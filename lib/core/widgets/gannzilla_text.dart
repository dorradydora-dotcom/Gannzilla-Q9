import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class GannZillaText extends StatelessWidget {
  final double fontSize;
  final double letterSpacing;
  final TextStyle? style;
  final bool isWhiteAndRed;

  const GannZillaText({
    super.key,
    required this.fontSize,
    this.letterSpacing = 0.0,
    this.style,
    this.isWhiteAndRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: fontSize.sp,
      fontWeight: FontWeight.w900,
      letterSpacing: letterSpacing.sp,
    ).merge(style);

    final gannPart = Text(
      'Gann',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: fontSize.sp,
      ),
    );

    final illaPart = Text(
      'illa',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: fontSize.sp,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        isWhiteAndRed
            ? gannPart
            : ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: gannPart,
              ),
        Text(
          'Z',
          style: baseStyle.copyWith(color: AppColors.error),
        ),
        isWhiteAndRed
            ? illaPart
            : ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: illaPart,
              ),
      ],
    );
  }
}
