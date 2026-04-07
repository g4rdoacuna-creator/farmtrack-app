import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/database.dart';

class PinScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  final bool isSetup;

  const PinScreen({super.key, required this.onUnlock, this.isSetup = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with TickerProviderStateMixin {
  String _entered = '';
  bool _isError = false;
  bool _isSuccess = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyTap(String digit) {
    if (_entered.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() => _entered += digit);
    if (_entered.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), _verify);
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _verify() async {
    final storedPin = await DatabaseHelper.instance.getSetting('pin') ?? '1234';
    if (_entered == storedPin) {
      HapticFeedback.mediumImpact();
      setState(() => _isSuccess = true);
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onUnlock();
    } else {
      HapticFeedback.vibrate();
      setState(() { _isError = true; });
      _shakeController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() { _entered = ''; _isError = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestDeep,
      body: SafeArea(
        child: Column(children: [
          const Spacer(flex: 2),
          // Logo
          Animate(
            effects: [FadeEffect(duration: 600.ms), SlideEffect(begin: const Offset(0, -0.2), end: Offset.zero, duration: 600.ms)],
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.white.withOpacity(0.15), width: 1),
                ),
                child: const Center(child: Text('🌾', style: TextStyle(fontSize: 44))),
              ),
              const SizedBox(height: 20),
              Text('FarmTrack', style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.white,
                letterSpacing: -0.5, fontFamily: 'Plus Jakarta Sans',
              )),
              const SizedBox(height: 6),
              Text(widget.isSetup ? 'Set your PIN' : 'Enter your PIN',
                style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.55), fontWeight: FontWeight.w500)),
            ]),
          ),
          const Spacer(),
          // PIN dots
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final shake = (_shakeController.value * 10).sin * 12;
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _entered.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isError
                        ? AppColors.crimson
                        : _isSuccess
                            ? AppColors.forestMint
                            : filled
                                ? AppColors.white
                                : Colors.transparent,
                    border: Border.all(
                      color: _isError
                          ? AppColors.crimson
                          : filled ? AppColors.white : AppColors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
          ),
          const Spacer(),
          // Numpad
          Animate(
            effects: [FadeEffect(delay: 200.ms, duration: 500.ms), SlideEffect(begin: const Offset(0, 0.2), delay: 200.ms, duration: 500.ms)],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(children: [
                _numRow(['1', '2', '3']),
                const SizedBox(height: 16),
                _numRow(['4', '5', '6']),
                const SizedBox(height: 16),
                _numRow(['7', '8', '9']),
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(child: SizedBox()),
                  _numKey('0'),
                  Expanded(
                    child: GestureDetector(
                      onTap: _onBackspace,
                      child: Container(
                        height: 68,
                        alignment: Alignment.center,
                        child: Icon(Icons.backspace_outlined, color: AppColors.white.withOpacity(0.7), size: 24),
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('Default PIN: 1234', style: TextStyle(
              fontSize: 12, color: AppColors.white.withOpacity(0.3), fontWeight: FontWeight.w500,
            )),
          ),
        ]),
      ),
    );
  }

  Widget _numRow(List<String> digits) => Row(
    children: digits.map((d) => _numKey(d)).toList(),
  );

  Widget _numKey(String digit) => Expanded(
    child: GestureDetector(
      onTap: () => _onKeyTap(digit),
      child: Container(
        height: 68,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.white.withOpacity(0.08)),
        ),
        alignment: Alignment.center,
        child: Text(digit, style: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.white,
          fontFamily: 'Plus Jakarta Sans',
        )),
      ),
    ),
  );
}

extension _Sin on double {
  double get sin => 0 == this ? 0 : (this * 3.14159 / 180).toDouble() * (1 - this * 0.001);
}
