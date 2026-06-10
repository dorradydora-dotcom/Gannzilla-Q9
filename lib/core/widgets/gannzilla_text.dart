import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class GannZillaText extends StatelessWidget {
  final double fontSize;
  final double letterSpacing;
  final TextStyle? style;

  const GannZillaText({
    super.key,
    required this.fontSize,
    this.letterSpacing = 0.0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: fontSize.sp,
      fontWeight: FontWeight.w900,
      letterSpacing: letterSpacing.sp,
    ).merge(style);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Gann',
            style: baseStyle.copyWith(color: Colors.white),
          ),
        ),
        Text(
          'Z',
          style: baseStyle.copyWith(color: AppColors.error),
        ),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'illa',
            style: baseStyle.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
