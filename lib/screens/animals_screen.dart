import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/farm_provider.dart';
import '../widgets/shared_widgets.dart';

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(builder: (context, farm, _) {
      final animals = farm.animals;
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          title: const Text('Animals'),
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () => _showAddAnimal(context, farm),
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: AppColors.forestMid,
              tooltip: 'Add animal type',
            ),
          ],
        ),
        body: animals.isEmpty
          ? const EmptyState(emoji: '🐾', title: 'No animals yet', subtitle: 'Tap + to add your first animal type and start tracking batches.')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: animals.length,
              itemBuilder: (context, i) {
                final a = animals[i];
                final batches = farm.batchesForAnimal(a['id']);
                final active = batches.where((b) => b['status'] == 'active').length;
                final fmt = NumberFormat('#,##0');
                return FutureBuilder<Map<String, double>>(
                  future: farm.summaryForAnimal(a['id']),
                  builder: (ctx, snap) {
                    final s = snap.data ?? {'income': 0, 'expense': 0, 'profit': 0};
                    return Animate(
                      effects: [FadeEffect(delay: Duration(milliseconds: i * 60), duration: 350.ms)],
                      child: AnimalCard(
                        animal: a,
                        income: '${farm.currency}${fmt.format(s['income']!)}',
                        expense: '${farm.currency}${fmt.format(s['expense']!)}',
                        profit: '${s['profit']! >= 0 ? '+' : '-'}${farm.currency}${fmt.format(s['profit']!.abs())}',
                        isProfit: (s['profit'] ?? 0) >= 0,
                        batchCount: batches.length,
                        activeBatchCount: active,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnimalDetailScreen(animalId: a['id']))),
                      ),
                    );
                  },
                );
              },
            ),
      );
    });
  }

  void _showAddAnimal(BuildContext context, FarmProvider farm) {
    final nameCtrl = TextEditingController();
    String emoji = '🐾';
    String color = 'custom';
    final colors = [
      ('pig', '🐷', 'Pig / Swine', AppColors.pig, AppColors.pigPale),
      ('chicken', '🐔', 'Chicken / Poultry', AppColors.chicken, AppColors.chickenPale),
      ('goat', '🐐', 'Goat', AppColors.goat, AppColors.goatPale),
      ('cow', '🐄', 'Cattle / Cow', AppColors.cow, AppColors.cowPale),
      ('duck', '🦆', 'Duck', AppColors.duck, AppColors.duckPale),
      ('custom', '🐾', 'Other / Custom', AppColors.custom, AppColors.customPale),
    ];

    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const _SheetHandle(),
              const SizedBox(height: 4),
              const Text('New Animal Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              _label('Animal Name'),
              TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Rabbit, Fish, Horse')),
              const SizedBox(height: 20),
              _label('Choose Type'),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: colors.map((c) {
                final selected = color == c.$1;
                return GestureDetector(
                  onTap: () => setModalState(() { color = c.$1; emoji = c.$2; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? c.$5 : AppColors.creamWarm,
                      borderRadius: BorderRadius.circular(Radii.lg),
                      border: Border.all(color: selected ? c.$4 : AppColors.creamBorder, width: selected ? 2 : 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(c.$2, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(c.$3, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? c.$4 : AppColors.inkLight)),
                    ]),
                  ),
                );
              }).toList()),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    farm.addAnimal(nameCtrl.text.trim(), emoji, color);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Animal Type'),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          )),
        );
      }),
    );
  }
}

