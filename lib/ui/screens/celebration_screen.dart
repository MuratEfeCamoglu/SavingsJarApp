import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/jar_model.dart';
import '../../core/theme.dart';

class CelebrationScreen extends StatefulWidget {
  final JarModel jar;

  const CelebrationScreen({Key? key, required this.jar}) : super(key: key);

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Goal Accomplished',
                          style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Congratulations!\nYou did it!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: const Icon(
                              Icons.stars,
                              size: 160,
                              color: Colors.orangeAccent,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Text('FINAL TOTAL ACHIEVED', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text(widget.jar.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text(
                          '\$${widget.jar.targetAmount.toStringAsFixed(2)} Saved',
                          style: const TextStyle(
                            color: AppTheme.accentGreen,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const LinearProgressIndicator(
                          value: 1.0,
                          backgroundColor: AppTheme.background,
                          color: AppTheme.accentGreen,
                          minHeight: 12,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: AppTheme.accentGreen, size: 16),
                                SizedBox(width: 4),
                                Text('100%', style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text('Target Reached', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _confettiController.play();
                      },
                      icon: const Icon(Icons.celebration),
                      label: const Text('Celebrate Again'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Start New Goal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
              createParticlePath: drawStar,
            ),
          ],
        ),
      ),
    );
  }

  Path drawStar(Size size) {
    const int points = 5;
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double outerR = cx;
    final double innerR = cx / 2.5;
    const double startAngle = -3.141592653589793 / 2; // top
    const double step = 3.141592653589793 / points;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? outerR : innerR;
      final double angle = startAngle + i * step;
      final double x = cx + r * _cos(angle);
      final double y = cy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // Inline trig to avoid dart:math import bloat
  double _cos(double rad) => _sinCos(rad, false);
  double _sin(double rad) => _sinCos(rad, true);
  double _sinCos(double rad, bool isSin) {
    // Normalise to [-π, π]
    while (rad > 3.141592653589793) rad -= 2 * 3.141592653589793;
    while (rad < -3.141592653589793) rad += 2 * 3.141592653589793;
    // Taylor series (accurate enough for 5-star rendering)
    double result = isSin ? rad : 1.0;
    double term = isSin ? rad : 1.0;
    final double r2 = rad * rad;
    for (int n = 1; n <= 7; n++) {
      term *= r2 / ((2 * n) * (2 * n + (isSin ? 1 : -1)));
      term = -term;
      result += term;
    }
    return result;
  }
}
