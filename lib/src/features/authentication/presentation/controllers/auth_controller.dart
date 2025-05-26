import 'dart:developer' as developer;
import 'dart:async'; // Add this import for TimeoutException
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../domain/dtos/user_registration_dto.dart';
import '../../domain/dtos/login_response_dto.dart';
import '../../domain/models/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../features/dashboard/presentation/providers/post_login_splash_provider.dart';
import '../../../../features/user/domain/entities/api_response_dto.dart';

// Auth state for the controller
class AuthState {
  final bool isLoading;
  final String? error;
  final UserRegistrationResponse? registrationResponse;
  final ApiResponseDTO<LoginResponseDTO>? loginResponse;
  final Map<String, dynamic>? googleLoginResponse;
  final Map<String, dynamic>? appleLoginResponse;

  AuthState({
    this.isLoading = false,
    this.error,
    this.registrationResponse,
    this.loginResponse,
    this.googleLoginResponse,
    this.appleLoginResponse,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserRegistrationResponse? registrationResponse,
    ApiResponseDTO<LoginResponseDTO>? loginResponse,
    Map<String, dynamic>? googleLoginResponse,
    Map<String, dynamic>? appleLoginResponse,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      registrationResponse: registrationResponse ?? this.registrationResponse,
      loginResponse: loginResponse ?? this.loginResponse,
      googleLoginResponse: googleLoginResponse ?? this.googleLoginResponse,
      appleLoginResponse: appleLoginResponse ?? this.appleLoginResponse,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final UserSessionNotifier _userSession;
  final Ref _ref;

  AuthController(this._authRepository, this._userSession, this._ref)
      : super(AuthState());

  Future<UserRegistrationResponse?> registerUser({
    required String email,
    required String password,
    String? username,
    String? celular,
    String? codigoIdentificador,
  }) async {
    developer.log('Registering user with email: $email',
        name: 'auth_controller');
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userDto = UserRegistrationDTO(
        username: username ??
            email.split('@')[0], // Use email prefix as default username
        email: email,
        password: password,
        celular: celular,
        codigoIdentificador: codigoIdentificador,
      );

      final response = await _authRepository.registerUser(userDto);
      developer.log('Registration successful: ${response.id}',
          name: 'auth_controller');

      state = state.copyWith(
        isLoading: false,
        registrationResponse: response,
      );
      return response;
    } catch (e, stack) {
      developer.log('Registration error: $e',
          name: 'auth_controller', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<ApiResponseDTO<LoginResponseDTO>?> login({
    required String email,
    required String password,
  }) async {
    developer.log('Login attempt for email: $email', name: 'auth_controller');
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Set splash screen to show before login attempt
      _ref.read(postLoginSplashStateProvider.notifier).showSplash();
      developer.log('Splash screen activated for login',
          name: 'auth_controller');

      // Make the API call with proper error handling and timeout
      final response = await _authRepository.login(email, password).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          developer.log('Login API call timeout', name: 'auth_controller');
          throw TimeoutException(
              'La conexión ha tardado demasiado tiempo. Intente nuevamente.');
        },
      );

      // Update user session with the received data
      if (response.data != null) {
        final loginData = response.data!;
        final userId = loginData.userId;
        final token = loginData.token;
        final username = loginData.username;
        final userEmail = loginData.email;

        developer.log(
            'Login successful, setting user session with userId: $userId',
            name: 'auth_controller');

        _userSession.setUserSession(
          userId: userId,
          token: token,
          username: username,
          email: userEmail,
        );

        // Make sure splash screen is active
        _ref.read(postLoginSplashStateProvider.notifier).showSplash();
      } else {
        developer.log('Warning: Response data is null',
            name: 'auth_controller');
      }

      state = state.copyWith(
        isLoading: false,
        loginResponse: response,
        error: null,
      );

      return response;
    } on TimeoutException catch (e) {
      developer.log('Login timeout: $e', name: 'auth_controller');

      // Hide splash on timeout
      _ref.read(postLoginSplashStateProvider.notifier).hideSplash();

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    } catch (e, stack) {
      developer.log('Login error: $e',
          name: 'auth_controller', error: e, stackTrace: stack);

      // Hide splash on error
      _ref.read(postLoginSplashStateProvider.notifier).hideSplash();

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> signInWithGoogle(
      UserCredential credential) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _authRepository.verifyGoogleLogin(credential);

      // Update user session with the received user ID
      if (response.containsKey('id')) {
        _userSession.setUserId(response['id'].toString());
      }

      state = state.copyWith(
        isLoading: false,
        googleLoginResponse: response,
        error: null,
      );

      return response;
    } catch (e, stack) {
      developer.log('Google sign-in error: $e',
          name: 'auth_controller', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> signInWithApple(
      UserCredential credential) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _authRepository.verifyAppleLogin(credential);

      // Update user session with the received user ID
      if (response.containsKey('id')) {
        _userSession.setUserId(response['id'].toString());
      }

      state = state.copyWith(
        isLoading: false,
        appleLoginResponse: response,
        error: null,
      );

      return response;
    } catch (e, stack) {
      developer.log('Apple sign-in error: $e',
          name: 'auth_controller', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(userSessionNotifierProvider.notifier),
    ref,
  );
});
