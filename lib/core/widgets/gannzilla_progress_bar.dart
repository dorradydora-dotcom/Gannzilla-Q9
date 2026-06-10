import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GannZillaProgressBar extends StatefulWidget {
  final Duration duration;

  const GannZillaProgressBar({
    super.key,
    required this.duration,
  });

  @override
  State<GannZillaProgressBar> createState() => _GannZillaProgressBarState();
}

class _GannZillaProgressBarState extends State<GannZillaProgressBar> {
  double _progress = 0.0;
  Timer? _timer;
  late List<double> _progressPoints;
  int _currentStep = 0;
  late int _totalSteps;

  @override
  void initState() {
    super.initState();
    _generateRandomProgress();
    _startLoading();
  }

  void _generateRandomProgress() {
    final random = math.Random();
    const intervalMs = 100;
    _totalSteps = (widget.duration.inMilliseconds / intervalMs).round();
    if (_totalSteps < 5) _totalSteps = 5;

    // Generate random weights to create a completely unique progress path each time
    final weights = List<double>.generate(_totalSteps, (_) {
      final r = random.nextDouble();
      // Introduce pauses (slow progress) and surges (jumps) randomly
      if (r < 0.25) return random.nextDouble() * 0.1; // pause
      if (r > 0.85) return random.nextDouble() * 2.5; // surge
      return random.nextDouble() * 1.0;
    });

    final totalWeight = weights.reduce((a, b) => a + b);
    final normalized = weights.map((w) => w / totalWeight).toList();

    double cumulative = 0.0;
    _progressPoints = [];
    for (final w in normalized) {
      cumulative += w;
      _progressPoints.add(cumulative);
    }
    _progressPoints[_totalSteps - 1] = 1.0; // Ensure 100% on the final step
  }

  void _startLoading() {
    const interval = Duration(milliseconds: 100);
    _timer = Timer.periodic(interval, (timer) {
      if (_currentStep < _totalSteps) {
        if (mounted) {
          setState(() {
            _progress = _progressPoints[_currentStep];
            _currentStep++;
          });
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_progress * 100).round();

    return SizedBox(
      width: 250.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Track
          Container(
            height: 6.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: Stack(
              children: [
                // Glow layer
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 250.w * _progress,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8C00)
                            .withValues(alpha: 0.4 * _progress),
                        blurRadius: 8.r,
                        spreadRadius: 1.r,
                      ),
                    ],
                  ),
                ),
                // Gradient progress bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 250.w * _progress,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8C00), Color(0xFFFFAB40)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // Percentage text
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFFFF8C00),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0.sp,
            ),
          ),
        ],
      ),
    );
  }
}
