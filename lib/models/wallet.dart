class Wallet {
  final int id;
  final double balance;

  Wallet({required this.id, required this.balance});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'balance': balance,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      balance: map['balance'],
    );
  }
}