// ─── ANIMAL DETAIL ───────────────────────────────────────────
class AnimalDetailScreen extends StatelessWidget {
  final String animalId;
  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(builder: (context, farm, _) {
      final animal = farm.getAnimal(animalId);
      if (animal == null) return const Scaffold(body: Center(child: Text('Animal not found')));
      final batches = farm.batchesForAnimal(animalId);
      final color = animalColor(animal['color'] ?? 'custom');
      final pale = animalPaleColor(animal['color'] ?? 'custom');
      final fmt = NumberFormat('#,##0');

      return Scaffold(
        backgroundColor: AppColors.cream,
        body: CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: pale,
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(animal['emoji'], style: const TextStyle(fontSize: 52)),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(animal['name'], style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
                    Text('${batches.where((b) => b['status'] == 'active').length} active • ${batches.length} total batches',
                      style: TextStyle(fontSize: 13, color: color.withOpacity(0.7), fontWeight: FontWeight.w500)),
                  ]),
                ]),
              ),
              title: Text(animal['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              collapseMode: CollapseMode.pin,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => _confirmDialog(ctx, 'Delete ${animal['name']}?', 'This will remove the animal type. Batches and transactions will remain in the database.'),
                  );
                  if (confirmed == true) {
                    farm.deleteAnimal(animalId);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Summary cards
              FutureBuilder<Map<String, double>>(
                future: farm.summaryForAnimal(animalId),
                builder: (ctx, snap) {
                  final s = snap.data ?? {'income': 0, 'expense': 0, 'profit': 0};
                  final profit = s['profit'] ?? 0;
                  return Row(children: [
                    Expanded(child: StatCard(label: 'INCOME', value: '${farm.currency}${fmt.format(s['income']!)}', color: AppColors.sapphire, bgColor: AppColors.sapphirePale)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(label: 'EXPENSE', value: '${farm.currency}${fmt.format(s['expense']!)}', color: AppColors.crimson, bgColor: AppColors.crimsonPale)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(
                      label: 'PROFIT',
                      value: '${profit >= 0 ? '+' : '-'}${farm.currency}${fmt.format(profit.abs())}',
                      color: profit >= 0 ? AppColors.forestMid : AppColors.crimson,
                      bgColor: profit >= 0 ? AppColors.forestPale : AppColors.crimsonPale,
                    )),
                  ]);
                },
              ),
              const SizedBox(height: 24),

              SectionHeader(title: 'Batches', action: '+ Add Batch', onAction: () => _showAddBatch(context, farm, animalId)),
              if (batches.isEmpty)
                const EmptyState(emoji: '📦', title: 'No batches yet', subtitle: 'Tap "+ Add Batch" to create your first batch of ${  ''}animals.')
              else
                ...batches.asMap().entries.map((e) {
                  final b = e.value;
                  return FutureBuilder<Map<String, double>>(
                    future: farm.summaryForBatch(b['id']),
                    builder: (ctx, snap) {
                      final s = snap.data ?? {'income': 0, 'expense': 0, 'profit': 0};
                      final profit = s['profit'] ?? 0;
                      return Animate(
                        effects: [FadeEffect(delay: Duration(milliseconds: e.key * 60), duration: 350.ms)],
                        child: BatchCard(
                          batch: b,
                          income: '${farm.currency}${fmt.format(s['income']!)}',
                          expense: '${farm.currency}${fmt.format(s['expense']!)}',
                          profit: '${profit >= 0 ? '+' : '-'}${farm.currency}${fmt.format(profit.abs())}',
                          isProfit: profit >= 0,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BatchDetailScreen(batchId: b['id']))),
                        ),
                      );
                    },
                  );
                }),
            ])),
          ),
        ]),
      );
    });
  }

  void _showAddBatch(BuildContext context, FarmProvider farm, String animalId) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String status = 'active';

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
              const Text('New Batch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              _label('Batch Name'),
              TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Pig Batch C')),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Quantity'),
                  TextField(controller: qtyCtrl, decoration: const InputDecoration(hintText: '0'), keyboardType: TextInputType.number),
                ])),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Start Date'),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) ss(() => selectedDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.creamWarm, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.creamBorder)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.inkLight),
                        const SizedBox(width: 8),
                        Text(DateFormat('MMM d, y').format(selectedDate), style: const TextStyle(fontSize: 14)),
                      ]),
                    ),
                  ),
                ])),
              ]),
              const SizedBox(height: 16),
              _label('Notes (optional)'),
              TextField(controller: notesCtrl, decoration: const InputDecoration(hintText: 'Breed, source, etc.'), maxLines: 2),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty || qtyCtrl.text.isEmpty) return;
                  farm.addBatch(
                    animalId: animalId, name: nameCtrl.text.trim(),
                    quantity: int.tryParse(qtyCtrl.text) ?? 1,
                    startDate: DateFormat('yyyy-MM-dd').format(selectedDate),
                    status: status, notes: notesCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Create Batch'),
              )),
              const SizedBox(height: 8),
            ]),
          )),
        );
      }),
    );
  }
}

