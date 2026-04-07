import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../core/theme.dart';
import '../providers/farm_provider.dart';
import '../widgets/shared_widgets.dart';
import 'animals_screen.dart';

// ═══════════════════════════════════════════════════════════════
// FINANCE SCREEN
// ═══════════════════════════════════════════════════════════════

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String _filter = 'all';
  final _filters = ['all', 'expense', 'income', 'feed', 'medicine', 'labor', 'sales', 'transport', 'other'];

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(builder: (context, farm, _) {
      final summary = farm.totalSummary;
      final fmt = NumberFormat('#,##0');
      final cur = farm.currency;
      String? typeFilter = ['expense', 'income'].contains(_filter) ? _filter : null;
      String? catFilter = !['all', 'expense', 'income'].contains(_filter) ? _filter : null;
      final txns = farm.filteredTransactions(type: typeFilter, category: catFilter);

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          surfaceTintColor: Colors.transparent,
          title: const Text('Finance'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: AppColors.forestMid,
              onPressed: () => showModalBottomSheet(
                context: context, isScrollControlled: true, useSafeArea: true,
                builder: (_) => AddTransactionSheet(farm: farm),
              ),
            ),
          ],
        ),
        body: Column(children: [
          // Summary row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              Expanded(child: _miniStat('Income', '$cur${fmt.format(summary['income']!)}', AppColors.sapphire, AppColors.sapphirePale)),
              const SizedBox(width: 10),
              Expanded(child: _miniStat('Expense', '$cur${fmt.format(summary['expense']!)}', AppColors.crimson, AppColors.crimsonPale)),
              const SizedBox(width: 10),
              Expanded(child: _miniStat('Profit',
                '${(summary['profit'] ?? 0) >= 0 ? '+' : '-'}$cur${fmt.format((summary['profit'] ?? 0).abs())}',
                (summary['profit'] ?? 0) >= 0 ? AppColors.forestMid : AppColors.crimson,
                (summary['profit'] ?? 0) >= 0 ? AppColors.forestPale : AppColors.crimsonPale)),
            ]),
          ),
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final f = _filters[i];
                final active = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.forestMid : AppColors.white,
                      borderRadius: BorderRadius.circular(Radii.pill),
                      border: Border.all(color: active ? AppColors.forestMid : AppColors.creamBorder),
                    ),
                    child: Text(f[0].toUpperCase() + f.substring(1),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: active ? AppColors.white : AppColors.inkLight)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Transaction list
          Expanded(
            child: txns.isEmpty
              ? const EmptyState(emoji: '💳', title: 'No transactions', subtitle: 'Tap + to add your first expense or income.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: txns.length,
                  itemBuilder: (ctx, i) {
                    final t = txns[i];
                    final animal = farm.getAnimal(t['animal_id'] ?? '');
                    final batch = farm.getBatch(t['batch_id'] ?? '');
                    return TransactionTile(
                      transaction: t,
                      animalName: animal?['name'] ?? '',
                      batchName: batch?['name'] ?? '',
                      onDelete: () => farm.deleteTransaction(t['id']),
                    );
                  },
                ),
          ),
        ]),
      );
    });
  }

  Widget _miniStat(String label, String value, Color color, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.lg)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color.withOpacity(0.7), letterSpacing: 0.4)),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color), overflow: TextOverflow.ellipsis),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════
