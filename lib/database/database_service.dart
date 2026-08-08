class NudgeDatabase 

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