import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon wrapper with glow effect
                Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.2),
                        blurRadius: 30.r,
                        spreadRadius: 5.r,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 50.r,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 40.h),
                
                // Title
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                
                // Subtitle
                Text(
                  'Please check your network settings and try again. GannZilla requires an active connection to fetch real-time market data.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50.h),
                
                // Retry Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to splash to restart the initialization and connection check
                    context.go('/splash');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.5),
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(
                        'Retry Connection',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