// TASKS SCREEN
// ═══════════════════════════════════════════════════════════════

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(builder: (context, farm, _) {
      final all = farm.tasks;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final due = all.where((t) => (t['next_due'] ?? '') <= today && t['last_done'] != today).toList();
      final upcoming = all.where((t) => (t['next_due'] ?? '') > today).toList();

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          surfaceTintColor: Colors.transparent,
          title: const Text('Tasks'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: AppColors.forestMid,
              onPressed: () => _showAddTask(context, farm),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            labelColor: AppColors.forestMid,
            unselectedLabelColor: AppColors.inkGhost,
            indicatorColor: AppColors.forestMid,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppColors.creamBorder,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: 'Due (${due.length})'),
              Tab(text: 'Upcoming (${upcoming.length})'),
              Tab(text: 'All (${all.length})'),
            ],
          ),
        ),
        body: TabBarView(controller: _tabs, children: [
          _taskList(due, farm, context, emptyMsg: "No overdue tasks 🎉"),
          _taskList(upcoming, farm, context, emptyMsg: "No upcoming tasks"),
          _taskList(all, farm, context),
        ]),
      );
    });
  }

  Widget _taskList(List<Map<String, dynamic>> tasks, FarmProvider farm, BuildContext ctx, {String? emptyMsg}) {
    if (tasks.isEmpty) return Center(child: EmptyState(
      emoji: '✅', title: emptyMsg ?? 'No tasks', subtitle: 'Tap + to add reminders for feeding, vaccination, and more.',
    ));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (_, i) {
        final t = tasks[i];
        final animal = farm.getAnimal(t['animal_id'] ?? '');
        return Animate(
          effects: [FadeEffect(delay: Duration(milliseconds: i * 40), duration: 300.ms)],
          child: TaskTile(
            task: t,
            animalName: animal?['name'] ?? '',
            animalEmoji: animal?['emoji'] ?? '',
            onMarkDone: () => farm.markTaskDone(t['id']),
            onDelete: () => farm.deleteTask(t['id']),
          ),
        );
      },
    );
  }

  void _showAddTask(BuildContext context, FarmProvider farm) {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String frequency = 'daily';
    String? animalId;
    DateTime nextDue = DateTime.now();

    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const _SheetHandle(),
              const SizedBox(height: 4),
              const Text('New Task / Reminder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              _label('Task Title'),
              TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'e.g. Feed pigs')),
              const SizedBox(height: 16),
              _label('Animal Type (optional)'),
              DropdownButtonFormField<String>(
                value: animalId,
                decoration: const InputDecoration(hintText: '— All Animals —'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('— All Animals —', style: TextStyle(color: AppColors.inkGhost))),
                  ...farm.animals.map((a) => DropdownMenuItem(value: a['id'] as String, child: Text('${a['emoji']} ${a['name']}'))),
                ],
                onChanged: (v) => ss(() => animalId = v),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Frequency'),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    items: ['daily', 'weekly', 'monthly'].map((f) => DropdownMenuItem(value: f, child: Text(f[0].toUpperCase() + f.substring(1)))).toList(),
                    onChanged: (v) => ss(() => frequency = v ?? frequency),
                  ),
                ])),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('First Due Date'),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(context: ctx, initialDate: nextDue, firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) ss(() => nextDue = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.creamWarm, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.creamBorder)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.inkLight),
                        const SizedBox(width: 8),
                        Text(DateFormat('MMM d').format(nextDue), style: const TextStyle(fontSize: 14)),
                      ]),
                    ),
                  ),
                ])),
              ]),
              const SizedBox(height: 16),
              _label('Notes (optional)'),
              TextField(controller: notesCtrl, decoration: const InputDecoration(hintText: 'Dosage, quantities, etc.'), maxLines: 2),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  farm.addTask(
                    title: titleCtrl.text.trim(), animalId: animalId, frequency: frequency,
                    nextDue: DateFormat('yyyy-MM-dd').format(nextDue), notes: notesCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Add Task'),
              )),
              const SizedBox(height: 8),
            ]),
          )),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REPORTS SCREEN