// ─── BATCH DETAIL ────────────────────────────────────────────
class BatchDetailScreen extends StatelessWidget {
  final String batchId;
  const BatchDetailScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(builder: (context, farm, _) {
      final batch = farm.getBatch(batchId);
      if (batch == null) return const Scaffold(body: Center(child: Text('Batch not found')));
      final animal = farm.getAnimal(batch['animal_id'] ?? '');
      final fmt = NumberFormat('#,##0');
      final txns = farm.filteredTransactions(batchId: batchId);

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          title: Text(batch['name'] ?? ''),
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.crimson,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => _confirmDialog(ctx, 'Delete Batch?', 'All transactions for this batch will also be deleted.'),
                );
                if (confirmed == true) {
                  farm.deleteBatch(batchId);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: FutureBuilder<Map<String, double>>(
          future: farm.summaryForBatch(batchId),
          builder: (ctx, snap) {
            final s = snap.data ?? {'income': 0, 'expense': 0, 'profit': 0};
            final profit = s['profit'] ?? 0;
            return CustomScrollView(slivers: [
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Batch info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(Radii.xl), border: Border.all(color: AppColors.creamBorder)),
                    child: Column(children: [
                      Row(children: [
                        if (animal != null) Text(animal['emoji'] ?? '', style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(batch['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          Text('${batch['quantity']} animals · Started ${DateFormat('MMM d, yyyy').format(DateTime.tryParse(batch['start_date'] ?? '') ?? DateTime.now())}',
                            style: const TextStyle(fontSize: 12, color: AppColors.inkLight)),
                        ])),
                        _statusDropdown(context, farm, batchId, batch['status']),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: StatCard(label: 'INCOME', value: '${farm.currency}${fmt.format(s['income']!)}', color: AppColors.sapphire, bgColor: AppColors.sapphirePale)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(label: 'EXPENSE', value: '${farm.currency}${fmt.format(s['expense']!)}', color: AppColors.crimson, bgColor: AppColors.crimsonPale)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(
                      label: 'PROFIT',
                      value: '${profit >= 0 ? '+' : '-'}${farm.currency}${fmt.format(profit.abs())}',
                      color: profit >= 0 ? AppColors.forestMid : AppColors.crimson,
                      bgColor: profit >= 0 ? AppColors.forestPale : AppColors.crimsonPale,
                    )),
                  ]),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Transactions',
                    action: '+ Add',
                    onAction: () => _showAddTransaction(context, farm, batchId),
                  ),
                ]),
              )),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: txns.isEmpty
                  ? const SliverToBoxAdapter(child: EmptyState(emoji: '💳', title: 'No transactions', subtitle: 'Tap "+ Add" to log an expense or income for this batch.'))
                  : SliverList(delegate: SliverChildBuilderDelegate(
                      (ctx, i) => TransactionTile(
                        transaction: txns[i],
                        animalName: animal?['name'] ?? '',
                        onDelete: () => farm.deleteTransaction(txns[i]['id']),
                      ),
                      childCount: txns.length,
                    )),
              ),
            ]);
          },
        ),
      );
    });
  }

  Widget _statusDropdown(BuildContext context, FarmProvider farm, String batchId, String current) {
    return DropdownButton<String>(
      value: current,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(Radii.lg),
      items: ['active', 'sold', 'deceased'].map((s) {
        final configs = {
          'active': (AppColors.forestPale, AppColors.forestMid, 'Active'),
          'sold': (AppColors.sapphirePale, AppColors.sapphire, 'Sold'),
          'deceased': (AppColors.crimsonPale, AppColors.crimson, 'Deceased'),
        };
        final (bg, fg, label) = configs[s]!;
        return DropdownMenuItem(value: s, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
        ));
      }).toList(),
      onChanged: (v) { if (v != null) farm.updateBatchStatus(batchId, v); },
    );
  }

  void _showAddTransaction(BuildContext context, FarmProvider farm, String batchId) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      builder: (ctx) => _AddTransactionSheet(farm: farm, preBatchId: batchId),
    );
  }
}

