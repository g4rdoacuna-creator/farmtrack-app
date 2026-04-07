import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/database.dart';
import 'providers/farm_provider.dart';
import 'screens/pin_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/animals_screen.dart';
import 'screens/other_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    navigationBarColor: Colors.transparent,
    navigationBarIconBrightness: Brightness.dark,
  ));

  // Edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize DB (seeds data on first launch)
  await DatabaseHelper.instance.database;

  runApp(
    ChangeNotifierProvider(
      create: (_) => FarmProvider()..loadAll(),
      child: const FarmTrackApp(),
    ),
  );
}

class FarmTrackApp extends StatelessWidget {
  const FarmTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/pin',
      routes: {
        '/pin': (_) => PinScreen(onUnlock: () => Navigator.pushReplacementNamed(_, '/home')),
        '/home': (_) => const HomeShell(),
      },
    );
  }
}

// ─── HOME SHELL (Bottom navigation) ─────────────────────────
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    AnimalsScreen(),
    FinanceScreen(),
    TasksScreen(),
    ReportsScreen(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.pets_outlined, activeIcon: Icons.pets_rounded, label: 'Animals'),
    _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Finance'),
    _NavItem(icon: Icons.check_circle_outline_rounded, activeIcon: Icons.check_circle_rounded, label: 'Tasks'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _FarmBottomNav(
        currentIndex: _index,
        items: _navItems,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _FarmBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _FarmBottomNav({required this.currentIndex, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.creamBorder, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final active = currentIndex == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(i);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.forestPale : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      active ? item.activeIcon : item.icon,
                      size: 22,
                      color: active ? AppColors.forestMid : AppColors.inkGhost,
                    ),
                    if (active) ...[
                      const SizedBox(width: 6),
                      Text(item.label, style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.forestMid,
                      )),
                    ],
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
