import 'package:expencestracker/bloc/expense_bloc.dart';
import 'package:expencestracker/widgets/custom_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pattern_lock/pattern_lock.dart';
import '../data/database_helper.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final String validUsername = 'gokul';
  final String validPassword = '9843';
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String message = 'Draw pattern to unlock';
  bool isError = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  Future<void> checkLoginStatus() async {
    try {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: BlocProvider.of<ExpenseBloc>(context),
            child: HomeScreen(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking login status'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Replace the login button onPressed method
  // onPressed: () async {
  //   if (usernameController.text == validUsername &&
  //       passwordController.text == validPassword) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => BlocProvider.value(
  //           value: BlocProvider.of<ExpenseBloc>(context),
  //           child: HomeScreen(),
  //         ),
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Invalid credentials'),
  //         backgroundColor: Colors.red,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       ),
  //     );
  //   }
  // },

  // Remove the checkLoginStatus method entirely
  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: commonbackground),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          isError ? Icons.error_outline : Icons.lock_outline,
                          size: 60,
                          color: isError ? Colors.red : Colors.blue.shade400,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PatternLock(
                          selectedColor: Colors.white,
                          notSelectedColor: Colors.white38,
                          pointRadius: 8,
                          showInput: true,
                          dimension: 3,
                          relativePadding: 0.7,
                          selectThreshold: 25,
                          fillPoints: true,
                          onInputComplete: (List<int> input) async {
                            final savedPattern =
                                await DatabaseHelper.instance.getPattern();
                            if (savedPattern == input.join('-')) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value:
                                        BlocProvider.of<ExpenseBloc>(context),
                                    child: HomeScreen(),
                                  ),
                                ),
                              );
                            } else {
                              setState(() {
                                isError = true;
                                message = 'Wrong pattern!\nTry again';
                              });
                              Future.delayed(Duration(seconds: 2), () {
                                if (mounted) {
                                  setState(() {
                                    isError = false;
                                    message = 'Draw pattern to unlock';
                                  });
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
