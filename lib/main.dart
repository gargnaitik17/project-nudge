import 'services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'core/theme/app_theme.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await NudgeDatabase.instance.database;

  runApp(NudgeApp(database: database));
}

// ============================================================
// CONSTANTS
// ============================================================

const Color nudgePrimary = Color(0xFF5B5FEF);

const List<String> expenseCategories = [
  'Food & Drinks',
  'Travel',
  'Entertainment',
  'Shopping',
  'Education',
  'Bills',
  'Health',
  'Other',
];

const List<String> paymentMethods = [
  'Cash',
  'UPI',
  'Debit Card',
  'Credit Card',
  'Bank Transfer',
];

// ============================================================
// DATABASE
// ============================================================

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

// ============================================================
// AI-READY ANALYSIS ENGINE
// ============================================================

class NudgeApp extends StatefulWidget {
  final Database database;

  const NudgeApp({
    super.key,
    required this.database,
  });

  @override
  State<NudgeApp> createState() => _NudgeAppState();
}

class _NudgeAppState extends State<NudgeApp> {
  bool darkMode = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final value =
          await NudgeDatabase.instance.getDarkMode();

      if (!mounted) return;

      setState(() {
        darkMode = value;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    await NudgeDatabase.instance.setDarkMode(value);

    if (!mounted) return;

    setState(() {
      darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
  if (loading) {
  final isDark = darkMode;

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF171A1F),
      useMaterial3: true,
    ),
    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF171A1F) : Colors.white,
      body: Center(
        child: Image.asset(
  isDark
      ? 'assets/images/nudge_logo_dark.png'
      : 'assets/images/nudge_logo_light.png',
  width: 330,
  fit: BoxFit.contain,
),
        ),
      ),
    )
;
}
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nudge',
      themeMode:
          darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: nudgePrimary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor:
            const Color(0xFFF7F7FB),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF767AF5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor:
            const Color(0xFF101014),
      ),
      home: NudgeHomePage(
        database: widget.database,
        darkMode: darkMode,
        onDarkModeChanged: toggleDarkMode,
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class NudgeHomePage extends StatefulWidget {
  final Database database;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const NudgeHomePage({
    super.key,
    required this.database,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<NudgeHomePage> createState() => _NudgeHomePageState();
}

class _NudgeHomePageState extends State<NudgeHomePage> {
  int selectedIndex = 0;

  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> friends = [];

  Map<String, dynamic> profile = {
    'name': 'Nudge User',
    'age': 18,
    'phone': '',
    'email': '',
    'college': '',
    'occupation': 'Student',
    'city': '',
    'monthlyBudget': 0.0,
  };

  double startingBalance = 24680;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEverything();
  }

  // ==========================================================
  // LOAD
  // ==========================================================

  Future<void> loadEverything() async {
    try {
      final transactionData =
          await NudgeDatabase.instance.getTransactions();

      final profileData =
          await NudgeDatabase.instance.getProfile();

      final friendData =
          await NudgeDatabase.instance.getFriends();

      final balance =
          await NudgeDatabase.instance.getStartingBalance();

      if (!mounted) return;

      setState(() {
        transactions = transactionData;
        profile = profileData;
        friends = friendData;
        startingBalance = balance;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showSnackBar('Database error: $e');
    }
  }

  Future<void> reloadTransactions() async {
    final data =
        await NudgeDatabase.instance.getTransactions();

    if (!mounted) return;

    setState(() {
      transactions = data;
    });
  }

  Future<void> reloadFriends() async {
    final data =
        await NudgeDatabase.instance.getFriends();

    if (!mounted) return;

    setState(() {
      friends = data;
    });
  }

  // ==========================================================
  // CALCULATIONS
  // ==========================================================

  double get totalSpending {
    return transactions.fold<double>(
      0,
      (sum, transaction) {
        if (transaction['type'] != 'expense') {
          return sum;
        }

        return sum +
            (transaction['amount'] as num).toDouble();
      },
    );
  }

  double get totalIncome {
    return transactions.fold<double>(
      0,
      (sum, transaction) {
        if (transaction['type'] != 'income') {
          return sum;
        }

        return sum +
            (transaction['amount'] as num).toDouble();
      },
    );
  }

  double get availableBalance {
    return startingBalance +
        totalIncome -
        totalSpending;
  }

  double get todaySpending {
    final now = DateTime.now();

    return transactions.where((transaction) {
      if (transaction['type'] != 'expense') {
        return false;
      }

      final date = DateTime.tryParse(
        transaction['date']?.toString() ?? '',
      );

      if (date == null) return false;

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).fold<double>(
      0,
      (sum, transaction) =>
          sum +
          (transaction['amount'] as num).toDouble(),
    );
  }

  double get monthlySpending {
    final now = DateTime.now();

    return transactions.where((transaction) {
      if (transaction['type'] != 'expense') {
        return false;
      }

      final date = DateTime.tryParse(
        transaction['date']?.toString() ?? '',
      );

      if (date == null) return false;

      return date.year == now.year &&
          date.month == now.month;
    }).fold<double>(
      0,
      (sum, transaction) =>
          sum +
          (transaction['amount'] as num).toDouble(),
    );
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  // ==========================================================
  // ICON
  // ==========================================================

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Food & Drinks':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.directions_car_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Health':
        return Icons.medical_services_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            buildHome(),
            buildActivity(),
            buildFriends(),
            buildProfile(),
          ],
        ),
      ),
      floatingActionButton:
          selectedIndex == 0 || selectedIndex == 1
              ? FloatingActionButton.extended(
                  onPressed: addTransaction,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add transaction'),
                )
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long_rounded),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon:
                Icon(Icons.people_alt_rounded),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HOME
  // ==========================================================

  Widget buildHome() {
    final analysis = NudgeAIService.analyse(
      transactions: transactions,
      balance: availableBalance,
      monthlyBudget:
          (profile['monthlyBudget'] as num?)?.toDouble() ??
              0,
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            8,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: nudgePrimary,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good evening',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55),
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Nudge',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: showSettings,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: buildBalanceCard(),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: buildStatCard(
                    "Today's spending",
                    formatCurrency(todaySpending),
                    Icons.today_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildStatCard(
                    'This month',
                    formatCurrency(monthlySpending),
                    Icons.calendar_month_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: buildNudgeCard(analysis),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            10,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent transactions',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                  child: const Text('See all'),
                ),
              ],
            ),
          ),
        ),

        if (loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        else if (transactions.isEmpty)
          SliverToBoxAdapter(
            child: buildEmptyTransactions(),
          )
        else
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.builder(
              itemCount: transactions.length > 5
                  ? 5
                  : transactions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10),
                  child: buildTransactionTile(
                    transactions[index],
                  ),
                );
              },
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // ==========================================================
  // BALANCE CARD
  // ==========================================================

  Widget buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5B5FEF),
            Color(0xFF767AF5),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Available balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                onPressed: editBalance,
                icon: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Edit balance',
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            formatCurrency(availableBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.trending_down_rounded,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${formatCurrency(monthlySpending)} spent this month',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // NUDGE
  // ==========================================================

  Widget buildNudgeCard(NudgeAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: nudgePrimary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: nudgePrimary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            '🧠',
            style: TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nudge says',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  analysis.message,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.70),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  Widget buildStatCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: nudgePrimary,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TRANSACTION TILE
  // ==========================================================

  Widget buildTransactionTile(
    Map<String, dynamic> transaction,
  ) {
    final title =
        transaction['title']?.toString() ?? '';

    final category =
        transaction['category']?.toString() ?? 'Other';

    final amount =
        (transaction['amount'] as num).toDouble();

    final type =
        transaction['type']?.toString() ?? 'expense';

    final isIncome = type == 'income';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () =>
          editTransaction(transaction),
      onLongPress: () =>
          showTransactionMenu(transaction),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color:
                    nudgePrimary.withValues(alpha: 0.10),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_upward_rounded
                    : categoryIcon(category),
                color:
                    isIncome ? Colors.green : nudgePrimary,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isIncome
                        ? 'Income • ${transaction['paymentMethod'] ?? 'Cash'}'
                        : '$category • ${transaction['paymentMethod'] ?? 'Cash'}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${formatCurrency(amount)}',
              style: TextStyle(
                color: isIncome ? Colors.green : null,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

  Widget buildEmptyTransactions() {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Text(
            '💸',
            style: TextStyle(fontSize: 42),
          ),
          SizedBox(height: 12),
          Text(
            'No spending yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add your first transaction and let Nudge keep track.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ACTIVITY
  // ==========================================================

  Widget buildActivity() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            25,
            20,
            20,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${transactions.length} transactions',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (transactions.isEmpty)
          SliverFillRemaining(
            child: buildEmptyTransactions(),
          )
        else
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10),
                  child: buildTransactionTile(
                    transactions[index],
                  ),
                );
              },
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // ==========================================================
  // FRIENDS
  // ==========================================================

  Widget buildFriends() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            25,
            20,
            10,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Friends',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Keep track of money between friends.',
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: addFriend,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
        ),
        if (friends.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_alt_rounded,
                      size: 64,
                      color: nudgePrimary,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No friends added',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add someone you lent money to or borrowed money from.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10),
                  child: buildFriendTile(
                    friends[index],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget buildFriendTile(
    Map<String, dynamic> friend,
  ) {
    final name =
        friend['name']?.toString() ?? '';

    final amount =
        (friend['amount'] as num).toDouble();

    final type =
        friend['type']?.toString() ?? 'lent';

    final lent = type == 'lent';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              nudgePrimary.withValues(alpha: 0.12),
          child: Text(
            name.isEmpty
                ? '?'
                : name[0].toUpperCase(),
            style: const TextStyle(
              color: nudgePrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          lent ? 'They owe you' : 'You owe them',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCurrency(amount),
              style: TextStyle(
                color:
                    lent ? Colors.green : Colors.red,
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton(
              onPressed: () async {
                await NudgeDatabase.instance
                    .deleteFriend(friend['id'] as int);

                await reloadFriends();
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PROFILE
  // ==========================================================

  Widget buildProfile() {
    final name =
        profile['name']?.toString() ?? 'Nudge User';

    final age =
        profile['age']?.toString() ?? '18';

    final phone =
        profile['phone']?.toString() ?? '';

    final email =
        profile['email']?.toString() ?? '';

    final college =
        profile['college']?.toString() ?? '';

    final occupation =
        profile['occupation']?.toString() ?? 'Student';

    final city =
        profile['city']?.toString() ?? '';

    final budget =
        (profile['monthlyBudget'] as num?)
                ?.toDouble() ??
            0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),

        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 20),

        CircleAvatar(
          radius: 42,
          backgroundColor: nudgePrimary,
          child: Text(
            name.trim().isEmpty
                ? 'N'
                : name.trim()[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 14),

        Center(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 25),

        Card(
          child: Column(
            children: [
              profileTile(
                Icons.person_outline,
                'Name',
                name,
              ),
              profileTile(
                Icons.cake_outlined,
                'Age',
                age,
              ),
              profileTile(
                Icons.phone_outlined,
                'Phone',
                phone.isEmpty ? 'Not added' : phone,
              ),
              profileTile(
                Icons.email_outlined,
                'Email',
                email.isEmpty ? 'Not added' : email,
              ),
              profileTile(
                Icons.school_outlined,
                'College',
                college.isEmpty
                    ? 'Not added'
                    : college,
              ),
              profileTile(
                Icons.work_outline_rounded,
                'Occupation',
                occupation,
              ),
              profileTile(
                Icons.location_on_outlined,
                'City',
                city.isEmpty ? 'Not added' : city,
              ),
              profileTile(
                Icons.account_balance_wallet_outlined,
                'Monthly budget',
                budget <= 0
                    ? 'Not set'
                    : formatCurrency(budget),
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_rounded,
                ),
                title: const Text(
                  'Edit profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: editProfile,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.account_balance_wallet_outlined,
            ),
            title: const Text(
              'Starting balance',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              formatCurrency(startingBalance),
            ),
            trailing: const Icon(
              Icons.edit_rounded,
            ),
            onTap: editBalance,
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: SwitchListTile(
            secondary: const Icon(
              Icons.dark_mode_outlined,
            ),
            title: const Text(
              'Dark mode',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            value: widget.darkMode,
            onChanged:
                widget.onDarkModeChanged,
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget profileTile(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  // ==========================================================
  // EDIT PROFILE
  // ==========================================================

  Future<void> editProfile() async {
    final nameController = TextEditingController(
      text: profile['name']?.toString() ?? '',
    );

    final ageController = TextEditingController(
      text: profile['age']?.toString() ?? '18',
    );

    final phoneController = TextEditingController(
      text: profile['phone']?.toString() ?? '',
    );

    final emailController = TextEditingController(
      text: profile['email']?.toString() ?? '',
    );

    final collegeController = TextEditingController(
      text: profile['college']?.toString() ?? '',
    );

    final cityController = TextEditingController(
      text: profile['city']?.toString() ?? '',
    );

    final budgetController = TextEditingController(
      text: ((profile['monthlyBudget'] as num?)
                  ?.toDouble() ??
              0)
          .toStringAsFixed(0),
    );

   String occupation =
    profile['occupation']?.toString().trim() ?? 'Student';

const validOccupations = [
  'Student',
  'Working',
  'Business',
  'Other',
];

if (!validOccupations.contains(occupation)) {
  final normalized = occupation.toLowerCase();

  if (normalized == 'student') {
    occupation = 'Student';
  } else if (normalized == 'working') {
    occupation = 'Working';
  } else if (normalized == 'business') {
    occupation = 'Business';
  } else {
    occupation = 'Other';
  }
}

    bool saving = false;

    try {
      final result =
          await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (
              context,
              setSheetState,
            ) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  MediaQuery.of(sheetContext)
                          .viewInsets
                          .bottom +
                      25,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit profile',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: nameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration:
                            const InputDecoration(
                          labelText: 'Name',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: ageController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          labelText: 'Age',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: phoneController,
                        keyboardType:
                            TextInputType.phone,
                        decoration:
                            const InputDecoration(
                          labelText: 'Phone number',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(
                          labelText: 'Email',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: collegeController,
                        decoration:
                            const InputDecoration(
                          labelText: 'College',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: occupation,
                        decoration:
                            const InputDecoration(
                          labelText: 'Occupation',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Student',
                            child: Text('Student'),
                          ),
                          DropdownMenuItem(
                            value: 'Working',
                            child: Text('Working'),
                          ),
                          DropdownMenuItem(
                            value: 'Business',
                            child: Text('Business'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setSheetState(() {
                                  occupation = value;
                                });
                              },
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: cityController,
                        decoration:
                            const InputDecoration(
                          labelText: 'City',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: budgetController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          prefixText: '₹ ',
                          labelText:
                              'Monthly budget',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  final name =
                                      nameController
                                          .text
                                          .trim();

                                  if (name.isEmpty) {
                                    ScaffoldMessenger
                                        .of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter your name.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final age =
                                      int.tryParse(
                                            ageController
                                                .text
                                                .trim(),
                                          ) ??
                                          18;

                                  final budget =
                                      double.tryParse(
                                            budgetController
                                                .text
                                                .trim(),
                                          ) ??
                                          0;

                                  setSheetState(() {
                                    saving = true;
                                  });

                                  try {
                                    await NudgeDatabase
                                        .instance
                                        .updateProfile(
                                      name: name,
                                      age: age,
                                      phone:
                                          phoneController
                                              .text
                                              .trim(),
                                      email:
                                          emailController
                                              .text
                                              .trim(),
                                      college:
                                          collegeController
                                              .text
                                              .trim(),
                                      occupation:
                                          occupation,
                                      city:
                                          cityController
                                              .text
                                              .trim(),
                                      monthlyBudget:
                                          budget,
                                    );

                                    if (!sheetContext
                                        .mounted) {
                                      return;
                                    }

                                    Navigator.pop(
                                      sheetContext,
                                      true,
                                    );
                                  } catch (e) {
                                    setSheetState(() {
                                      saving = false;
                                    });

                                    if (!sheetContext
                                        .mounted) {
                                      return;
                                    }

                                    ScaffoldMessenger
                                        .of(sheetContext)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Could not save profile: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 13,
                            ),
                            child: saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save profile',
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      if (result == true) {
        final updated =
            await NudgeDatabase.instance
                .getProfile();

        if (!mounted) return;

        setState(() {
          profile = updated;
        });

        showSnackBar('Profile updated ✨');
      }
    } finally {
      nameController.dispose();
      ageController.dispose();
      phoneController.dispose();
      emailController.dispose();
      collegeController.dispose();
      cityController.dispose();
      budgetController.dispose();
    }
  }

  // ==========================================================
  // EDIT BALANCE
  // ==========================================================

  Future<void> editBalance() async {
    final controller = TextEditingController(
      text: startingBalance.toStringAsFixed(0),
    );

    try {
      final result =
          await showDialog<double>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Edit starting balance',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                prefixText: '₹ ',
                labelText: 'Balance',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final amount = double.tryParse(
                    controller.text.trim(),
                  );

                  if (amount == null ||
                      amount < 0) {
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    amount,
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (result == null) return;

      await NudgeDatabase.instance
          .setStartingBalance(result);

      if (!mounted) return;

      setState(() {
        startingBalance = result;
      });

      showSnackBar('Balance updated 💰');
    } finally {
      controller.dispose();
    }
  }

  // ==========================================================
  // ADD TRANSACTION
  // ==========================================================

  Future<void> addTransaction() async {
    final result =
        await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return const AddTransactionSheet();
      },
    );

    if (!mounted) return;

    if (result == true) {
      await reloadTransactions();

      if (!mounted) return;

      showSnackBar('Transaction added 💸');
    }
  }

  // ==========================================================
  // EDIT TRANSACTION
  // ==========================================================

  Future<void> editTransaction(
    Map<String, dynamic> transaction,
  ) async {
    final result =
        await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return EditTransactionSheet(
          transaction: transaction,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await reloadTransactions();

      if (!mounted) return;

      showSnackBar('Transaction updated ✨');
    }
  }

  // ==========================================================
  // DELETE TRANSACTION
  // ==========================================================

  Future<void> deleteTransaction(
    Map<String, dynamic> transaction,
  ) async {
    final title =
        transaction['title']?.toString() ?? '';

    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete transaction?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Delete "$title" from your transaction history?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }

    await NudgeDatabase.instance.deleteTransaction(
      transaction['id'] as int,
    );

    await reloadTransactions();

    if (!mounted) return;

    showSnackBar('Transaction deleted 🗑️');
  }

  // ==========================================================
  // TRANSACTION MENU
  // ==========================================================

  void showTransactionMenu(
    Map<String, dynamic> transaction,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.edit_rounded),
                title: const Text(
                  'Edit transaction',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);

                  Future.microtask(() {
                    if (mounted) {
                      editTransaction(
                        transaction,
                      );
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'Delete transaction',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);

                  Future.microtask(() {
                    if (mounted) {
                      deleteTransaction(
                        transaction,
                      );
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // ADD FRIEND
  // ==========================================================

  Future<void> addFriend() async {
    final nameController =
        TextEditingController();

    final phoneController =
        TextEditingController();

    final amountController =
        TextEditingController();

    final noteController =
        TextEditingController();

    String type = 'lent';

    try {
      final result =
          await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (
              context,
              setSheetState,
            ) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  MediaQuery.of(sheetContext)
                          .viewInsets
                          .bottom +
                      25,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add friend',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),

                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'lent',
                            label: Text('I lent'),
                            icon: Icon(
                              Icons
                                  .arrow_upward_rounded,
                            ),
                          ),
                          ButtonSegment(
                            value: 'borrowed',
                            label:
                                Text('I borrowed'),
                            icon: Icon(
                              Icons
                                  .arrow_downward_rounded,
                            ),
                          ),
                        ],
                        selected: {type},
                        onSelectionChanged:
                            (value) {
                          setSheetState(() {
                            type = value.first;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: nameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration:
                            const InputDecoration(
                          labelText: 'Friend name',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: phoneController,
                        keyboardType:
                            TextInputType.phone,
                        decoration:
                            const InputDecoration(
                          labelText: 'Phone',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          prefixText: '₹ ',
                          labelText: 'Amount',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        decoration:
                            const InputDecoration(
                          labelText: 'Note',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            final name =
                                nameController.text
                                    .trim();

                            final amount =
                                double.tryParse(
                                  amountController
                                      .text
                                      .trim(),
                                );

                            if (name.isEmpty ||
                                amount == null ||
                                amount <= 0) {
                              return;
                            }

                            await NudgeDatabase
                                .instance
                                .addFriend(
                              name: name,
                              phone:
                                  phoneController
                                      .text
                                      .trim(),
                              amount: amount,
                              type: type,
                              note:
                                  noteController
                                      .text
                                      .trim(),
                            );

                            if (!sheetContext
                                .mounted) {
                              return;
                            }

                            Navigator.pop(
                              sheetContext,
                              true,
                            );
                          },
                          child: const Text(
                            'Save friend',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      if (result == true) {
        await reloadFriends();

        if (!mounted) return;

        showSnackBar('Friend added 🤝');
      }
    } finally {
      nameController.dispose();
      phoneController.dispose();
      amountController.dispose();
      noteController.dispose();
    }
  }

  // ==========================================================
  // SETTINGS
  // ==========================================================

  void showSettings() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(
                  Icons.dark_mode_outlined,
                ),
                title:
                    const Text('Dark mode'),
                value: widget.darkMode,
                onChanged: (value) {
                  widget.onDarkModeChanged(value);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet_outlined,
                ),
                title: const Text(
                  'Edit balance',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);

                  Future.microtask(() {
                    if (mounted) {
                      editBalance();
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                ),
                title:
                    const Text('Profile'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  setState(() {
                    selectedIndex = 3;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// ADD TRANSACTION SHEET
// ============================================================

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({
    super.key,
  });

  @override
  State<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState
    extends State<AddTransactionSheet> {
  final amountController =
      TextEditingController();

  final titleController =
      TextEditingController();

  final noteController =
      TextEditingController();

  String selectedCategory =
      'Food & Drinks';

  String selectedType = 'expense';

  String selectedPaymentMethod = 'Cash';

  bool saving = false;

  bool get isIncome => selectedType == 'income';

  @override
  void dispose() {
    amountController.dispose();
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveTransaction() async {
    if (saving) return;

    final title =
        titleController.text.trim();

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    final note =
        noteController.text.trim();

    if (title.isEmpty) {
      showError('Please enter a title.');
      return;
    }

    if (amount == null || amount <= 0) {
      showError('Please enter a valid amount.');
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final id =
          await NudgeDatabase.instance
              .addTransaction(
        title: title,
        category:
            isIncome ? 'Income' : selectedCategory,
        amount: amount,
        type: selectedType,
        note: note,
        paymentMethod: selectedPaymentMethod,
        date: DateTime.now(),
      );

      if (id <= 0) {
        throw Exception(
          'Invalid transaction ID.',
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showError(
        'Could not save transaction.\n$e',
      );
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context)
                .viewInsets
                .bottom +
            24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Add transaction',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 18),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Expense'),
                  icon: Icon(
                    Icons.arrow_downward_rounded,
                  ),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Income'),
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                  ),
                ),
              ],
              selected: {selectedType},
              onSelectionChanged:
                  saving
                      ? null
                      : (value) {
                          setState(() {
                            selectedType =
                                value.first;
                          });
                        },
            ),

            const SizedBox(height: 14),

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                prefixText: '₹ ',
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: titleController,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration:
                  InputDecoration(
                labelText: isIncome
                    ? 'Income source'
                    : 'What did you spend on?',
                hintText: isIncome
                    ? 'e.g. Tuition'
                    : 'e.g. Coffee',
                border: const OutlineInputBorder(),
              ),
            ),

            // IMPORTANT:
            // Income DOES NOT show category.
            if (!isIncome) ...[
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration:
                    const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    expenseCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: saving
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          selectedCategory =
                              value;
                        });
                      },
              ),
            ],

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue:
                  selectedPaymentMethod,
              decoration:
                  const InputDecoration(
                labelText: 'Payment method',
                border: OutlineInputBorder(),
              ),
              items:
                  paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: saving
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        selectedPaymentMethod =
                            value;
                      });
                    },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: noteController,
              maxLines: 2,
              decoration:
                  const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    saving ? null : saveTransaction,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save transaction',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EDIT TRANSACTION SHEET
// ============================================================

class EditTransactionSheet
    extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const EditTransactionSheet({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionSheet>
      createState() =>
          _EditTransactionSheetState();
}

class _EditTransactionSheetState
    extends State<EditTransactionSheet> {
  late final TextEditingController amountController;
  late final TextEditingController titleController;
  late final TextEditingController noteController;

  late String selectedCategory;
  late String selectedType;
  late String selectedPaymentMethod;

  bool saving = false;

  bool get isIncome => selectedType == 'income';

  @override
  void initState() {
    super.initState();

    amountController =
        TextEditingController(
      text: ((widget.transaction['amount']
                      as num?)
                  ?.toDouble() ??
              0)
          .toStringAsFixed(2),
    );

    titleController =
        TextEditingController(
      text:
          widget.transaction['title']
                  ?.toString() ??
              '',
    );

    noteController =
        TextEditingController(
      text:
          widget.transaction['note']
                  ?.toString() ??
              '',
    );

    selectedCategory =
        widget.transaction['category']
                ?.toString() ??
            'Other';

    if (!expenseCategories.contains(
      selectedCategory,
    )) {
      selectedCategory = 'Other';
    }

    selectedType =
        widget.transaction['type']
                ?.toString() ??
            'expense';

    selectedPaymentMethod =
        widget.transaction['paymentMethod']
                ?.toString() ??
            'Cash';

    if (!paymentMethods.contains(
      selectedPaymentMethod,
    )) {
      selectedPaymentMethod = 'Cash';
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> updateTransaction() async {
    if (saving) return;

    final title =
        titleController.text.trim();

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (title.isEmpty) {
      showError('Please enter a title.');
      return;
    }

    if (amount == null || amount <= 0) {
      showError('Please enter a valid amount.');
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await NudgeDatabase.instance
          .updateTransaction(
        id: widget.transaction['id'] as int,
        title: title,
        category:
            isIncome ? 'Income' : selectedCategory,
        amount: amount,
        type: selectedType,
        note: noteController.text.trim(),
        paymentMethod: selectedPaymentMethod,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showError(
        'Could not update transaction.\n$e',
      );
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context)
                .viewInsets
                .bottom +
            24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit transaction',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 18),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Expense'),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Income'),
                ),
              ],
              selected: {selectedType},
              onSelectionChanged:
                  saving
                      ? null
                      : (value) {
                          setState(() {
                            selectedType =
                                value.first;

                            if (selectedType ==
                                'income') {
                              selectedCategory =
                                  'Other';
                            }
                          });
                        },
            ),

            const SizedBox(height: 14),

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                prefixText: '₹ ',
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: titleController,
              decoration:
                  InputDecoration(
                labelText: isIncome
                    ? 'Income source'
                    : 'What did you spend on?',
                border: const OutlineInputBorder(),
              ),
            ),

            // Category is ONLY for expenses.
            if (!isIncome) ...[
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration:
                    const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    expenseCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: saving
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          selectedCategory =
                              value;
                        });
                      },
              ),
            ],

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue:
                  selectedPaymentMethod,
              decoration:
                  const InputDecoration(
                labelText: 'Payment method',
                border: OutlineInputBorder(),
              ),
              items:
                  paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: saving
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        selectedPaymentMethod =
                            value;
                      });
                    },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: noteController,
              maxLines: 2,
              decoration:
                  const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    saving
                        ? null
                        : updateTransaction,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save changes',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
