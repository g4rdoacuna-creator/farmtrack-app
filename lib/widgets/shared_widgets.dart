import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import 'package:intl/intl.dart';

// ─── STAT CARD ──────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final String? subtitle;
  final Widget? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (icon != null) ...[icon!, const SizedBox(width: 6)],
            Text(label, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: color.withOpacity(0.8), letterSpacing: 0.6,
            )),
          ]),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w800,
            color: color, letterSpacing: -0.5,
            fontFamily: 'Plus Jakarta Sans',
          )),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: TextStyle(
              fontSize: 11, color: color.withOpacity(0.6), fontWeight: FontWeight.w500,
            )),
          ],
        ],
      ),
    );
  }
}

// ─── ANIMAL CARD ────────────────────────────────────────────
class AnimalCard extends StatelessWidget {
  final Map<String, dynamic> animal;
  final String income;
  final String expense;
  final String profit;
  final bool isProfit;
  final int batchCount;
  final int activeBatchCount;
  final VoidCallback onTap;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.income,
    required this.expense,
    required this.profit,
    required this.isProfit,
    required this.batchCount,
    required this.activeBatchCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = animalColor(animal['color'] ?? 'custom');
    final pale = animalPaleColor(animal['color'] ?? 'custom');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: AppColors.creamBorder),
          boxShadow: [BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16, offset: const Offset(0, 4),
          )],
        ),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pale,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
            ),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child: Center(child: Text(animal['emoji'] ?? '🐾', style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(animal['name'], style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.inkDark,
                )),
                const SizedBox(height: 2),
                Row(children: [
                  _pill('$activeBatchCount active', color),
                  const SizedBox(width: 6),
                  Text('$batchCount total', style: const TextStyle(
                    fontSize: 11, color: AppColors.inkGhost, fontWeight: FontWeight.w500,
                  )),
                ]),
              ])),
              Icon(Icons.chevron_right_rounded, color: color, size: 22),
            ]),
          ),
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              _statItem('Income', income, AppColors.sapphire),
              _divider(),
              _statItem('Expense', expense, AppColors.crimson),
              _divider(),
              _statItem('Profit', profit, isProfit ? AppColors.forestMid : AppColors.crimson),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(Radii.pill),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
  );

  Widget _statItem(String label, String value, Color color) => Expanded(
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.inkGhost, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.3)),
    ]),
  );

  Widget _divider() => Container(
    width: 1, height: 32,
    color: AppColors.creamBorder,
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );
}

// ─── BATCH CARD ─────────────────────────────────────────────
class BatchCard extends StatelessWidget {
  final Map<String, dynamic> batch;
  final String income;
  final String expense;
  final String profit;
  final bool isProfit;
  final VoidCallback onTap;

  const BatchCard({
    super.key,
    required this.batch,
    required this.income,
    required this.expense,
    required this.profit,
    required this.isProfit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = batch['status'] as String? ?? 'active';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: AppColors.creamBorder),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(batch['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.inkDark)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('${batch['quantity']} animals', style: const TextStyle(fontSize: 12, color: AppColors.inkLight)),
                  const SizedBox(width: 8),
                  Text('·', style: const TextStyle(color: AppColors.inkGhost)),
                  const SizedBox(width: 8),
                  Text(_formatDate(batch['start_date'] ?? ''), style: const TextStyle(fontSize: 12, color: AppColors.inkLight)),
                ]),
              ])),
              _statusBadge(status),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkGhost, size: 20),
            ]),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.creamWarm,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(Radii.xl)),
            ),
            child: Row(children: [
              _fin('Income', income, AppColors.sapphire),
              _fin('Expense', expense, AppColors.crimson),
              _fin('Profit', profit, isProfit ? AppColors.forestMid : AppColors.crimson),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _fin(String label, String value, Color color) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.inkGhost, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ]),
    ),
  );

  Widget _statusBadge(String status) {
    final configs = {
      'active': (AppColors.forestPale, AppColors.forestMid, 'Active'),
      'sold': (AppColors.sapphirePale, AppColors.sapphire, 'Sold'),
      'deceased': (AppColors.crimsonPale, AppColors.crimson, 'Deceased'),
    };
    final (bg, fg, label) = configs[status] ?? (AppColors.creamWarm, AppColors.inkLight, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  String _formatDate(String d) {
    try { return DateFormat('MMM d, yyyy').format(DateTime.parse(d)); } catch (_) { return d; }
  }
}

// ─── TRANSACTION TILE ────────────────────────────────────────
class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String animalName;
  final String batchName;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.animalName = '',
    this.batchName = '',
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction['type'] == 'income';
    final amount = (transaction['amount'] as num).toDouble();
    final color = isIncome ? AppColors.forestMid : AppColors.crimson;
    final bgColor = isIncome ? AppColors.forestGhost : AppColors.crimsonPale;

    return Dismissible(
      key: Key(transaction['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.crimson,
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: AppColors.creamBorder),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(Radii.lg)),
            child: Center(child: Text(isIncome ? '💰' : '💸', style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _catBadge(transaction['category'] ?? ''),
              if (animalName.isNotEmpty) ...[const SizedBox(width: 6), Text(animalName, style: const TextStyle(fontSize: 10, color: AppColors.inkGhost, fontWeight: FontWeight.w500))],
            ]),
            const SizedBox(height: 3),
            Text(
              (transaction['notes'] as String?)?.isNotEmpty == true ? transaction['notes'] : 'No notes',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkDark),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(_formatDate(transaction['date'] ?? ''), style: const TextStyle(fontSize: 11, color: AppColors.inkGhost)),
          ])),
          Text(
            '${isIncome ? '+' : '-'}₱${_formatNum(amount)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
        ]),
      ),
    );
  }

  Widget _catBadge(String cat) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.creamWarm,
      borderRadius: BorderRadius.circular(Radii.pill),
    ),
    child: Text(cat, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.inkLight, letterSpacing: 0.3)),
  );

  String _formatDate(String d) {
    try { return DateFormat('MMM d, yyyy').format(DateTime.parse(d)); } catch (_) { return d; }
  }

  String _formatNum(double n) => NumberFormat('#,##0').format(n);
}