// ═══════════════════════════════════════════════════════════════

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(builder: (context, farm, _) {
      final fmt = NumberFormat('#,##0');
      final cur = farm.currency;
      final summary = farm.totalSummary;
      final catData = farm.expenseByCategory;
      final catColors = [AppColors.forestMint, AppColors.crimson, AppColors.sapphire, AppColors.amber, AppColors.violet, AppColors.inkLight];
      final catList = catData.entries.toList();

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          surfaceTintColor: Colors.transparent,
          title: const Text('Reports'),
          actions: [
            TextButton.icon(
              onPressed: () => _exportCSV(context, farm),
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: const Text('Export'),
              style: TextButton.styleFrom(foregroundColor: AppColors.forestMid),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // Summary
            _card(Column(children: [
              _reportRow('Total Income', '$cur${fmt.format(summary['income']!)}', AppColors.sapphire),
              _divider(),
              _reportRow('Total Expenses', '$cur${fmt.format(summary['expense']!)}', AppColors.crimson),
              _divider(),
              _reportRow('Net Profit', '${(summary['profit']??0) >= 0 ? '+' : '-'}$cur${fmt.format((summary['profit']??0).abs())}',
                (summary['profit'] ?? 0) >= 0 ? AppColors.forestMid : AppColors.crimson),
              _divider(),
              _reportRow('Active Batches', farm.activeBatchCount.toString(), AppColors.inkDark),
              _divider(),
              _reportRow('Total Animals', farm.totalAnimalCount.toString(), AppColors.inkDark),
            ]), title: 'Farm Summary'),
            const SizedBox(height: 16),

            // Expense breakdown pie chart
            if (catList.isNotEmpty) _card(Column(children: [
              SizedBox(
                height: 180,
                child: PieChart(PieChartData(
                  sections: catList.asMap().entries.map((e) {
                    final total = catData.values.fold<double>(0, (a, b) => a + b);
                    final pct = total > 0 ? e.value.value / total * 100 : 0;
                    return PieChartSectionData(
                      value: e.value.value,
                      color: catColors[e.key % catColors.length],
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      radius: 60,
                    );
                  }).toList(),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                )),
              ),
              const SizedBox(height: 16),
              ...catList.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: catColors[e.key % catColors.length], borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 10),
                  Text(e.value.key[0].toUpperCase() + e.value.key.substring(1),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkDark)),
                  const Spacer(),
                  Text('$cur${fmt.format(e.value.value)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.inkDark)),
                ]),
              )),
            ]), title: 'Expense Breakdown'),
            const SizedBox(height: 16),

            // Per animal
            _card(Column(children: [
              ...farm.animals.map((a) => FutureBuilder<Map<String, double>>(
                future: farm.summaryForAnimal(a['id']),
                builder: (ctx, snap) {
                  final s = snap.data ?? {'profit': 0, 'income': 0, 'expense': 0};
                  final profit = s['profit'] ?? 0;
                  return Column(children: [
                    Row(children: [
                      Text(a['emoji'] ?? '', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(a['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                      Text('${profit >= 0 ? '+' : '-'}$cur${fmt.format(profit.abs())}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: profit >= 0 ? AppColors.forestMid : AppColors.crimson)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const SizedBox(width: 30),
                      Text('In: $cur${fmt.format(s['income']!)}', style: const TextStyle(fontSize: 12, color: AppColors.sapphire, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Text('Out: $cur${fmt.format(s['expense']!)}', style: const TextStyle(fontSize: 12, color: AppColors.crimson, fontWeight: FontWeight.w600)),
                    ]),
                    if (a != farm.animals.last) _divider(),
                  ]);
                },
              )),
            ]), title: 'Profit by Animal'),
            const SizedBox(height: 16),

            // Per batch
            _card(Column(children: [
              ...farm.batches.asMap().entries.map((e) {
                final b = e.value;
                final animal = farm.getAnimal(b['animal_id'] ?? '');
                return FutureBuilder<Map<String, double>>(
                  future: farm.summaryForBatch(b['id']),
                  builder: (ctx, snap) {
                    final s = snap.data ?? {'profit': 0};
                    final profit = s['profit'] ?? 0;
                    return Column(children: [
                      Row(children: [
                        if (animal != null) Text(animal['emoji'] ?? '', style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(b['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                          Text(b['status'], style: const TextStyle(fontSize: 11, color: AppColors.inkGhost)),
                        ])),
                        Text('${profit >= 0 ? '+' : '-'}$cur${fmt.format(profit.abs())}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: profit >= 0 ? AppColors.forestMid : AppColors.crimson)),
                      ]),
                      if (e.key < farm.batches.length - 1) _divider(),
                    ]);
                  },
                );
              }),
            ]), title: 'Profit by Batch'),
          ],
        ),
      );
    });
  }

  Widget _card(Widget child, {required String title}) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(Radii.xl), border: Border.all(color: AppColors.creamBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.inkDark)),
      const SizedBox(height: 16),
      child,
    ]),
  );

  Widget _reportRow(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.inkLight, fontWeight: FontWeight.w500))),
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
    ]),
  );

  Widget _divider() => const Divider(color: AppColors.creamBorder, height: 1);

  Future<void> _exportCSV(BuildContext context, FarmProvider farm) async {
    final csv = await farm.exportCSV();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/farmtrack_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
    await file.writeAsString(csv);
    if (context.mounted) {
      await Share.shareXFiles([XFile(file.path)], text: 'FarmTrack Export');
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ═══════════════════════════════════════════════════════════════

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _currCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) _load();
  }

  Future<void> _load() async {
    final farm = context.read<FarmProvider>();
    _nameCtrl.text = farm.farmName;
    _currCtrl.text = farm.currency;
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(builder: (context, farm, _) => Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: () {
              farm.updateSetting('farm_name', _nameCtrl.text.trim().isEmpty ? 'My Farm' : _nameCtrl.text.trim());
              farm.updateSetting('currency', _currCtrl.text.trim().isEmpty ? '₱' : _currCtrl.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!'), backgroundColor: AppColors.forestMid));
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.forestMid)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _section('Farm', [
          _settingsTile('Farm Name', icon: '🏡', child: TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'My Farm'),
            style: const TextStyle(fontSize: 14),
          )),
          _settingsTile('Currency', icon: '💱', child: TextField(
            controller: _currCtrl,
            decoration: const InputDecoration(hintText: '₱'),
            style: const TextStyle(fontSize: 14),
            maxLength: 3,
          )),
        ]),
        const SizedBox(height: 16),
        _section('Security', [
          _settingsTile('Change PIN', icon: '🔐', onTap: () => _changePin(context, farm)),
        ]),
        const SizedBox(height: 16),
        _section('Data', [
          _settingsTile('Export All Data', icon: '📤', onTap: () async {
            final csv = await farm.exportCSV();
            final dir = await getTemporaryDirectory();
            final file = File('${dir.path}/farmtrack_export.csv');
            await file.writeAsString(csv);
            if (context.mounted) await Share.shareXFiles([XFile(file.path)], text: 'FarmTrack Data Export');
          }),
          _settingsTile('Reset All Data', icon: '🗑️', textColor: AppColors.crimson, onTap: () => _confirmReset(context, farm)),
        ]),
        const SizedBox(height: 24),
        Center(child: Text('FarmTrack v1.0.0\nOffline-First · SQLite Storage\nMade for Filipino Farmers 🌾',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.inkGhost, height: 1.8))),
      ]),
    ));
  }

  Widget _section(String title, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inkGhost, letterSpacing: 0.8))),
    Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(Radii.xl), border: Border.all(color: AppColors.creamBorder)),
      child: Column(children: children),
    ),
  ]);

  Widget _settingsTile(String label, {String? icon, Widget? child, VoidCallback? onTap, Color? textColor}) {
    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        if (icon != null) Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: child != null
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.inkLight, letterSpacing: 0.3)),
              const SizedBox(height: 4),
              child,
            ])
          : Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor ?? AppColors.inkDark))),
        if (onTap != null && child == null) const Icon(Icons.chevron_right_rounded, color: AppColors.inkGhost),
      ]),
    );
    if (onTap != null) return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(Radii.xl), child: tile);
    return tile;
  }

  void _changePin(BuildContext context, FarmProvider farm) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
      title: const Text('Change PIN', style: TextStyle(fontWeight: FontWeight.w800)),
      content: TextField(
        controller: ctrl, obscureText: true, maxLength: 4,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'New 4-digit PIN'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (ctrl.text.length != 4) return;
          farm.updateSetting('pin', ctrl.text);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN updated!'), backgroundColor: AppColors.forestMid));
        }, child: const Text('Save')),
      ],
    ));
  }

  void _confirmReset(BuildContext context, FarmProvider farm) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
      title: const Text('Reset All Data', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.crimson)),
      content: const Text('This will permanently delete all animals, batches, transactions, and tasks. This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.crimson),
          onPressed: () async {
            await DatabaseHelper.instance.clearAll();
            if (context.mounted) {
              Navigator.pop(ctx);
              Navigator.of(context).pushNamedAndRemoveUntil('/pin', (_) => false);
            }
          },
          child: const Text('Reset Everything'),
        ),
      ],
    ));
  }
}

// ─── SHARED HELPERS ──────────────────────────────────────────
Widget _label(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.inkLight, letterSpacing: 0.3)),
);

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: AppColors.creamBorder, borderRadius: BorderRadius.circular(2)),
    ),
  );
}

// Import from database for reset
import '../core/database.dart';
