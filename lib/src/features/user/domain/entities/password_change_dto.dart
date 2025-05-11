class PasswordChangeDTO {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  PasswordChangeDTO({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  // Add a validation method
  bool isValid() {
    return currentPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword;
  }

  // Check if passwords match
  bool passwordsMatch() {
    return newPassword == confirmPassword;
  }
}
