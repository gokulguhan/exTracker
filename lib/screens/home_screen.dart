import 'package:expencestracker/screens/drawer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../models/expense.dart';
import '../data/database_helper.dart';
import 'package:intl/intl.dart';
import 'wallet_history_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  final List<String> _expenseTypes = [
    'Petrol',
    'Rapido',
    'Uber',
    'Bsevice',
    'Other'
  ];
  String? _selectedExpenseType;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Add this line
      drawer: DrawerView(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade100],
            // colors: [Colors.blue.shade300, Colors.purple.shade300],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildWalletCard(),
              Expanded(child: _buildExpensesList()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(),
    );
  }

  // Update the logout function in _buildAppBar()
  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer(); // Update this line
                },
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Expenses',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Update the logout button
          // IconButton(
          //   icon: Icon(Icons.logout, color: Colors.white),
          //   onPressed: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => LoginScreen()),
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: Icon(
          //     size: 30,
          //     Icons.lock_reset,
          //     color: Colors.white,
          //   ),
          //   onPressed: () async {
          //     final result = await Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => PatternResetScreen()),
          //     );
          //     if (result == true) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(
          //           content: Text('Pattern successfully updated'),
          //           backgroundColor: Colors.green,
          //           behavior: SnackBarBehavior.floating,
          //         ),
          //       );
          //     }
          //   },
          // ),
          Hero(
            tag: 'logo',
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseInitial) {
          context.read<ExpenseBloc>().add(LoadExpenses());
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (state is ExpenseLoading) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (state is ExpenseLoaded) {
          if (state.expenses.isEmpty) {
            return Center(
              child: Text(
                'No expenses yet!\nAdd your first expense.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: state.expenses.length,
                itemBuilder: (context, index) {
                  final expense = state.expenses[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        index * 0.1,
                        1.0,
                        curve: Curves.easeOut,
                      ),
                    )),
                    child: _buildExpenseCard(expense),
                  );
                },
              );
            },
          );
        }
        return Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Dismissible(
      key: Key(expense.id.toString()),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<ExpenseBloc>().add(DeleteExpense(expense));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense deleted'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _showEditExpenseDialog(context, expense),
        child: Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        expense.description,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '₹${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      expense.expenseType,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(expense.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditExpenseDialog(BuildContext context, Expense expense) {
    final descriptionController =
        TextEditingController(text: expense.description);
    final amountController =
        TextEditingController(text: expense.amount.toString());
    final expenseTypeController =
        TextEditingController(text: expense.expenseType);

    // Check if the expense type exists in the list, if not add it
    if (!_expenseTypes.contains(expense.expenseType) &&
        expense.expenseType != 'Other') {
      _expenseTypes.insert(_expenseTypes.length - 1, expense.expenseType);
    }
    _selectedExpenseType = expense.expenseType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Expense',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Replace the TextField with Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            value: _selectedExpenseType,
                            hint: Text('Select Expense Type'),
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.blue.shade700),
                            items: _expenseTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedExpenseType = newValue;
                                  if (newValue != 'Other') {
                                    expenseTypeController.text = newValue;
                                  } else {
                                    _showCustomTypeDialog(
                                        context, expenseTypeController);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        elevation: 8,
        icon: Icon(Icons.add),
        label: Text('Add Expense'),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final expenseTypeController = TextEditingController();
    final _fromkey = GlobalKey<FormState>();
    _selectedExpenseType = null; // Reset selected type for new expense

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_shopping_cart,
                color: Colors.blue.shade700,
                size: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Add New Expense',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Form(
            key: _fromkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  validator: (value) {
                    if (value!.isEmpty || value == '') {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon:
                        Icon(Icons.description, color: Colors.blue.shade700),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty || value == '') {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    prefixIcon:
                        Icon(Icons.currency_rupee, color: Colors.blue.shade700),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                  ),
                ),
                SizedBox(height: 16),
                // Replace the existing TextField for expenseType with this:
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              value: _selectedExpenseType,
                              hint: Text('Select Expense Type'),
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blue.shade700),
                              items: _expenseTypes.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedExpenseType = newValue;
                                  if (newValue != 'Other') {
                                    expenseTypeController.text = newValue ?? '';
                                  } else {
                                    _showCustomTypeDialog(
                                        context, expenseTypeController);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    print("hai");
                    if (_fromkey.currentState?.validate() == true) {
                      if (descriptionController.text.isNotEmpty &&
                          amountController.text.isNotEmpty &&
                          expenseTypeController.text.isNotEmpty) {
                        final amount = double.parse(amountController.text);
                        if (await DatabaseHelper.instance
                            .deductFromWallet(amount)) {
                          final expense = Expense(
                            description: descriptionController.text,
                            amount: amount,
                            expenseType: expenseTypeController.text,
                            date: DateTime.now(),
                          );
                          context.read<ExpenseBloc>().add(AddExpense(expense));
                          Navigator.pop(context);
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Insufficient wallet balance'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add Expense',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add this widget after the app bar
  Widget _buildWalletCard() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Balance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<double>(
                    future: DatabaseHelper.instance.getWalletBalance(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          '₹${snapshot.data?.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        );
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ],
              ),
              BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseLoaded) {
                    final total = state.expenses.fold<double>(
                      0,
                      (sum, expense) => sum + expense.amount,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Expenses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ],
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
            ],
          ),
          // In _buildWalletCard(), update the button row
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAddMoneyDialog(context),
                  child: Text(
                    'Add Money',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WalletHistoryScreen()),
                  );
                },
                child: Icon(Icons.history),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context) {
    final _fromkey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.blue.shade700,
                size: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Add Money to Wallet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Form(
            key: _fromkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty || value == '') {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixIcon: Icon(Icons.money_sharp),
                    prefixStyle: TextStyle(fontSize: 24),
                    hintText: 'Enter Amount',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blue.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_fromkey.currentState?.validate() == true) {
                      final amount = double.tryParse(amountController.text);
                      if (amount != null && amount > 0) {
                        await DatabaseHelper.instance.addToWallet(amount);
                        Navigator.pop(context);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('₹$amount added to wallet'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add Money',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCustomTypeDialog(
      BuildContext context, TextEditingController expenseTypeController) {
    final customTypeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom Type'),
        content: TextField(
          controller: customTypeController,
          decoration: InputDecoration(
            labelText: 'Enter expense type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (customTypeController.text.isNotEmpty) {
                setState(() {
                  _expenseTypes.insert(
                      _expenseTypes.length - 1, customTypeController.text);
                  _selectedExpenseType = customTypeController.text;
                  expenseTypeController.text = customTypeController.text;
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

// Update your expense addition logic to check wallet balance
}

// In your AppBar actions or drawer menu

