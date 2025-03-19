import 'package:expencestracker/widgets/custom_gradient.dart';
import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import '../data/database_helper.dart';
import 'home_screen.dart';

class PatternSetupScreen extends StatefulWidget {
  @override
  _PatternSetupScreenState createState() => _PatternSetupScreenState();
}

class _PatternSetupScreenState extends State<PatternSetupScreen> {
  String? firstPattern;
  String message = 'Draw your pattern';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(gradient: commonbackground),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Container(
                      width: screenWidth * 0.8,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
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
                            if (input.length < 4) {
                              setState(() {
                                message =
                                    'Pattern too short!\nDraw at least 4 points';
                              });
                              return;
                            }

                            if (firstPattern == null) {
                              firstPattern = input.join('-');
                              setState(() {
                                message = 'Confirm your pattern';
                              });
                            } else {
                              if (firstPattern == input.join('-')) {
                                await DatabaseHelper.instance
                                    .savePattern(firstPattern!);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                );
                              } else {
                                setState(() {
                                  firstPattern = null;
                                  message = 'Patterns do not match!\nTry again';
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
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
