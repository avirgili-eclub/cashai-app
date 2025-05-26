import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum to represent all possible screens in the bottom navigation
enum ActiveScreen { home, statistics, calendar, settings }

// Provider to track the currently active screen
final activeScreenProvider = StateProvider<ActiveScreen>((ref) {
  return ActiveScreen.home; // Default to home screen
});
