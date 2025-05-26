class LoginResponseDTO {
  final String token;
  final String email;
  final String username;
  final String userId;
  final bool isFirstLogin;

  LoginResponseDTO({
    required this.token,
    required this.email,
    required this.username,
    required this.userId,
    required this.isFirstLogin,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      userId: json['userId'] ?? '',
      isFirstLogin: json['isFirstLogin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'username': username,
      'userId': userId,
      'isFirstLogin': isFirstLogin,
    };
  }
}
