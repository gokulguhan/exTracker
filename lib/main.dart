import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database_helper.dart';
import 'myapp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(AppLifecycleListener());
  
  // Initialize all async operations before runApp
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;
  final hasPattern = await dbHelper.getPattern() != null;
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Run the app after all initializations
  runApp(MyApp(
    dbHelper: dbHelper,
    hasPattern: hasPattern,
    prefs: sharedPreferences,
  ));
}

class AppLifecycleListener extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        // In this case, you might want to handle it or assign a default value.
        break;
    }
    debugPrint('App lifecycle state changed: $state');
    // You can add further logic here based on the app lifecycle state
  }
}
