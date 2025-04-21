import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/dtos/user_registration_dto.dart';
import '../../domain/models/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/app_user.dart';

// Add part directive for generated code
part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required http.Client httpClient,
    required this.baseUrl,
    required this.authBaseUrl,
    required this.firebaseAuth,
  }) : _httpClient = httpClient;

  final http.Client _httpClient;
  final String baseUrl; // For user registration - /api/v1/users
  final String authBaseUrl; // For login - /api/v1/auth
  final FirebaseAuth firebaseAuth;

  // Firebase Auth methods
  Stream<User?> authStateChanges() => firebaseAuth.authStateChanges();

  User? get currentUser => firebaseAuth.currentUser;

  Future<UserCredential> signInWithProvider(AuthProvider provider) {
    return firebaseAuth.signInWithProvider(provider);
  }

  // API Authentication methods
  @override
  Future<UserRegistrationResponse> registerUser(
      UserRegistrationDTO userDto) async {
    try {
      final registerUrl = '$baseUrl/register';
      developer.log('Making API request to: $registerUrl',
          name: 'auth_repository');

      final response = await _httpClient.post(
        Uri.parse(registerUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode(userDto.toJson()),
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'auth_repository');

      // Handle redirects explicitly
      if (response.statusCode == 302) {
        final redirectLocation = response.headers['location'];
        developer.log('Received redirect to: $redirectLocation',
            name: 'auth_repository');
        throw AuthError(
            'El servidor está redireccionando la solicitud. Esto podría indicar un problema de configuración.',
            statusCode: response.statusCode);
      }

      // Handle empty response body
      if (response.body.trim().isEmpty) {
        developer.log('Empty response body received', name: 'auth_repository');
        throw AuthError(
            'El servidor devolvió una respuesta vacía (código ${response.statusCode}).',
            statusCode: response.statusCode);
      }

      // Try to parse response as JSON
      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        developer.log('Failed to parse JSON: ${response.body}',
            name: 'auth_repository', error: e);
        throw AuthError(
            'Error al procesar la respuesta del servidor: ${e.toString()}');
      }

      if (response.statusCode == 201) {
        developer.log('Registration successful', name: 'auth_repository');
        return UserRegistrationResponse.fromJson(responseBody);
      } else {
        String errorMessage = responseBody is String
            ? responseBody
            : responseBody['message'] ?? 'Error en el registro';
        developer.log('Registration error: $errorMessage',
            name: 'auth_repository');
        throw AuthError(errorMessage, statusCode: response.statusCode);
      }
    } catch (e, stack) {
      developer.log('Network error in registerUser: $e',
          name: 'auth_repository', error: e, stackTrace: stack);
      if (e is AuthError) rethrow;
      throw AuthError('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Use authBaseUrl for login with a fallback to baseUrl if null
      final effectiveBaseUrl = authBaseUrl;
      final loginUrl = '$effectiveBaseUrl/login';

      developer.log('Making login request to: $loginUrl',
          name: 'auth_repository');

      final response = await _httpClient.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      developer.log('Login response status code: ${response.statusCode}',
          name: 'auth_repository');

      // Handle empty response body
      if (response.body.trim().isEmpty) {
        developer.log('Empty login response body received',
            name: 'auth_repository');
        throw AuthError(
            'El servidor devolvió una respuesta vacía (código ${response.statusCode}).',
            statusCode: response.statusCode);
      }

      // Try to parse response as JSON
      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        developer.log('Failed to parse login JSON: ${response.body}',
            name: 'auth_repository', error: e);
        throw AuthError(
            'Error al procesar la respuesta del servidor: ${e.toString()}');
      }

      if (response.statusCode == 200) {
        developer.log(
            'Login successful, token received: ${responseBody.containsKey('token')}',
            name: 'auth_repository');
        return responseBody;
      } else {
        String errorMessage = responseBody is String
            ? responseBody
            : responseBody['message'] ?? 'Error al iniciar sesión';
        developer.log('Login error: $errorMessage', name: 'auth_repository');
        throw AuthError(errorMessage, statusCode: response.statusCode);
      }
    } catch (e, stack) {
      developer.log('Network error in login: $e',
          name: 'auth_repository', error: e, stackTrace: stack);
      if (e is AuthError) rethrow;
      throw AuthError('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyGoogleLogin(
      UserCredential credential) async {
    try {
      final googleUser = credential.user;
      if (googleUser == null) {
        throw AuthError('Error de Google Sign-In: Usuario nulo');
      }

      // Get ID token from Firebase
      final idToken = await googleUser.getIdToken();

      // Send to backend for verification - use authBaseUrl with fallback
      final effectiveBaseUrl = authBaseUrl;
      final loginUrl = '$effectiveBaseUrl/auth/google';

      developer.log('Verifying Google login with backend at: $loginUrl',
          name: 'auth_repository');

      final response = await _httpClient.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'idToken': idToken,
          'email': googleUser.email,
          'displayName': googleUser.displayName,
          'photoURL': googleUser.photoURL,
          'uid': googleUser.uid,
        }),
      );

      developer.log(
          'Google verification response status: ${response.statusCode}',
          name: 'auth_repository');

      // Handle empty response body
      if (response.body.trim().isEmpty) {
        developer.log('Empty Google auth response body received',
            name: 'auth_repository');
        throw AuthError(
            'El servidor devolvió una respuesta vacía (código ${response.statusCode}).',
            statusCode: response.statusCode);
      }

      // Try to parse response as JSON
      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        developer.log('Failed to parse Google auth JSON: ${response.body}',
            name: 'auth_repository', error: e);
        throw AuthError(
            'Error al procesar la respuesta del servidor: ${e.toString()}');
      }

      if (response.statusCode == 200) {
        developer.log('Google login verification successful',
            name: 'auth_repository');
        return responseBody;
      } else {
        String errorMessage = responseBody is String
            ? responseBody
            : responseBody['message'] ?? 'Error al verificar login con Google';
        developer.log('Google login verification error: $errorMessage',
            name: 'auth_repository');
        throw AuthError(errorMessage, statusCode: response.statusCode);
      }
    } catch (e, stack) {
      developer.log('Error in verifyGoogleLogin: $e',
          name: 'auth_repository', error: e, stackTrace: stack);
      if (e is AuthError) rethrow;
      throw AuthError('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyAppleLogin(
      UserCredential credential) async {
    try {
      final appleUser = credential.user;
      if (appleUser == null) {
        throw AuthError('Error de Apple Sign-In: Usuario nulo');
      }

      // Get ID token from Firebase
      final idToken = await appleUser.getIdToken();

      // Send to backend for verification - use authBaseUrl with fallback
      final effectiveBaseUrl = authBaseUrl;
      final loginUrl = '$effectiveBaseUrl/auth/apple';

      developer.log('Verifying Apple login with backend at: $loginUrl',
          name: 'auth_repository');

      final response = await _httpClient.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'idToken': idToken,
          'email': appleUser.email,
          'displayName': appleUser.displayName,
          'uid': appleUser.uid,
        }),
      );

      developer.log(
          'Apple verification response status: ${response.statusCode}',
          name: 'auth_repository');

      // Handle empty response body
      if (response.body.trim().isEmpty) {
        developer.log('Empty Apple auth response body received',
            name: 'auth_repository');
        throw AuthError(
            'El servidor devolvió una respuesta vacía (código ${response.statusCode}).',
            statusCode: response.statusCode);
      }

      // Try to parse response as JSON
      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        developer.log('Failed to parse Apple auth JSON: ${response.body}',
            name: 'auth_repository', error: e);
        throw AuthError(
            'Error al procesar la respuesta del servidor: ${e.toString()}');
      }

      if (response.statusCode == 200) {
        developer.log('Apple login verification successful',
            name: 'auth_repository');
        return responseBody;
      } else {
        String errorMessage = responseBody is String
            ? responseBody
            : responseBody['message'] ?? 'Error al verificar login con Apple';
        developer.log('Apple login verification error: $errorMessage',
            name: 'auth_repository');
        throw AuthError(errorMessage, statusCode: response.statusCode);
      }
    } catch (e, stack) {
      developer.log('Error in verifyAppleLogin: $e',
          name: 'auth_repository', error: e, stackTrace: stack);
      if (e is AuthError) rethrow;
      throw AuthError('Error de conexión: ${e.toString()}');
    }
  }

  // Method to convert Firebase User to AppUser
  AppUser? _userFromFirebase(User? user) {
    if (user == null) {
      return null;
    }
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
    );
  }
}

// Convert manual provider to generated provider
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

// Provider for the repository
// Convert repository provider to generated provider
@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  // Choose the correct host based on platform
  String host;

  if (kIsWeb) {
    // Web uses the current origin
    host = 'http://localhost:8080';
  } else if (Platform.isAndroid) {
    // Android emulator needs special IP for host's localhost
    host = 'http://10.0.2.2:8080';
  } else {
    // iOS simulator and desktop can use localhost
    host = 'http://localhost:8080';
  }

  final usersBaseUrl = '$host/api/v1/users'; // For registration
  final authBaseUrl = '$host/api/v1/auth'; // For login

  developer.log('Using Registration API base URL: $usersBaseUrl',
      name: 'auth_repository_provider');
  developer.log('Using Auth API base URL: $authBaseUrl',
      name: 'auth_repository_provider');

  return AuthRepositoryImpl(
    httpClient: http.Client(),
    baseUrl: usersBaseUrl,
    authBaseUrl: authBaseUrl,
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
}

// Stream provider for authentication state changes
// Convert stream provider to generated provider
@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final repository = ref.watch(authRepositoryProvider) as AuthRepositoryImpl;
  return repository.authStateChanges();
}
