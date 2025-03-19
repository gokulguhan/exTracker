import 'dart:math' show pi, sin;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/expense_bloc.dart';
import 'data/database_helper.dart';

import 'screens/pattern_setup_screen.dart';
import 'screens/splash_view.dart';

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;
  final bool hasPattern;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SharedPreferences prefs;

  MyApp(
      {Key? key,
      required this.dbHelper,
      required this.hasPattern,
      required this.prefs})
      : super(key: key);

  Future<bool> _authenticateUser() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        return true;
      }
      ;

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return true;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      debugPrint('Authentication error: $e');
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remove this line as we're already passing prefs through constructor
    // final sharedPreferences = SharedPreferences.getInstance();
    
    return BlocProvider(
      create: (context) => ExpenseBloc(dbHelper: dbHelper),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder<bool>(
          future: _authenticateUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.data == true) {
              return hasPattern
                  ? FutureBuilder<String?>(
                      future: dbHelper.getPattern(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return snapshot.hasData
                            ? SplashView()
                            : PatternSetupScreen();
                      },
                    )
                  : PatternSetupScreen();
            }

            return Scaffold(
              body: AnimatedContainer(
                duration: Duration(seconds: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade900,
                      Colors.red.shade700,
                      Colors.red.shade500,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: TweenAnimationBuilder(
                  duration: Duration(seconds: 2),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: Offset(0, sin(value * 5 * pi) * 10),
                            child: TweenAnimationBuilder(
                              duration: Duration(milliseconds: 800),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, double scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 20),
                              child: Text(
                                'Authentication required',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: value,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyApp(
                                        dbHelper: dbHelper,
                                        hasPattern: hasPattern,
                                        prefs: prefs,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Try Again',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
