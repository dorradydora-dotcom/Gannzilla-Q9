import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final name = context.select<AuthController, String>(
      (auth) => auth.currentUser?.userMetadata?['full_name'] ?? 'Trader',
    );
    final email = context.select<AuthController, String>(
      (auth) => auth.currentUser?.email ?? '',
    );

    final settingsRows = [
      SettingsRow(
          Icons.notifications_outlined, 'Notifications', AppColors.primary),
      SettingsRow(
          Icons.security_outlined, 'Security & Privacy', AppColors.accent),
      SettingsRow(Icons.language_outlined, 'Language',
          AppColors.newsGradient.colors[0]),
      SettingsRow(
          Icons.help_outline_rounded, 'Help & Support', AppColors.textHint),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),

          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90.r,
                height: 90.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20.r,
                    ),
                  ],
                ),
                child: Icon(Icons.person, color: Colors.white, size: 48.r),
              ),
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                ),
                child: Icon(Icons.edit_rounded,
                    color: AppColors.primary, size: 14.r),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            email,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
          ),

          SizedBox(height: 8.h),
          // Verified badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded,
                    color: const Color(0xFF4CAF50), size: 14.r),
                SizedBox(width: 4.w),
                Text(
                  'Verified Account',
                  style: TextStyle(
                    color: const Color(0xFF4CAF50),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // Settings rows
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: List.generate(settingsRows.length, (i) {
                final row = settingsRows[i];
                final isLast = i == settingsRows.length - 1;
                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.vertical(
                        top: i == 0 ? Radius.circular(20.r) : Radius.zero,
                        bottom: isLast ? Radius.circular(20.r) : Radius.zero,
                      ),
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 16.h),
                        child: Row(
                          children: [
                            Container(
                              width: 36.r,
                              height: 36.r,
                              decoration: BoxDecoration(
                                color: row.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child:
                                  Icon(row.icon, color: row.color, size: 18.r),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Text(
                                row.label,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: AppColors.textHint, size: 20.r),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                          height: 1,
                          color: AppColors.borderSubtle,
                          indent: 70.w),
                  ],
                );
              }),
            ),
          ),

          SizedBox(height: 24.h),

          // Logout Button
          Container(
            height: 52.h,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.6), width: 1.5.w),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: () => auth.signOut(),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded,
                          color: AppColors.error, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(
                        AppStrings.logout,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class SettingsRow {
  final IconData icon;
  final String label;
  final Color color;
  const SettingsRow(this.icon, this.label, this.color);
}
