import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/gannzilla_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: AppStrings.home),
    _NavItem(icon: Icons.search_rounded, label: AppStrings.search),
    _NavItem(icon: Icons.notifications_rounded, label: AppStrings.notifications),
    _NavItem(icon: Icons.person_rounded, label: AppStrings.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const _HomeTab();
      case 1:
        return const _PlaceholderTab(icon: Icons.search_rounded, label: AppStrings.search);
      case 2:
        return const _PlaceholderTab(
            icon: Icons.notifications_rounded, label: AppStrings.notifications);
      case 3:
        return const _ProfileTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      height: 72.h,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textHint,
                    size: 24.r,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textHint,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final userName = context.select<AuthController, String>(
      (auth) => auth.currentUser?.userMetadata?['full_name']
              ?.toString()
              .split(' ')
              .first ??
          'User',
    );

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.welcome}، $userName 👋',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      AppStrings.homeSubtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 46.r,
                  height: 46.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 24.r),
                ),
              ],
            ),
          ),
        ),

        // Hero Banner
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Container(
              height: 160.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20.w,
                    top: -20.h,
                    child: Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30.w,
                    bottom: -30.h,
                    child: Container(
                      width: 90.r,
                      height: 90.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppStrings.bannerTitle,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            GannZillaText(
                              fontSize: 18,
                            ),
                            Text(
                              AppStrings.bannerExclaim,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppStrings.bannerSubtitle,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white70,
                            height: 1.5,
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

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.quickActions,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.4,
                  children: const [
                    _QuickActionCard(
                      icon: Icons.currency_bitcoin_rounded,
                      label: AppStrings.crypto,
                      gradient: AppColors.cryptoGradient,
                    ),
                    _QuickActionCard(
                      icon: Icons.show_chart_rounded,
                      label: AppStrings.forex,
                      gradient: AppColors.primaryGradient,
                    ),
                    _QuickActionCard(
                      icon: Icons.newspaper_rounded,
                      label: AppStrings.news,
                      gradient: AppColors.newsGradient,
                    ),
                    _QuickActionCard(
                      icon: Icons.water_rounded,
                      label: AppStrings.whaleTrades,
                      gradient: AppColors.whaleGradient,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }
}

// ─── Quick Action Card ────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradient.colors[0].withValues(alpha: 0.35),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 30.r),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
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

// ─── Profile Tab ──────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final name = context.select<AuthController, String>(
      (auth) => auth.currentUser?.userMetadata?['full_name'] ?? 'User',
    );
    final email = context.select<AuthController, String>(
      (auth) => auth.currentUser?.email ?? '',
    );

    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          SizedBox(height: 32.h),
          // Avatar
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
          Text(email,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14.sp)),
          SizedBox(height: 40.h),
          // Logout Button
          Container(
            height: 52.h,
            width: double.infinity,
            decoration: BoxDecoration(
              border:
                  Border.all(color: AppColors.error.withValues(alpha: 0.6), width: 1.5.w),
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
        ],
      ),
    );
  }
}

// ─── Placeholder Tab ──────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.r, color: AppColors.textHint),
          SizedBox(height: 16.h),
          Text(
            label,
            style: TextStyle(
                fontSize: 18.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.comingSoon,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// ─── Nav Item Model ───────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