// ─── ADD TRANSACTION SHEET ───────────────────────────────────
class AddTransactionSheet extends StatefulWidget {
  final FarmProvider farm;
  final String? preBatchId;
  const AddTransactionSheet({super.key, required this.farm, this.preBatchId});
  @override State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  String type = 'expense';
  String category = 'feed';
  String? selectedBatch;
  DateTime date = DateTime.now();
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  static const expCats = ['feed', 'medicine', 'labor', 'transport', 'other'];
  static const incCats = ['sales', 'other'];

  @override
  void initState() { super.initState(); selectedBatch = widget.preBatchId; }

  @override
  Widget build(BuildContext context) {
    final batches = widget.farm.batches;
    final cats = type == 'expense' ? expCats : incCats;
    if (!cats.contains(category)) category = cats.first;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _SheetHandle(),
          const SizedBox(height: 4),
          const Text('Add Transaction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          // Type toggle
          Container(
            decoration: BoxDecoration(color: AppColors.creamWarm, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(4),
            child: Row(children: [
              _typeBtn('expense', '💸 Expense'),
              _typeBtn('income', '💰 Income'),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Amount (${widget.farm.currency})'),
              TextField(controller: amountCtrl, decoration: const InputDecoration(hintText: '0.00'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            ])),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Date'),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (d != null) setState(() => date = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.creamWarm, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.creamBorder)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.inkLight),
                    const SizedBox(width: 8),
                    Text(DateFormat('MMM d').format(date), style: const TextStyle(fontSize: 14)),
                  ]),
                ),
              ),
            ])),
          ]),
          const SizedBox(height: 16),
          _label('Category'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: cats.map((c) => GestureDetector(
            onTap: () => setState(() => category = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: category == c ? (type == 'expense' ? AppColors.crimsonPale : AppColors.forestPale) : AppColors.creamWarm,
                borderRadius: BorderRadius.circular(Radii.pill),
                border: Border.all(color: category == c ? (type == 'expense' ? AppColors.crimson : AppColors.forestMint) : AppColors.creamBorder),
              ),
              child: Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: category == c ? (type == 'expense' ? AppColors.crimson : AppColors.forestMid) : AppColors.inkLight)),
            ),
          )).toList()),
          const SizedBox(height: 16),
          _label('Link to Batch'),
          DropdownButtonFormField<String>(
            value: selectedBatch,
            decoration: const InputDecoration(hintText: '— No Batch —'),
            items: [
              const DropdownMenuItem(value: null, child: Text('— No Batch —', style: TextStyle(color: AppColors.inkGhost))),
              ...batches.map((b) {
                final animal = widget.farm.getAnimal(b['animal_id'] ?? '');
                return DropdownMenuItem(value: b['id'] as String, child: Text('${animal?['emoji'] ?? ''} ${b['name']}', overflow: TextOverflow.ellipsis));
              }),
            ],
            onChanged: (v) => setState(() => selectedBatch = v),
          ),
          const SizedBox(height: 16),
          _label('Notes'),
          TextField(controller: notesCtrl, decoration: const InputDecoration(hintText: 'Description...'), maxLines: 2),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: type == 'expense' ? AppColors.crimson : AppColors.forestMid,
            ),
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount <= 0) return;
              widget.farm.addTransaction(
                type: type, amount: amount,
                date: DateFormat('yyyy-MM-dd').format(date),
                category: category, batchId: selectedBatch,
                notes: notesCtrl.text.trim(),
              );
              Navigator.pop(context);
            },
            child: Text('Save ${type == 'expense' ? 'Expense' : 'Income'}'),
          )),
          const SizedBox(height: 8),
        ]),
      )),
    );
  }

  Widget _typeBtn(String t, String label) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => type = t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: type == t ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: type == t ? AppColors.inkDark : AppColors.inkGhost)),
      ),
    ),
  );
}

// Alias for use from other screens
typedef _AddTransactionSheet = AddTransactionSheet;

// ─── HELPERS ─────────────────────────────────────────────────
Widget _label(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.inkLight, letterSpacing: 0.3)),
);

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36, height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: AppColors.creamBorder, borderRadius: BorderRadius.circular(2)),
    ),
  );
}

AlertDialog _confirmDialog(BuildContext ctx, String title, String message) => AlertDialog(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
  title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
  content: Text(message, style: const TextStyle(color: AppColors.inkLight)),
  actions: [
    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
    ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.crimson),
      onPressed: () => Navigator.pop(ctx, true),
      child: const Text('Delete'),
    ),
  ],
);
