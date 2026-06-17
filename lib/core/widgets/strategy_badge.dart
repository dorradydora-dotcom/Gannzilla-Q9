import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/market_data_service.dart';

class StrategyBadge extends StatefulWidget {
  final StrategyInfo info;

  const StrategyBadge({super.key, required this.info});

  @override
  State<StrategyBadge> createState() => _StrategyBadgeState();
}

class _StrategyBadgeState extends State<StrategyBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    // Light heartbeat speed
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final double intensity = _pulseAnim.value;
        // Very subtle scale pulse: 0.98 to 1.04
        final double scale = 0.98 + (0.06 * intensity);

        return Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.info.label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.info.color,
                  fontSize: 5.5.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: widget.info.color.withValues(alpha: 0.6 + (0.3 * intensity)),
                      blurRadius: 6.r + (4.r * intensity),
                    ),
                    Shadow(
                      color: widget.info.color.withValues(alpha: 0.3 + (0.2 * intensity)),
                      blurRadius: 12.r + (6.r * intensity),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Icon(
                widget.info.icon,
                color: widget.info.color,
                size: 11.r,
                shadows: [
                  Shadow(
                    color: widget.info.color.withValues(alpha: 0.6 + (0.3 * intensity)),
                    blurRadius: 6.r + (4.r * intensity),
                  ),
                  Shadow(
                    color: widget.info.color.withValues(alpha: 0.3 + (0.2 * intensity)),
                    blurRadius: 12.r + (6.r * intensity),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
