class CustomCategoryRequest {
  final String name;
  final String emoji;
  final String color;
  final String? description;

  CustomCategoryRequest({
    required this.name,
    required this.emoji,
    required this.color,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'emoji': emoji,
      'color': color,
      if (description != null) 'description': description,
    };
  }
}
