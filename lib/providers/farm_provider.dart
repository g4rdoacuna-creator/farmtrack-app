import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/database.dart';

const _uuid = Uuid();

class FarmProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _animals = [];
  List<Map<String, dynamic>> _batches = [];
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _tasks = [];
  Map<String, double> _totalSummary = {'income': 0, 'expense': 0, 'profit': 0};
  Map<String, double> _expenseByCategory = {};
  List<Map<String, dynamic>> _monthlyData = [];

  String _farmName = 'My Farm';
  String _currency = '₱';
  bool _isLoading = true;

  // Getters
  List<Map<String, dynamic>> get animals => _animals;
  List<Map<String, dynamic>> get batches => _batches;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get tasks => _tasks;
  Map<String, double> get totalSummary => _totalSummary;
  Map<String, double> get expenseByCategory => _expenseByCategory;
  List<Map<String, dynamic>> get monthlyData => _monthlyData;
  String get farmName => _farmName;
  String get currency => _currency;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> get upcomingTasks {
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));
    return _tasks.where((t) {
      final due = DateTime.tryParse(t['next_due'] ?? '') ?? now;
      return due.isBefore(weekLater) || due.isAtSameMomentAs(now);
    }).toList()..sort((a, b) => (a['next_due'] ?? '').compareTo(b['next_due'] ?? ''));
  }

  List<Map<String, dynamic>> get dueTodayTasks {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    return _tasks.where((t) => (t['next_due'] ?? '') <= todayStr && t['last_done'] != todayStr).toList();
  }

  int get activeBatchCount => _batches.where((b) => b['status'] == 'active').length;
  int get totalAnimalCount => _batches.where((b) => b['status'] == 'active').fold(0, (s, b) => s + (b['quantity'] as int));

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _animals = await _db.getAnimals();
    _batches = await _db.getBatches();
    _transactions = await _db.getTransactions();
    _tasks = await _db.getTasks();
    _totalSummary = await _db.getTotalSummary();
    _expenseByCategory = await _db.getExpenseByCategory();
    _monthlyData = await _db.getMonthlyData(6);
    _farmName = await _db.getSetting('farm_name') ?? 'My Farm';
    _currency = await _db.getSetting('currency') ?? '₱';

    _isLoading = false;
    notifyListeners();
  }

  // ─── ANIMALS ───────────────────────────────────────────────
  Future<void> addAnimal(String name, String emoji, String color) async {
    await _db.insertAnimal({
      'id': _uuid.v4(),
      'name': name,
      'emoji': emoji,
      'color': color,
      'sort_order': _animals.length,
      'created_at': DateTime.now().toIso8601String(),
    });
    await loadAll();
  }

  Future<void> deleteAnimal(String id) async {
    await _db.deleteAnimal(id);
    await loadAll();
  }

  Map<String, dynamic>? getAnimal(String id) {
    try { return _animals.firstWhere((a) => a['id'] == id); } catch (_) { return null; }
  }

  List<Map<String, dynamic>> batchesForAnimal(String animalId) =>
      _batches.where((b) => b['animal_id'] == animalId).toList();

  Future<Map<String, double>> summaryForAnimal(String animalId) async =>
      await _db.getTransactionSummary(animalId: animalId);

  // ─── BATCHES ───────────────────────────────────────────────
  Future<void> addBatch({
    required String animalId, required String name, required int quantity,
    required String startDate, required String status, String? notes,
  }) async {
    await _db.insertBatch({
      'id': _uuid.v4(), 'animal_id': animalId, 'name': name,
      'quantity': quantity, 'start_date': startDate, 'status': status,
      'notes': notes ?? '', 'created_at': DateTime.now().toIso8601String(),
    });
    await loadAll();
  }

  Future<void> updateBatchStatus(String id, String status) async {
    await _db.updateBatch(id, {'status': status});
    await loadAll();
  }

  Future<void> deleteBatch(String id) async {
    await _db.deleteBatch(id);
    await loadAll();
  }

  Future<Map<String, double>> summaryForBatch(String batchId) async =>
      await _db.getTransactionSummary(batchId: batchId);

  Future<List<Map<String, dynamic>>> transactionsForBatch(String batchId) async =>
      await _db.getTransactions(batchId: batchId);

  Map<String, dynamic>? getBatch(String id) {
    try { return _batches.firstWhere((b) => b['id'] == id); } catch (_) { return null; }
  }

  // ─── TRANSACTIONS ──────────────────────────────────────────
  Future<void> addTransaction({
    required String type, required double amount, required String date,
    required String category, String? batchId, String? animalId, String? notes,
  }) async {
    // Determine animalId from batch if not provided
    String? resolvedAnimalId = animalId;
    if (resolvedAnimalId == null && batchId != null) {
      final batch = getBatch(batchId);
      resolvedAnimalId = batch?['animal_id'];
    }
    await _db.insertTransaction({
      'id': _uuid.v4(), 'type': type, 'amount': amount, 'date': date,
      'category': category, 'batch_id': batchId, 'animal_id': resolvedAnimalId,
      'notes': notes ?? '', 'created_at': DateTime.now().toIso8601String(),
    });
    await loadAll();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    await loadAll();
  }

  List<Map<String, dynamic>> filteredTransactions({String? type, String? category, String? animalId, String? batchId}) {
    return _transactions.where((t) {
      if (type != null && t['type'] != type) return false;
      if (category != null && t['category'] != category) return false;
      if (animalId != null && t['animal_id'] != animalId) return false;
      if (batchId != null && t['batch_id'] != batchId) return false;
      return true;
    }).toList();
  }

  // ─── TASKS ─────────────────────────────────────────────────
  Future<void> addTask({
    required String title, String? animalId, String? batchId,
    required String frequency, required String nextDue, String? notes,
  }) async {
    final data = <String, dynamic>{
      'id': _uuid.v4(), 'title': title, 'frequency': frequency,
      'next_due': nextDue, 'notes': notes ?? '',
      'created_at': DateTime.now().toIso8601String(),
    };
    if (animalId != null) data['animal_id'] = animalId;
    if (batchId != null) data['batch_id'] = batchId;
    await _db.insertTask(data);
    await loadAll();
  }

  Future<void> markTaskDone(String id) async {
    final task = _tasks.firstWhere((t) => t['id'] == id);
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final nextDue = _computeNextDue(task['frequency'], todayStr);
    await _db.updateTask(id, {'last_done': todayStr, 'next_due': nextDue});
    await loadAll();
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    await loadAll();
  }

  String _computeNextDue(String frequency, String fromDate) {
    final dt = DateTime.parse(fromDate);
    DateTime next;
    if (frequency == 'daily') next = dt.add(const Duration(days: 1));
    else if (frequency == 'weekly') next = dt.add(const Duration(days: 7));
    else next = DateTime(dt.year, dt.month + 1, dt.day);
    return next.toIso8601String().substring(0, 10);
  }

  // ─── SETTINGS ──────────────────────────────────────────────
  Future<void> updateSetting(String key, String value) async {
    await _db.setSetting(key, value);
    if (key == 'farm_name') _farmName = value;
    if (key == 'currency') _currency = value;
    notifyListeners();
  }

  Future<String?> getSetting(String key) => _db.getSetting(key);

  Future<String> exportCSV() => _db.exportCSV();
}
