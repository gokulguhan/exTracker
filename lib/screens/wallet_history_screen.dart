import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet_transaction.dart';
import '../data/database_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_gradient.dart';

class WalletHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Wallet History',
      ),
      body: Container(
        decoration: BoxDecoration(gradient: commonbackground),
        child: FutureBuilder<List<WalletTransaction>>(
          future: DatabaseHelper.instance.getWalletTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                decoration: BoxDecoration(gradient: commonbackground),
                child: Center(
                  child: Text('No transactions yet'),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final transaction = snapshot.data![index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.isCredit
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        transaction.isCredit ? Icons.add : Icons.remove,
                        color: transaction.isCredit ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      transaction.description,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(transaction.date),
                    ),
                    trailing: Text(
                      '${transaction.isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction.isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
