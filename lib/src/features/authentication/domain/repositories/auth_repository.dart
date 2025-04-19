import 'package:firebase_auth/firebase_auth.dart';
import '../dtos/user_registration_dto.dart';
import '../models/auth_response.dart';
import '../app_user.dart';

abstract class AuthRepository {
  // API authentication methods
  Future<UserRegistrationResponse> registerUser(UserRegistrationDTO userDto);
  Future<Map<String, dynamic>> login(String email, String password);

  // Firebase authentication methods for social sign-in
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<UserCredential> signInWithProvider(AuthProvider provider);

  // Social login with backend verification
  Future<Map<String, dynamic>> verifyGoogleLogin(UserCredential credential);
  Future<Map<String, dynamic>> verifyAppleLogin(UserCredential credential);
}
