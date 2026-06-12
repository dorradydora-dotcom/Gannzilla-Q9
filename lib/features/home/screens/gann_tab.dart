import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

class GannTab extends StatelessWidget {
  const GannTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {
        'title': 'Gann Square of 9',
        'desc': 'Calculate support, resistance, and key turning points using the Square of Nine matrix.',
        'icon': Icons.grid_4x4_rounded,
        'gradient': AppColors.cryptoGradient
      },
      {
        'title': 'Gann Fan & Angles',
        'desc': 'Plot dynamic geometric trendlines based on time-and-price equivalence.',
        'icon': Icons.trending_up_rounded,
        'gradient': AppColors.primaryGradient
      },
      {
        'title': 'Gann Hexagon Chart',
        'desc': 'Discover cyclical time frames and coordinates for major market movements.',
        'icon': Icons.hexagon_outlined,
        'gradient': AppColors.newsGradient
      },
      {
        'title': 'Price-Time Calculator',
        'desc': 'Align market highs/lows against key astronomical or numeric angles.',
        'icon': Icons.calculate_outlined,
        'gradient': AppColors.whaleGradient
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gann Tools',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgCard,
                  border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                ),
                child: Icon(Icons.info_outline_rounded,
                    color: AppColors.textSecondary, size: 20.r),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Technical analysis modules inspired by W.D. Gann\'s price and time theories.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20.h),

          // Tools list
          Expanded(
            child: ListView.separated(
              itemCount: tools.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final tool = tools[index];
                return Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon wrapper
                      Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: tool['gradient'] as LinearGradient,
                        ),
                        child: Icon(
                          tool['icon'] as IconData,
                          color: Colors.white,
                          size: 22.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tool['title'] as String,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              tool['desc'] as String,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.sp,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textHint,
                        size: 20.r,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
