class WalletTransaction {
  final int? id;  // Changed from int to int?
  final double amount;
  final bool isCredit;
  final DateTime date;
  final String description;

  WalletTransaction({
    this.id,  // Changed from required this.id
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,  // Only include id if it's not null
      'amount': amount,
      'isCredit': isCredit ? 1 : 0,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    return WalletTransaction(
      id: map['id'],
      amount: map['amount'],
      isCredit: map['isCredit'] == 1,
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }
}