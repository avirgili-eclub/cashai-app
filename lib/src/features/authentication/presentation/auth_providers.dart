import 'package:flutter_riverpod/flutter_riverpod.dart';

// This provider will be used to configure authentication options
final authProvidersProvider = Provider<List<String>>((ref) {
  return ['email', 'google', 'apple']; // Updated to include social options
});
