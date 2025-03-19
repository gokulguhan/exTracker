class Expense {
  final int? id;
  final String description;
  final double amount;
  final String expenseType;
  final DateTime date;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.expenseType,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'expenseType': expenseType,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      expenseType: map['expenseType'],
      date: DateTime.parse(map['date']),
    );
  }
}
