import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import 'home_tab.dart';
import 'market_tab.dart';
import 'favourite_tab.dart';
import 'gann_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.show_chart_rounded, label: 'Market'),
    _NavItem(icon: Icons.star_rounded, label: 'Favourite'),
    _NavItem(icon: Icons.grid_3x3_rounded, label: 'Gann'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: SafeArea(
        bottom: false,
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeTab(glowAnim: _glowAnim);
      case 1:
        return const MarketTab();
      case 2:
        return const FavouriteTab();
      case 3:
        return const GannTab();
      case 4:
        return const ProfileTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav() {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Container(
      margin: EdgeInsets.only(
        left: 5.w,
        right: 5.w,
        bottom: bottomPadding > 0 ? bottomPadding + 4.h : 8.h,
      ),
      height: 50.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
              color: const Color.fromARGB(255, 63, 63, 127), width: 1.w)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glow dot indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isSelected ? 16.w : 0,
                    height: 3.h,
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(2.r),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.textPrimary
                                    .withValues(alpha: 0.7),
                                blurRadius: 8.r,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  Icon(
                    item.icon,
                    color: isSelected ? Colors.white : AppColors.textHint,
                    size: 20.r,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: isSelected ? Colors.white : AppColors.textHint,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
