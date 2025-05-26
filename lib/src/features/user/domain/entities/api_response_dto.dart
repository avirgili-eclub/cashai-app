class ApiResponseDTO<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponseDTO({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponseDTO.fromJson(Map<String, dynamic> json) {
    return ApiResponseDTO(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] is T ? json['data'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
