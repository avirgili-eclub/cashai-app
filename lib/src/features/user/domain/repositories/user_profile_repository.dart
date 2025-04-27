import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/user_profile_dto.dart';
import '../../data/repositories/user_profile_repository_impl.dart';

part 'user_profile_repository.g.dart';

abstract class UserProfileRepository {
  Future<UserProfileDTO> getUserProfile();
  Future<UserProfileDTO> updateUserProfile(Map<String, dynamic> updates);
}

@riverpod
UserProfileRepository userProfileRepository(UserProfileRepositoryRef ref) {
  return ref.watch(userProfileRepositoryImplProvider);
}
