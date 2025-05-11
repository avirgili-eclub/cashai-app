import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../domain/entities/user_profile_dto.dart';
import '../../domain/entities/password_change_dto.dart';
import '../../domain/entities/api_response_dto.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/firebase_user_profile_datasource.dart';

part 'user_profile_repository_impl.g.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseUserProfileDataSource dataSource;
  final String token;
  final String userId;

  UserProfileRepositoryImpl({
    required this.dataSource,
    required this.token,
    required this.userId,
  });

  @override
  Future<UserProfileDTO> getUserProfile() async {
    developer.log(
        'Getting user profile with token: ${token.isNotEmpty ? "Valid Token" : "Empty Token"}',
        name: 'user_profile_repository');
    developer.log('Getting user profile with userId: $userId',
        name: 'user_profile_repository');
    try {
      final profile = await dataSource.getUserProfile(token, userId);
      developer.log('Successfully retrieved user profile',
          name: 'user_profile_repository');
      return profile;
    } catch (e, stack) {
      developer.log('Error getting user profile: $e',
          name: 'user_profile_repository', error: e, stackTrace: stack);

      // Return default profile in case of error
      return const UserProfileDTO(
        username: 'Usuario',
        email: 'usuario@example.com',
        askForAudioCategory: true,
        askForTransactionCategoryNotification: false,
        authBiometric: false,
      );
    }
  }

  @override
  Future<UserProfileDTO> updateUserProfile(Map<String, dynamic> updates) async {
    developer.log('Updating user profile', name: 'user_profile_repository');
    try {
      final updatedProfile =
          await dataSource.updateUserProfile(token, userId, updates);
      developer.log('User profile updated successfully',
          name: 'user_profile_repository');
      return updatedProfile;
    } catch (e, stack) {
      developer.log('Error updating user profile: $e',
          name: 'user_profile_repository', error: e, stackTrace: stack);
      // Return default profile in case of error
      return const UserProfileDTO(
        username: 'Usuario',
        email: 'usuario@example.com',
        askForAudioCategory: true,
        askForTransactionCategoryNotification: false,
        authBiometric: false,
      );
    }
  }

  @override
  Future<ApiResponseDTO<void>> changePassword(
      PasswordChangeDTO passwordChangeDTO) async {
    developer.log('Changing user password', name: 'user_profile_repository');

    try {
      final result = await dataSource.changePassword(token, passwordChangeDTO);
      developer.log(
          'Password change result: ${result.success ? "Success" : "Failed"} - ${result.message}',
          name: 'user_profile_repository');
      return result;
    } catch (e, stack) {
      developer.log('Error changing password: $e',
          name: 'user_profile_repository', error: e, stackTrace: stack);
      return ApiResponseDTO(
        success: false,
        message: 'Error al cambiar la contraseña: $e',
      );
    }
  }
}

@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepositoryImpl(
    UserProfileRepositoryImplRef ref) {
  final dataSource = ref.watch(userProfileDataSourceProvider);
  final userSession = ref.watch(userSessionNotifierProvider);

  // Check if user is properly authenticated
  if (userSession.token == null ||
      userSession.token!.isEmpty ||
      userSession.userId == null ||
      userSession.userId!.isEmpty) {
    // Log the issue
    developer.log(
        'Invalid token or userId when creating user profile repository',
        name: 'user_profile_repository');

    // Return a repository with empty token
    return UserProfileRepositoryImpl(
      dataSource: dataSource,
      token: '',
      userId: '',
    );
  }

  // User is authenticated, return normal repository
  return UserProfileRepositoryImpl(
    dataSource: dataSource,
    token: userSession.token!,
    userId: userSession.userId!,
  );
}
