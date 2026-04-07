import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('farmtrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB, onOpen: _seedData);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE animals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL,
        color TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE batches (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animals(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        batch_id TEXT,
        animal_id TEXT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        animal_id TEXT,
        batch_id TEXT,
        frequency TEXT NOT NULL,
        next_due TEXT NOT NULL,
        last_done TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedData(Database db) async {
    // Only seed if empty
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM animals'),
    );
    if (count != null && count > 0) return;

    final now = DateTime.now().toIso8601String();
    final today = DateTime.now();
    String d(int days) => today.subtract(Duration(days: days))
        .toIso8601String().substring(0, 10);
    String f(int days) => today.add(Duration(days: days))
        .toIso8601String().substring(0, 10);
    final todayStr = today.toIso8601String().substring(0, 10);

    // Animals
    final animals = [
      {'id': 'a1', 'name': 'Pig', 'emoji': '🐷', 'color': 'pig', 'sort_order': 0, 'created_at': now},
      {'id': 'a2', 'name': 'Chicken', 'emoji': '🐔', 'color': 'chicken', 'sort_order': 1, 'created_at': now},
      {'id': 'a3', 'name': 'Goat', 'emoji': '🐐', 'color': 'goat', 'sort_order': 2, 'created_at': now},
      {'id': 'a4', 'name': 'Cow', 'emoji': '🐄', 'color': 'cow', 'sort_order': 3, 'created_at': now},
    ];
    for (final a in animals) await db.insert('animals', a);

    // Batches
    final batches = [
      {'id': 'b1', 'animal_id': 'a1', 'name': 'Pig Batch A', 'quantity': 12, 'start_date': d(90), 'status': 'active', 'notes': 'Landrace breed from Digos supplier', 'created_at': now},
      {'id': 'b2', 'animal_id': 'a1', 'name': 'Pig Batch B', 'quantity': 8, 'start_date': d(45), 'status': 'active', 'notes': 'Native breed', 'created_at': now},
      {'id': 'b3', 'animal_id': 'a2', 'name': 'Broiler Flock 1', 'quantity': 150, 'start_date': d(120), 'status': 'sold', 'notes': 'First broiler cycle — successful', 'created_at': now},
      {'id': 'b4', 'animal_id': 'a2', 'name': 'Layer Flock A', 'quantity': 80, 'start_date': d(60), 'status': 'active', 'notes': 'Rhode Island Red layers', 'created_at': now},
      {'id': 'b5', 'animal_id': 'a3', 'name': 'Goat Herd 1', 'quantity': 6, 'start_date': d(180), 'status': 'active', 'notes': 'Anglo-Nubian × Local', 'created_at': now},
    ];
    for (final b in batches) await db.insert('batches', b);

    // Transactions
    final txns = [
      {'id': 't1', 'batch_id': 'b1', 'animal_id': 'a1', 'type': 'expense', 'amount': 5400.0, 'date': d(80), 'category': 'feed', 'notes': 'Starter feeds 120 kg', 'created_at': now},
      {'id': 't2', 'batch_id': 'b1', 'animal_id': 'a1', 'type': 'expense', 'amount': 800.0, 'date': d(60), 'category': 'medicine', 'notes': 'Dewormer + vitamins', 'created_at': now},
      {'id': 't3', 'batch_id': 'b1', 'animal_id': 'a1', 'type': 'expense', 'amount': 3200.0, 'date': d(30), 'category': 'feed', 'notes': 'Grower feeds 80 kg', 'created_at': now},
      {'id': 't4', 'batch_id': 'b1', 'animal_id': 'a1', 'type': 'income', 'amount': 7200.0, 'date': d(10), 'category': 'sales', 'notes': 'Sold 4 pigs to Davao market', 'created_at': now},
      {'id': 't5', 'batch_id': 'b2', 'animal_id': 'a1', 'type': 'expense', 'amount': 3200.0, 'date': d(40), 'category': 'feed', 'notes': 'Starter feeds', 'created_at': now},
      {'id': 't6', 'batch_id': 'b2', 'animal_id': 'a1', 'type': 'expense', 'amount': 500.0, 'date': d(20), 'category': 'medicine', 'notes': 'Hog cholera vaccine', 'created_at': now},
      {'id': 't7', 'batch_id': 'b3', 'animal_id': 'a2', 'type': 'expense', 'amount': 4500.0, 'date': d(110), 'category': 'feed', 'notes': 'Broiler starter crumbles', 'created_at': now},
      {'id': 't8', 'batch_id': 'b3', 'animal_id': 'a2', 'type': 'expense', 'amount': 600.0, 'date': d(100), 'category': 'medicine', 'notes': 'Newcastle + IBD vaccine', 'created_at': now},
      {'id': 't9', 'batch_id': 'b3', 'animal_id': 'a2', 'type': 'expense', 'amount': 300.0, 'date': d(90), 'category': 'labor', 'notes': 'Processing labor', 'created_at': now},
      {'id': 't10', 'batch_id': 'b3', 'animal_id': 'a2', 'type': 'income', 'amount': 11250.0, 'date': d(85), 'category': 'sales', 'notes': 'Sold 150 broilers live weight', 'created_at': now},
      {'id': 't11', 'batch_id': 'b4', 'animal_id': 'a2', 'type': 'expense', 'amount': 2800.0, 'date': d(50), 'category': 'feed', 'notes': 'Layer mash 70 kg', 'created_at': now},
      {'id': 't12', 'batch_id': 'b4', 'animal_id': 'a2', 'type': 'income', 'amount': 1800.0, 'date': d(14), 'category': 'sales', 'notes': 'Egg sales — Week 1', 'created_at': now},
      {'id': 't13', 'batch_id': 'b4', 'animal_id': 'a2', 'type': 'income', 'amount': 1920.0, 'date': d(7), 'category': 'sales', 'notes': 'Egg sales — Week 2', 'created_at': now},
      {'id': 't14', 'batch_id': 'b5', 'animal_id': 'a3', 'type': 'expense', 'amount': 1200.0, 'date': d(90), 'category': 'feed', 'notes': 'Hay bales + mineral lick', 'created_at': now},
      {'id': 't15', 'batch_id': 'b5', 'animal_id': 'a3', 'type': 'expense', 'amount': 400.0, 'date': d(60), 'category': 'medicine', 'notes': 'Albendazole dewormer', 'created_at': now},
      {'id': 't16', 'batch_id': 'b5', 'animal_id': 'a3', 'type': 'income', 'amount': 4800.0, 'date': d(5), 'category': 'sales', 'notes': 'Sold 2 adult goats', 'created_at': now},
    ];
    for (final t in txns) await db.insert('transactions', t);

    // Tasks
    final tasks = [
      {'id': 'tk1', 'title': 'Feed Pig Batch A', 'animal_id': 'a1', 'batch_id': 'b1', 'frequency': 'daily', 'next_due': todayStr, 'last_done': null, 'notes': 'Morning & afternoon — 2kg each', 'created_at': now},
      {'id': 'tk2', 'title': 'Feed Pig Batch B', 'animal_id': 'a1', 'batch_id': 'b2', 'frequency': 'daily', 'next_due': todayStr, 'last_done': null, 'notes': '1.5 kg morning', 'created_at': now},
      {'id': 'tk3', 'title': 'Collect Eggs — Layer Flock', 'animal_id': 'a2', 'batch_id': 'b4', 'frequency': 'daily', 'next_due': todayStr, 'last_done': null, 'notes': 'Check for cracked eggs', 'created_at': now},
      {'id': 'tk4', 'title': 'Vaccinate Chickens', 'animal_id': 'a2', 'batch_id': null, 'frequency': 'monthly', 'next_due': f(3), 'last_done': null, 'notes': 'Newcastle + IBD booster', 'created_at': now},
      {'id': 'tk5', 'title': 'Deworm Goats', 'animal_id': 'a3', 'batch_id': 'b5', 'frequency': 'monthly', 'next_due': f(7), 'last_done': null, 'notes': 'Use Albendazole 10ml per goat', 'created_at': now},
      {'id': 'tk6', 'title': 'Weigh Pig Batch A', 'animal_id': 'a1', 'batch_id': 'b1', 'frequency': 'weekly', 'next_due': f(2), 'last_done': null, 'notes': 'Record weights in notes', 'created_at': now},
      {'id': 'tk7', 'title': 'Clean & Disinfect Pig Pens', 'animal_id': 'a1', 'batch_id': null, 'frequency': 'weekly', 'next_due': d(1), 'last_done': null, 'notes': 'Bleach solution 1:10 ratio', 'created_at': now},
    ];
    for (final t in tasks) {
      final cleaned = Map<String, dynamic>.from(t)..removeWhere((k, v) => v == null);
      await db.insert('tasks', cleaned);
    }

    // Default settings
    await db.insert('settings', {'key': 'pin', 'value': '1234'});
    await db.insert('settings', {'key': 'farm_name', 'value': 'My Farm'});
    await db.insert('settings', {'key': 'currency', 'value': '₱'});
    await db.insert('settings', {'key': 'notifications', 'value': 'true'});
  }

  // ─── ANIMALS ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAnimals() async {
    final db = await database;
    return db.query('animals', orderBy: 'sort_order ASC, created_at ASC');
  }

  Future<void> insertAnimal(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('animals', data);
  }

  Future<void> deleteAnimal(String id) async {
    final db = await database;
    await db.delete('animals', where: 'id = ?', whereArgs: [id]);
  }

  // ─── BATCHES ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getBatches({String? animalId}) async {
    final db = await database;
    if (animalId != null) {
      return db.query('batches', where: 'animal_id = ?', whereArgs: [animalId], orderBy: 'created_at DESC');
    }
    return db.query('batches', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getBatch(String id) async {
    final db = await database;
    final results = await db.query('batches', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insertBatch(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('batches', data);
  }

  Future<void> updateBatch(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('batches', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteBatch(String id) async {
    final db = await database;
    await db.delete('batches', where: 'id = ?', whereArgs: [id]);
    await db.delete('transactions', where: 'batch_id = ?', whereArgs: [id]);
  }

  // ─── TRANSACTIONS ──────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getTransactions({
    String? batchId, String? animalId, String? type, String? category,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];
    if (batchId != null) { conditions.add('batch_id = ?'); args.add(batchId); }
    if (animalId != null) { conditions.add('animal_id = ?'); args.add(animalId); }
    if (type != null) { conditions.add('type = ?'); args.add(type); }
    if (category != null) { conditions.add('category = ?'); args.add(category); }
    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    return db.query('transactions', where: where, whereArgs: args.isNotEmpty ? args : null, orderBy: 'date DESC, created_at DESC');
  }

  Future<void> insertTransaction(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('transactions', data);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getTransactionSummary({String? batchId, String? animalId}) async {
    final txns = await getTransactions(batchId: batchId, animalId: animalId);
    double income = 0, expense = 0;
    for (final t in txns) {
      if (t['type'] == 'income') income += (t['amount'] as num).toDouble();
      else expense += (t['amount'] as num).toDouble();
    }
    return {'income': income, 'expense': expense, 'profit': income - expense};
  }

  Future<Map<String, double>> getTotalSummary() async {
    final db = await database;
    final incomeResult = await db.rawQuery('SELECT SUM(amount) as total FROM transactions WHERE type = ?', ['income']);
    final expenseResult = await db.rawQuery('SELECT SUM(amount) as total FROM transactions WHERE type = ?', ['expense']);
    final income = (incomeResult.first['total'] as num?)?.toDouble() ?? 0;
    final expense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0;
    return {'income': income, 'expense': expense, 'profit': income - expense};
  }

  Future<Map<String, double>> getExpenseByCategory() async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions WHERE type = ? GROUP BY category',
      ['expense'],
    );
    return {for (final r in results) r['category'] as String: (r['total'] as num).toDouble()};
  }

  Future<List<Map<String, dynamic>>> getMonthlyData(int months) async {
    final db = await database;
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int i = months - 1; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i);
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      final income = Sqflite.firstIntValue(
        await db.rawQuery("SELECT SUM(amount) FROM transactions WHERE type='income' AND date LIKE '$key%'"),
      ) ?? 0;
      final expense = Sqflite.firstIntValue(
        await db.rawQuery("SELECT SUM(amount) FROM transactions WHERE type='expense' AND date LIKE '$key%'"),
      ) ?? 0;
      result.add({'month': key, 'label': _monthLabel(dt.month), 'income': income.toDouble(), 'expense': expense.toDouble()});
    }
    return result;
  }

  String _monthLabel(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }

  // ─── TASKS ─────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getTasks({String? animalId}) async {
    final db = await database;
    if (animalId != null) {
      return db.query('tasks', where: 'animal_id = ?', whereArgs: [animalId], orderBy: 'next_due ASC');
    }
    return db.query('tasks', orderBy: 'next_due ASC');
  }

  Future<void> insertTask(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('tasks', data);
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('tasks', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ─── SETTINGS ──────────────────────────────────────────────
  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return result.isNotEmpty ? result.first['value'] as String? : null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('batches');
    await db.delete('animals');
    await db.delete('tasks');
    await db.delete('settings');
    _database = null;
  }

  Future<String> exportCSV() async {
    final db = await database;
    final txns = await db.rawQuery('''
      SELECT t.date, a.name as animal, b.name as batch, t.type, t.category, t.amount, t.notes
      FROM transactions t
      LEFT JOIN batches b ON t.batch_id = b.id
      LEFT JOIN animals a ON t.animal_id = a.id
      ORDER BY t.date DESC
    ''');
    final lines = ['Date,Animal,Batch,Type,Category,Amount,Notes'];
    for (final r in txns) {
      lines.add([
        r['date'], r['animal'] ?? '', r['batch'] ?? '',
        r['type'], r['category'], r['amount'], '"${r['notes'] ?? ''}"',
      ].join(','));
    }
    return lines.join('\n');
  }
}
