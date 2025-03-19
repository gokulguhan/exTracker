import 'package:expencestracker/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/expense_bloc.dart';
import '../widgets/custom_gradient.dart';
import 'pattern_reset_screen.dart';
import 'report_screen.dart';
import 'wallet_history_screen.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(gradient: commonbackground),
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.blue.shade700,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Expense Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                'Home',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                'Transaction History',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WalletHistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  Icons.lock,
                  key: ValueKey<bool>(false),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'App Lock',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  FutureBuilder<bool>(
                    future: SharedPreferences.getInstance().then(
                        (prefs) => prefs.getBool('isLockEnabled') ?? false),
                    builder: (context, snapshot) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (snapshot.data ?? false)
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Switch(
                          value: snapshot.data ?? false,
                          onChanged: (bool value) async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('isLockEnabled', value);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          activeColor: Colors.white,
                          activeTrackColor:
                              const Color.fromARGB(255, 55, 212, 60),
                          inactiveThumbColor: Colors.grey.shade300,
                          inactiveTrackColor: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.lock_reset_outlined,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                'Pattern Reset',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatternResetScreen()),
                );
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pattern successfully updated'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            ListTile(
              selectedTileColor: Colors.white.withOpacity(0.2),
              leading: Icon(
                Icons.bar_chart,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                'Reports',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<ExpenseBloc>.value(
                      value: BlocProvider.of<ExpenseBloc>(context),
                      child: const ReportScreen(),
                    ),
                  ),
                );
              },
            ),

            FutureBuilder<bool>(
              future: SharedPreferences.getInstance()
                  .then((prefs) => prefs.getBool('isLockEnabled') ?? false),
              builder: (context, snapshot) {
                final bool isLockEnabled = snapshot.data ?? false;
                return isLockEnabled
                    ? ListTile(
                        leading: Icon(
                          Icons.login_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        onTap: () => {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          )
                        },
                      )
                    : SizedBox
                        .shrink(); // Returns an empty widget when lock is enabled
              },
            ),
            // Divider(color: Colors.white.withOpacity(0.2)),
            // ListTile(
            //   leading: Icon(Icons.info_outline, color: Colors.white),
            //   title: Text(
            //     'About',
            //     style: TextStyle(color: Colors.white, fontSize: 16),
            //   ),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // Show about dialog
            //     showAboutDialog(
            //       context: context,
            //       applicationName: 'Expense Tracker',
            //       applicationVersion: '1.0.0',
            //       applicationIcon: Icon(
            //         Icons.account_balance_wallet,
            //         color: Colors.blue.shade700,
            //         size: 50,
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
