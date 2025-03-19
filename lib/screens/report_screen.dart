import 'dart:collection';
import 'dart:math';
import 'package:expencestracker/widgets/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../models/expense.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 140, 195, 240),
      appBar: CustomAppBar(
        title: 'Reports',
        showHomeButton: true,
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          // Add this to trigger initial load
          if (state is ExpenseInitial) {
            context.read<ExpenseBloc>().add(LoadExpenses());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: TextStyle(color: Colors.red.shade400),
              ),
            );
          }

          if (state is ExpenseLoaded) {
            final expenses = state.expenses;
            if (expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No expenses to display',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            try {
              final sortedExpenses = List<Expense>.from(expenses)
                ..sort((a, b) => b.date.compareTo(a.date));

              final monthlyExpenses = calculateMonthlyExpenses(sortedExpenses);
              final dailyExpenses = calculateDailyExpenses(sortedExpenses);
              // this use to calculate the total expense, average expense, and highest expense
              final totalExpense =
                  expenses.fold(0.0, (sum, expense) => sum + expense.amount);
              final averageExpense = totalExpense / expenses.length;
              final highestExpense =
                  expenses.reduce((a, b) => a.amount > b.amount ? a : b).amount;

// this use max amount to find the maximum amount for proper scaling
              final maxAmount = monthlyExpenses.values.reduce(max);
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          gridCard(
                              'Total Expenses',
                              '₹${totalExpense.toStringAsFixed(2)}',
                              Colors.blue),
                          gridCard(
                              'Average',
                              '₹${averageExpense.toStringAsFixed(2)}',
                              Colors.green),
                          gridCard(
                              'Highest',
                              '₹${highestExpense.toStringAsFixed(2)}',
                              Colors.orange),
                          gridCard(
                              'Count', '${expenses.length}', Colors.purple),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly Overview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: monthlyExpenses.length,
                                  itemBuilder: (context, index) {
                                    final month =
                                        monthlyExpenses.keys.elementAt(index);
                                    final amount =
                                        monthlyExpenses.values.elementAt(index);
                                    return monthBar(month, amount, maxAmount);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      dailyExpensesList(dailyExpenses),
                    ],
                  ),
                ),
              );
            } catch (e) {
              return Center(
                child: Text(
                  'Error loading expenses',
                  style: TextStyle(color: Colors.red.shade400),
                ),
              );
            }
          }

          // Add this default return statement
          return const Center(
            child: Text('Unexpected state'),
          );
        },
      ),
    );
  }

  Widget monthBar(String month, double amount, double maxAmount) {
    // Calculate height percentage based on maximum amount
    final heightPercentage = (amount / maxAmount) * 150;

    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: heightPercentage.clamp(20, 150), // Minimum height of 20
            width: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 8),
          Text(month, style: const TextStyle(fontSize: 12)),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget gridCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.7), color],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dailyExpensesList(Map<String, double> dailyExpenses) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...dailyExpenses.entries.map((entry) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        '₹${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Map<String, double> calculateMonthlyExpenses(List<Expense> expenses) {
    final monthlyMap = SplayTreeMap<String, double>();
    for (var expense in expenses) {
      final month = DateFormat('MMM').format(expense.date);
      monthlyMap[month] = (monthlyMap[month] ?? 0) + expense.amount;
    }
    return monthlyMap;
  }

  Map<String, double> calculateDailyExpenses(List<Expense> expenses) {
    final dailyMap = SplayTreeMap<String, double>();

    for (var expense in expenses) {
      final day = DateFormat('MMM dd').format(expense.date);
      dailyMap[day] = (dailyMap[day] ?? 0) + expense.amount;
    }

    return dailyMap;
  }
}
