import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../providers/farm_provider.dart';
import '../widgets/shared_widgets.dart';
import 'animals_screen.dart';
import 'tasks_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(builder: (context, farm, _) {
      if (farm.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.forestMint));
      final summary = farm.totalSummary;
      final fmt = NumberFormat('#,##0');
      final cur = farm.currency;
      final dueTasks = farm.dueTodayTasks;
      final upcoming = farm.upcomingTasks.take(4).toList();
      final monthlyData = farm.monthlyData;

      return RefreshIndicator(
        onRefresh: farm.loadAll,
        color: AppColors.forestMid,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.cream,
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(child: Text('🌾', style: const TextStyle(fontSize: 24))),
              ),
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(farm.farmName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.inkDark)),
                Text(DateFormat('EEE, MMM d').format(DateTime.now()),
                  style: const TextStyle(fontSize: 12, color: AppColors.inkGhost, fontWeight: FontWeight.w500)),
              ]),
              actions: [
                if (dueTasks.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.crimsonPale, borderRadius: BorderRadius.circular(Radii.pill)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text('🔔', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('${dueTasks.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.crimson)),
                    ]),
                  ),
                const SizedBox(width: 8),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(delegate: SliverChildListDelegate([
                // Profit hero card
                Animate(
                  effects: [FadeEffect(duration: 400.ms), SlideEffect(begin: const Offset(0, 0.1), duration: 400.ms)],
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.forestMid,
                      borderRadius: BorderRadius.circular(Radii.xxl),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [AppColors.forestLight, AppColors.forestDeep],
                      ),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(Radii.pill)),
                          child: Text('Total Profit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.white.withOpacity(0.85), letterSpacing: 0.5)),
                        ),
                        const Spacer(),
                        Text('All Batches', style: TextStyle(fontSize: 11, color: AppColors.white.withOpacity(0.45))),
                      ]),
                      const SizedBox(height: 16),
                      Text(
                        '${summary['profit']! >= 0 ? '' : '-'}$cur${fmt.format(summary['profit']!.abs())}',
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.white, letterSpacing: -1.5),
                      ),
                      const SizedBox(height: 20),
                      Row(children: [
                        _heroStat('Income', '$cur${fmt.format(summary['income']!)}', AppColors.forestMint),
                        const SizedBox(width: 24),
                        _heroStat('Expenses', '$cur${fmt.format(summary['expense']!)}', AppColors.amber),
                        const Spacer(),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${farm.activeBatchCount}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.white)),
                          Text('active batches', style: TextStyle(fontSize: 11, color: AppColors.white.withOpacity(0.5))),
                        ]),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // Animal cards
                Animate(
                  effects: [FadeEffect(delay: 100.ms, duration: 400.ms)],
                  child: SectionHeader(
                    title: 'Animal Overview',
                    action: 'See All',
                    onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnimalsScreen())),
                  ),
                ),
                ...farm.animals.asMap().entries.map((entry) {
                  final i = entry.key;
                  final a = entry.value;
                  final batches = farm.batchesForAnimal(a['id']);
                  final activeBatches = batches.where((b) => b['status'] == 'active').length;
                  return FutureBuilder<Map<String, double>>(
                    future: farm.summaryForAnimal(a['id']),
                    builder: (context, snap) {
                      final s = snap.data ?? {'income': 0, 'expense': 0, 'profit': 0};
                      return Animate(
                        effects: [FadeEffect(delay: Duration(milliseconds: 150 + i * 60), duration: 400.ms),
                          SlideEffect(begin: const Offset(0, 0.1), delay: Duration(milliseconds: 150 + i * 60), duration: 400.ms)],
                        child: AnimalCard(
                          animal: a,
                          income: '$cur${fmt.format(s['income']!)}',
                          expense: '$cur${fmt.format(s['expense']!)}',
                          profit: '${s['profit']! >= 0 ? '+' : '-'}$cur${fmt.format(s['profit']!.abs())}',
                          isProfit: (s['profit'] ?? 0) >= 0,
                          batchCount: batches.length,
                          activeBatchCount: activeBatches,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => AnimalDetailScreen(animalId: a['id']),
                          )),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 8),

                // Upcoming tasks
                Animate(
                  effects: [FadeEffect(delay: 300.ms, duration: 400.ms)],
                  child: SectionHeader(
                    title: 'Upcoming Tasks',
                    action: 'All Tasks',
                    onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksScreen())),
                  ),
                ),
                if (upcoming.isEmpty)
                  Animate(
                    effects: [FadeEffect(delay: 350.ms, duration: 300.ms)],
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.forestGhost, borderRadius: BorderRadius.circular(Radii.xl)),
                      child: const Row(children: [
                        Text('🎉', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 12),
                        Expanded(child: Text('All caught up! No tasks due soon.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.forestMid))),
                      ]),
                    ),
                  )
                else
                  ...upcoming.asMap().entries.map((e) {
                    final t = e.value;
                    final animal = farm.getAnimal(t['animal_id'] ?? '');
                    return Animate(
                      effects: [FadeEffect(delay: Duration(milliseconds: 350 + e.key * 50), duration: 300.ms)],
                      child: TaskTile(
                        task: t,
                        animalName: animal?['name'] ?? '',
                        animalEmoji: animal?['emoji'] ?? '',
                        onMarkDone: () => farm.markTaskDone(t['id']),
                        onDelete: () => farm.deleteTask(t['id']),
                      ),
                    );
                  }),
                const SizedBox(height: 24),

                // Income vs Expense chart
                Animate(
                  effects: [FadeEffect(delay: 400.ms, duration: 400.ms)],
                  child: SectionHeader(title: 'Income vs Expense', action: null),
                ),
                Animate(
                  effects: [FadeEffect(delay: 450.ms, duration: 400.ms)],
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(Radii.xl),
                      border: Border.all(color: AppColors.creamBorder),
                    ),
                    child: Column(children: [
                      SizedBox(
                        height: 180,
                        child: monthlyData.isEmpty
                          ? const Center(child: Text('No data yet'))
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: monthlyData.fold<double>(0, (m, e) => (e['income'] as double) > m ? e['income'] : ((e['expense'] as double) > m ? e['expense'] : m)) * 1.2 + 1,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                                    final idx = v.toInt();
                                    if (idx < 0 || idx >= monthlyData.length) return const SizedBox();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(monthlyData[idx]['label'], style: const TextStyle(fontSize: 10, color: AppColors.inkGhost)),
                                    );
                                  }, reservedSize: 24)),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(show: true, drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.creamBorder, strokeWidth: 1)),
                                borderData: FlBorderData(show: false),
                                barGroups: monthlyData.asMap().entries.map((e) {
                                  final i = e.key;
                                  final d = e.value;
                                  return BarChartGroupData(x: i, barRods: [
                                    BarChartRodData(toY: (d['income'] as double), color: AppColors.forestMint, width: 10, borderRadius: BorderRadius.circular(4)),
                                    BarChartRodData(toY: (d['expense'] as double), color: AppColors.amber, width: 10, borderRadius: BorderRadius.circular(4)),
                                  ]);
                                }).toList(),
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _legend(AppColors.forestMint, 'Income'),
                        const SizedBox(width: 20),
                        _legend(AppColors.amber, 'Expense'),
                      ]),
                    ]),
                  ),
                ),
              ])),
            ),
          ],
        ),
      );
    });
  }

  Widget _heroStat(String label, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontWeight: FontWeight.w600)),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
    ],
  );

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontSize: 12, color: AppColors.inkLight, fontWeight: FontWeight.w600)),
  ]);
}
