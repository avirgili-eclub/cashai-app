class UserRegistrationResponse {
  final String id;
  final String username;
  final String email;
  // Optional subscription field could be added later

  UserRegistrationResponse({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return UserRegistrationResponse(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
    );
  }
}

class AuthError implements Exception {
  final String message;
  final int? statusCode;

  AuthError(this.message, {this.statusCode});

  @override
  String toString() => message;
}
