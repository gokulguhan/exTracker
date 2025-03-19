import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/wallet_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Update version number to 3
  static const _version = 4;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // Add this line
    );
  }

  // Update version number
  // static const _version = 3;

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        description $textType,
        amount $doubleType,
        expenseType $textType,
        date $textType
      )
    ''');

    // Create wallet table
    await db.execute('''
      CREATE TABLE wallet (
        id $idType,
        balance $doubleType DEFAULT 0.0
      )
    ''');

    // Create wallet_transactions table
    await db.execute('''
      CREATE TABLE wallet_transactions (
        id $idType,
        amount $doubleType,
        isCredit INTEGER NOT NULL,
        date $textType,
        description $textType
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Initialize wallet with 0 balance
    await db.insert('wallet', {'balance': 0.0});
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE wallet (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          balance REAL DEFAULT 0.0
        )
      ''');
      await db.insert('wallet', {'balance': 0.0});
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE wallet_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          isCredit INTEGER NOT NULL,
          date TEXT NOT NULL,
          description TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  Future<int> insertExpense(Expense expense) async {
    try {
      final db = await instance.database;
      return await db.insert('expenses', expense.toMap());
    } catch (e) {
      print('Error inserting expense: $e');
      throw Exception('Failed to insert expense');
    }
  }

  Future<List<Expense>> getAllExpenses() async {
    try {
      final db = await instance.database;
      final result = await db.query('expenses', orderBy: 'date DESC');
      return result.map((json) => Expense.fromMap(json)).toList();
    } catch (e) {
      print('Error getting expenses: $e');
      throw Exception('Failed to get expenses');
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final db = await instance.database;
      final result = await db.query('expenses', orderBy: 'date DESC');
      return result.map((json) => Expense.fromMap(json)).toList();
    } catch (e) {
      print('Error getting expenses: $e');
      throw Exception('Failed to get expenses');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Add these methods to your DatabaseHelper class

  Future<void> createWalletTable(Database db) async {
    await db.execute('''
      CREATE TABLE wallet(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        balance REAL
      )
    ''');
    // Initialize wallet with 0 balance
    await db.insert('wallet', {'balance': 0.0});
  }

  Future<double> getWalletBalance() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('wallet');
    if (maps.isEmpty) {
      await db.insert('wallet', {'balance': 0.0});
      return 0.0;
    }
    return maps.first['balance'];
  }

  Future<void> updateWalletBalance(double newBalance) async {
    final db = await database;
    await db.update(
      'wallet',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // Add to your DatabaseHelper class

  Future<void> createWalletTransactionTable(Database db) async {
    await db.execute('''
      CREATE TABLE wallet_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        isCredit INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
  }

  Future<void> addWalletTransaction(WalletTransaction transaction) async {
    final db = await database;
    await db.insert('wallet_transactions', transaction.toMap());
  }

  Future<List<WalletTransaction>> getWalletTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallet_transactions',
      orderBy: 'date DESC',
    );
    return List.generate(
        maps.length, (i) => WalletTransaction.fromMap(maps[i]));
  }

  // Update these methods to record transactions
  Future<void> addToWallet(double amount) async {
    final currentBalance = await getWalletBalance();
    await updateWalletBalance(currentBalance + amount);
    await addWalletTransaction(
      WalletTransaction(
        id: null, // Changed from 0 to null
        amount: amount,
        isCredit: true,
        date: DateTime.now(),
        description: 'Added to wallet',
      ),
    );
  }

  Future<bool> deductFromWallet(double amount) async {
    final currentBalance = await getWalletBalance();
    if (currentBalance >= amount) {
      await updateWalletBalance(currentBalance - amount);
      await addWalletTransaction(
        WalletTransaction(
          id: null, // Changed from 0 to null
          amount: amount,
          isCredit: false,
          date: DateTime.now(),
          description: 'Expense deduction',
        ),
      );
      return true;
    }
    return false;
  }

  Future<void> savePattern(String pattern) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'pattern', 'value': pattern},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPattern() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['pattern'],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }
}
  // Increment this from 1 to 2
