import 'package:expencestracker/widgets/custom_app_bar.dart';
import 'package:expencestracker/widgets/custom_gradient.dart';
import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import '../data/database_helper.dart';

class PatternResetScreen extends StatefulWidget {
  @override
  _PatternResetScreenState createState() => _PatternResetScreenState();
}

class _PatternResetScreenState extends State<PatternResetScreen> {
  String? firstPattern;
  String message = 'Draw new pattern';
  bool isError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Pattern Reset'),
      body: Container(
        decoration: BoxDecoration(gradient: commonbackground),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: AspectRatio(
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
                        if (input.length < 4) {
                          setState(() {
                            message =
                                'Pattern too short!\nUse at least 4 points';
                            isError = true;
                          });
                          return;
                        }

                        if (firstPattern == null) {
                          firstPattern = input.join('-');
                          setState(() {
                            message = 'Draw pattern again to confirm';
                            isError = false;
                          });
                        } else {
                          if (firstPattern == input.join('-')) {
                            await DatabaseHelper.instance
                                .savePattern(firstPattern!);
                            Navigator.pop(context, true);
                          } else {
                            setState(() {
                              firstPattern = null;
                              message = 'Patterns do not match!\nTry again';
                              isError = true;
                            });
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