// ─── TASK TILE ───────────────────────────────────────────────
class TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final String animalName;
  final String animalEmoji;
  final VoidCallback onMarkDone;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    this.animalName = '',
    this.animalEmoji = '',
    required this.onMarkDone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final isDoneToday = task['last_done'] == today;
    final due = DateTime.tryParse(task['next_due'] ?? '') ?? DateTime.now();
    final daysUntil = due.difference(DateTime.now()).inDays;
    final isOverdue = !isDoneToday && daysUntil < 0;
    final isDueToday = !isDoneToday && daysUntil <= 0;
    final freq = task['frequency'] ?? 'daily';

    return Dismissible(
      key: Key(task['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.crimson,
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDoneToday ? AppColors.forestGhost : AppColors.white,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: isOverdue ? AppColors.crimson.withOpacity(0.3) : AppColors.creamBorder),
        ),
        child: Row(children: [
          // Check button
          GestureDetector(
            onTap: isDoneToday ? null : onMarkDone,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isDoneToday ? AppColors.forestMint : Colors.transparent,
                border: Border.all(
                  color: isDoneToday ? AppColors.forestMint : AppColors.creamBorder,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: isDoneToday ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              task['title'],
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: isDoneToday ? AppColors.inkGhost : AppColors.inkDark,
                decoration: isDoneToday ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 4),
            Row(children: [
              if (animalEmoji.isNotEmpty) Text('$animalEmoji ', style: const TextStyle(fontSize: 12)),
              _freqBadge(freq),
              const SizedBox(width: 6),
              if (!isDoneToday) Text(
                isOverdue ? 'Overdue ${(-daysUntil)}d' : isDueToday ? 'Due today' : 'In ${daysUntil}d',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: isOverdue ? AppColors.crimson : isDueToday ? AppColors.amberDeep : AppColors.inkGhost,
                ),
              ),
              if (isDoneToday) Text('Done today', style: TextStyle(fontSize: 11, color: AppColors.forestMint, fontWeight: FontWeight.w600)),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _freqBadge(String freq) {
    final configs = {
      'daily': (AppColors.forestPale, AppColors.forestMid),
      'weekly': (AppColors.sapphirePale, AppColors.sapphire),
      'monthly': (AppColors.amberPale, AppColors.amberDeep),
    };
    final (bg, fg) = configs[freq] ?? (AppColors.creamWarm, AppColors.inkLight);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Text(freq, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.3)),
    );
  }
}

// ─── SECTION HEADER ─────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
    child: Row(children: [
      Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.inkDark))),
      if (action != null) GestureDetector(
        onTap: onAction,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.forestPale,
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          child: Text(action!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.forestMid)),
        ),
      ),
    ]),
  );
}

// ─── PILL BADGE ──────────────────────────────────────────────
class PillBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const PillBadge({super.key, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
  );
}

// ─── EMPTY STATE ─────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.inkDark)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.inkGhost, height: 1.6), textAlign: TextAlign.center),
      ]),
    ),
  );
}
