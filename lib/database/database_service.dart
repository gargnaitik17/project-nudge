import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
class NudgeDatabase {
  NudgeDatabase._();

  static final NudgeDatabase instance = NudgeDatabase._();

  Database? _database;

  static const int databaseVersion = 7;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, 'nudge.db');

    _database = await openDatabase(
      dbPath,
      version: databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );

    return _database!;
  }

  // ==========================================================
  // CREATE
  // ==========================================================

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'Other',
        amount REAL NOT NULL,
        type TEXT NOT NULL DEFAULT 'expense',
        note TEXT NOT NULL DEFAULT '',
        paymentMethod TEXT NOT NULL DEFAULT 'Cash',
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL DEFAULT 'Nudge User',
        age INTEGER NOT NULL DEFAULT 18,
        phone TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL DEFAULT '',
        college TEXT NOT NULL DEFAULT '',
        occupation TEXT NOT NULL DEFAULT 'Student',
        city TEXT NOT NULL DEFAULT '',
        monthlyBudget REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        darkMode INTEGER NOT NULL DEFAULT 0,
        startingBalance REAL NOT NULL DEFAULT 24680
      )
    ''');

    await db.execute('''
      CREATE TABLE friends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        amount REAL NOT NULL DEFAULT 0,
        type TEXT NOT NULL DEFAULT 'lent',
        note TEXT NOT NULL DEFAULT '',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.insert('profile', {
      'id': 1,
      'name': 'Nudge User',
      'age': 18,
      'phone': '',
      'email': '',
      'college': '',
      'occupation': 'Student',
      'city': '',
      'monthlyBudget': 0,
    });

    await db.insert('settings', {
      'id': 1,
      'darkMode': 0,
      'startingBalance': 24680,
    });
  }

  // ==========================================================
  // MIGRATION
  // ==========================================================

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // --------------------------------------------------------
    // Transactions
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'Other',
        amount REAL NOT NULL,
        type TEXT NOT NULL DEFAULT 'expense',
        note TEXT NOT NULL DEFAULT '',
        paymentMethod TEXT NOT NULL DEFAULT 'Cash',
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL DEFAULT '',
        updatedAt TEXT NOT NULL DEFAULT ''
      )
    ''');

    final transactionColumns =
        await db.rawQuery('PRAGMA table_info(transactions)');

    final existingTransactionColumns = transactionColumns
        .map((column) => column['name'] as String)
        .toSet();

    if (!existingTransactionColumns.contains('type')) {
      await db.execute('''
        ALTER TABLE transactions
        ADD COLUMN type TEXT NOT NULL DEFAULT 'expense'
      ''');
    }

    if (!existingTransactionColumns.contains('note')) {
      await db.execute('''
        ALTER TABLE transactions
        ADD COLUMN note TEXT NOT NULL DEFAULT ''
      ''');
    }

    if (!existingTransactionColumns.contains('paymentMethod')) {
      await db.execute('''
        ALTER TABLE transactions
        ADD COLUMN paymentMethod TEXT NOT NULL DEFAULT 'Cash'
      ''');
    }

    if (!existingTransactionColumns.contains('createdAt')) {
      await db.execute('''
        ALTER TABLE transactions
        ADD COLUMN createdAt TEXT NOT NULL DEFAULT ''
      ''');
    }

    if (!existingTransactionColumns.contains('updatedAt')) {
      await db.execute('''
        ALTER TABLE transactions
        ADD COLUMN updatedAt TEXT NOT NULL DEFAULT ''
      ''');
    }

    // --------------------------------------------------------
    // Profile
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL DEFAULT 'Nudge User',
        age INTEGER NOT NULL DEFAULT 18,
        phone TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL DEFAULT '',
        college TEXT NOT NULL DEFAULT '',
        occupation TEXT NOT NULL DEFAULT 'Student',
        city TEXT NOT NULL DEFAULT '',
        monthlyBudget REAL NOT NULL DEFAULT 0
      )
    ''');

    final profileColumns =
        await db.rawQuery('PRAGMA table_info(profile)');

    final existingProfileColumns =
        profileColumns.map((c) => c['name'] as String).toSet();

    if (!existingProfileColumns.contains('email')) {
      await db.execute('''
        ALTER TABLE profile
        ADD COLUMN email TEXT NOT NULL DEFAULT ''
      ''');
    }

    if (!existingProfileColumns.contains('college')) {
      await db.execute('''
        ALTER TABLE profile
        ADD COLUMN college TEXT NOT NULL DEFAULT ''
      ''');
    }

    if (!existingProfileColumns.contains('occupation')) {
      await db.execute('''
        ALTER TABLE profile
        ADD COLUMN occupation TEXT NOT NULL DEFAULT 'Student'
      ''');
    }

    if (!existingProfileColumns.contains('city')) {
      await db.execute('''
        ALTER TABLE profile
        ADD COLUMN city TEXT NOT NULL DEFAULT ''
      ''');
    }

    if (!existingProfileColumns.contains('monthlyBudget')) {
      await db.execute('''
        ALTER TABLE profile
        ADD COLUMN monthlyBudget REAL NOT NULL DEFAULT 0
      ''');
    }

    // --------------------------------------------------------
    // Settings
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY,
        darkMode INTEGER NOT NULL DEFAULT 0,
        startingBalance REAL NOT NULL DEFAULT 24680
      )
    ''');

    final settingsColumns =
        await db.rawQuery('PRAGMA table_info(settings)');

    final existingSettingsColumns =
        settingsColumns.map((c) => c['name'] as String).toSet();

    if (!existingSettingsColumns.contains('startingBalance')) {
      await db.execute('''
        ALTER TABLE settings
        ADD COLUMN startingBalance REAL NOT NULL DEFAULT 24680
      ''');
    }

    // --------------------------------------------------------
    // Friends
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS friends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        amount REAL NOT NULL DEFAULT 0,
        type TEXT NOT NULL DEFAULT 'lent',
        note TEXT NOT NULL DEFAULT '',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // --------------------------------------------------------
    // Default rows
    // --------------------------------------------------------

    final profile =
        await db.query('profile', where: 'id = 1', limit: 1);

    if (profile.isEmpty) {
      await db.insert('profile', {
        'id': 1,
        'name': 'Nudge User',
        'age': 18,
        'phone': '',
        'email': '',
        'college': '',
        'occupation': 'Student',
        'city': '',
        'monthlyBudget': 0,
      });
    }

    final settings =
        await db.query('settings', where: 'id = 1', limit: 1);

    if (settings.isEmpty) {
      await db.insert('settings', {
        'id': 1,
        'darkMode': 0,
        'startingBalance': 24680,
      });
    }
  }

  // ==========================================================
  // TRANSACTIONS
  // ==========================================================

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;

    return db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );
  }

  Future<int> addTransaction({
    required String title,
    required String category,
    required double amount,
    required String type,
    required String note,
    required String paymentMethod,
    required DateTime date,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return db.insert(
      'transactions',
      {
        'title': title,
        'category': category,
        'amount': amount,
        'type': type,
        'note': note,
        'paymentMethod': paymentMethod,
        'date': date.toIso8601String(),
        'createdAt': now,
        'updatedAt': now,
      },
    );
  }

  Future<int> updateTransaction({
    required int id,
    required String title,
    required String category,
    required double amount,
    required String type,
    required String note,
    required String paymentMethod,
  }) async {
    final db = await database;

    return db.update(
      'transactions',
      {
        'title': title,
        'category': category,
        'amount': amount,
        'type': type,
        'note': note,
        'paymentMethod': paymentMethod,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================================
  // PROFILE
  // ==========================================================

  Future<Map<String, dynamic>> getProfile() async {
    final db = await database;

    final result = await db.query(
      'profile',
      where: 'id = 1',
      limit: 1,
    );

    if (result.isEmpty) {
      final defaultProfile = {
        'id': 1,
        'name': 'Nudge User',
        'age': 18,
        'phone': '',
        'email': '',
        'college': '',
        'occupation': 'Student',
        'city': '',
        'monthlyBudget': 0.0,
      };

      await db.insert('profile', defaultProfile);

      return defaultProfile;
    }

    return result.first;
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required String phone,
    required String email,
    required String college,
    required String occupation,
    required String city,
    required double monthlyBudget,
  }) async {
    final db = await database;

    await db.update(
      'profile',
      {
        'name': name,
        'age': age,
        'phone': phone,
        'email': email,
        'college': college,
        'occupation': occupation,
        'city': city,
        'monthlyBudget': monthlyBudget,
      },
      where: 'id = 1',
    );
  }

  // ==========================================================
  // SETTINGS / BALANCE
  // ==========================================================

  Future<bool> getDarkMode() async {
    final db = await database;

    final result = await db.query(
      'settings',
      where: 'id = 1',
      limit: 1,
    );

    if (result.isEmpty) {
      await db.insert('settings', {
        'id': 1,
        'darkMode': 0,
        'startingBalance': 24680,
      });

      return false;
    }

    return (result.first['darkMode'] as num).toInt() == 1;
  }

  Future<void> setDarkMode(bool enabled) async {
    final db = await database;

    await db.update(
      'settings',
      {
        'darkMode': enabled ? 1 : 0,
      },
      where: 'id = 1',
    );
  }

  Future<double> getStartingBalance() async {
    final db = await database;

    final result = await db.query(
      'settings',
      where: 'id = 1',
      limit: 1,
    );

    if (result.isEmpty) {
      await db.insert('settings', {
        'id': 1,
        'darkMode': 0,
        'startingBalance': 24680,
      });

      return 24680;
    }

    return (result.first['startingBalance'] as num).toDouble();
  }

  Future<void> setStartingBalance(double amount) async {
    final db = await database;

    await db.update(
      'settings',
      {
        'startingBalance': amount,
      },
      where: 'id = 1',
    );
  }

  // ==========================================================
  // FRIENDS
  // ==========================================================

  Future<List<Map<String, dynamic>>> getFriends() async {
    final db = await database;

    return db.query(
      'friends',
      orderBy: 'createdAt DESC, id DESC',
    );
  }

  Future<int> addFriend({
    required String name,
    required String phone,
    required double amount,
    required String type,
    required String note,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return db.insert('friends', {
      'name': name,
      'phone': phone,
      'amount': amount,
      'type': type,
      'note': note,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<int> deleteFriend(int id) async {
    final db = await database;

    return db.delete(
      'friends',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}


