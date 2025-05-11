import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_profile_dto.dart';
import '../../domain/entities/password_change_dto.dart';
import '../../domain/entities/api_response_dto.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../routing/app_router.dart';

part 'user_profile_controller.g.dart';

@riverpod
class UserProfileController extends _$UserProfileController {
  @override
  Future<UserProfileDTO> build() async {
    developer.log('UserProfileController build called',
        name: 'user_profile_controller');
    return _fetchUserProfile();
  }

  Future<UserProfileDTO> _fetchUserProfile() async {
    developer.log('Fetching user profile data',
        name: 'user_profile_controller');

    // Check for valid user token first
    final userSession = ref.read(userSessionNotifierProvider);
    if (userSession.token == null || userSession.token!.isEmpty) {
      developer.log('No valid token found, cannot fetch user profile',
          name: 'user_profile_controller');

      // Trigger navigation to sign-in page using the router
      Future.microtask(() {
        final router = ref.read(goRouterProvider);
        router.go('/signIn');
      });

      // Return a default profile
      return const UserProfileDTO();
    }

    final repository = ref.watch(userProfileRepositoryProvider);
    try {
      final profile = await repository.getUserProfile();
      developer.log('User profile fetched successfully: ${profile.username}',
          name: 'user_profile_controller');
      return profile;
    } catch (e, stack) {
      developer.log('Error fetching user profile: $e',
          name: 'user_profile_controller', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refreshUserProfile() async {
    developer.log('Manual refresh triggered', name: 'user_profile_controller');
    state = const AsyncValue.loading();
    try {
      final profile = await _fetchUserProfile();
      developer.log('User profile refreshed successfully',
          name: 'user_profile_controller');
      state = AsyncValue.data(profile);
    } catch (e, st) {
      developer.log('Refresh failed',
          name: 'user_profile_controller', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  // Updated to directly set state with returned profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    developer.log('Updating user profile: $updates',
        name: 'user_profile_controller');

    try {
      state = const AsyncValue.loading();
      final repository = ref.read(userProfileRepositoryProvider);
      final updatedProfile = await repository.updateUserProfile(updates);

      // Directly update state with new profile
      state = AsyncValue.data(updatedProfile);
      developer.log('Profile updated successfully: ${updatedProfile.username}',
          name: 'user_profile_controller');

      return true;
    } catch (e, st) {
      developer.log('Failed to update profile',
          name: 'user_profile_controller', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<ApiResponseDTO<void>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    developer.log('Attempting to change password',
        name: 'user_profile_controller');

    final passwordChangeDTO = PasswordChangeDTO(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    // Client-side validation
    if (!passwordChangeDTO.isValid()) {
      return ApiResponseDTO(
        success: false,
        message: !passwordChangeDTO.passwordsMatch()
            ? 'Las contraseñas no coinciden'
            : 'Todos los campos son obligatorios',
      );
    }

    // Call the repository to change password
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      final result = await repository.changePassword(passwordChangeDTO);

      if (result.success) {
        developer.log('Password changed successfully',
            name: 'user_profile_controller');
      } else {
        developer.log('Failed to change password: ${result.message}',
            name: 'user_profile_controller');
      }

      return result;
    } catch (e, st) {
      developer.log('Error while changing password: $e',
          name: 'user_profile_controller', error: e, stackTrace: st);
      return ApiResponseDTO(
        success: false,
        message: 'Error al cambiar la contraseña: $e',
      );
    }
  }
}
