import 'package:flutter_riverpod/flutter_riverpod.dart';

// This provider will be used to configure authentication options
// We'll implement this later when we connect to the Spring Boot backend
final authProvidersProvider = Provider<List<String>>((ref) {
  return ['email', 'anonymous'];
});
