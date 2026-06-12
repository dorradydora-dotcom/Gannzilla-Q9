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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: AppStrings.home),
    _NavItem(icon: Icons.search_rounded, label: AppStrings.search),
    _NavItem(icon: Icons.notifications_rounded, label: AppStrings.notifications),
    _NavItem(icon: Icons.person_rounded, label: AppStrings.profile),
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
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(child: _buildBody()),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _HomeTab(glowAnim: _glowAnim);
      case 1:
        return const _PlaceholderTab(
            icon: Icons.search_rounded, label: AppStrings.search);
      case 2:
        return const _PlaceholderTab(
            icon: Icons.notifications_rounded,
            label: AppStrings.notifications);
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glow dot indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isSelected ? 20.w : 0,
                    height: 3.h,
                    margin: EdgeInsets.only(bottom: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2.r),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.7),
                                blurRadius: 8.r,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  Icon(
                    item.icon,
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                    size: 24.r,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color:
                          isSelected ? AppColors.primary : AppColors.textHint,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
  final Animation<double> glowAnim;
  const _HomeTab({required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    final userName = context.select<AuthController, String>(
      (auth) =>
          auth.currentUser?.userMetadata?['full_name']
              ?.toString()
              .split(' ')
              .first ??
          'Trader',
    );

    // Mock market ticker data
    final tickers = [
      _TickerData('BTC', '\$104,220', '+2.4%', true, AppColors.cryptoGradient),
      _TickerData('ETH', '\$3,891', '-0.8%', false, AppColors.primaryGradient),
      _TickerData('BNB', '\$712', '+1.1%', true, AppColors.newsGradient),
      _TickerData('SOL', '\$188', '+5.2%', true, AppColors.whaleGradient),
    ];

    // Mock whale alerts
    final whaleAlerts = [
      _WhaleAlert('🐋', 'BTC', '12,400 BTC', 'Transferred to Binance', '2m ago',
          Colors.orange),
      _WhaleAlert('🐳', 'ETH', '86,000 ETH', 'Moved to cold wallet', '11m ago',
          AppColors.primary),
      _WhaleAlert('🦈', 'USDT', '\$320M', 'Minted on Tron', '34m ago',
          AppColors.accent),
    ];

    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────
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
                      'Hey, $userName 👋',
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
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Notification bell + avatar
                Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgCard,
                        border: Border.all(
                            color: AppColors.borderSubtle, width: 1.5),
                      ),
                      child: Icon(Icons.notifications_outlined,
                          color: AppColors.textSecondary, size: 20.r),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                      ),
                      child:
                          Icon(Icons.person, color: Colors.white, size: 20.r),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Market Ticker Horizontal Strip ───────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: SizedBox(
              height: 88.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: tickers.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, i) => _TickerCard(data: tickers[i]),
              ),
            ),
          ),
        ),

        // ── Hero Banner ───────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
            child: AnimatedBuilder(
              animation: glowAnim,
              builder: (_, __) => Container(
                height: 150.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: glowAnim.value),
                      blurRadius: 28.r,
                      spreadRadius: 2.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -20.w,
                      top: -20.h,
                      child: Container(
                        width: 110.r,
                        height: 110.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 35.w,
                      bottom: -35.h,
                      child: Container(
                        width: 80.r,
                        height: 80.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
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
                                'Welcome to ',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              GannZillaText(fontSize: 17),
                              Text(
                                ' ⚡',
                                style: TextStyle(
                                  fontSize: 17.sp,
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
                              fontSize: 12.sp,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'Explore Now →',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
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
        ),

        // ── Quick Actions ────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: AppStrings.quickActions,
                  actionLabel: 'See all',
                ),
                SizedBox(height: 16.h),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                  childAspectRatio: 1.35,
                  children: const [
                    _QuickActionCard(
                      icon: Icons.currency_bitcoin_rounded,
                      label: AppStrings.crypto,
                      subtitle: 'Live prices & charts',
                      gradient: AppColors.cryptoGradient,
                    ),
                    _QuickActionCard(
                      icon: Icons.show_chart_rounded,
                      label: AppStrings.forex,
                      subtitle: 'FX pairs & signals',
                      gradient: AppColors.primaryGradient,
                    ),
                    _QuickActionCard(
                      icon: Icons.newspaper_rounded,
                      label: AppStrings.news,
                      subtitle: 'Breaking market news',
                      gradient: AppColors.newsGradient,
                    ),
                    _QuickActionCard(
                      icon: Icons.water_rounded,
                      label: AppStrings.whaleTrades,
                      subtitle: 'Track smart money',
                      gradient: AppColors.whaleGradient,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Whale Activity Feed ───────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: '🐋 Whale Activity',
                  actionLabel: 'View all',
                ),
                SizedBox(height: 12.h),
                ...whaleAlerts
                    .map((alert) => _WhaleAlertTile(data: alert)),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 32.h)),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  const _SectionHeader({required this.title, required this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          actionLabel,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Market Ticker Card ───────────────────────────────────
class _TickerData {
  final String symbol;
  final String price;
  final String change;
  final bool isUp;
  final LinearGradient gradient;
  const _TickerData(
      this.symbol, this.price, this.change, this.isUp, this.gradient);
}

class _TickerCard extends StatelessWidget {
  final _TickerData data;
  const _TickerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final changeColor = data.isUp ? const Color(0xFF4CAF50) : AppColors.error;
    return Container(
      width: 120.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  gradient: data.gradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    data.symbol[0],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                data.symbol,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.price,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      data.isUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: changeColor,
                      size: 10.r,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      data.change,
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Card ────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: gradient.colors[0].withValues(alpha: 0.3),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22.r),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Whale Alert Data & Tile ──────────────────────────────
class _WhaleAlert {
  final String emoji;
  final String coin;
  final String amount;
  final String description;
  final String time;
  final Color color;
  const _WhaleAlert(this.emoji, this.coin, this.amount, this.description,
      this.time, this.color);
}

class _WhaleAlertTile extends StatelessWidget {
  final _WhaleAlert data;
  const _WhaleAlertTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(data.emoji, style: TextStyle(fontSize: 22.sp)),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.coin,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: data.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        data.amount,
                        style: TextStyle(
                          color: data.color,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  data.description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.time,
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 11.sp,
            ),
          ),
        ],
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
      (auth) => auth.currentUser?.userMetadata?['full_name'] ?? 'Trader',
    );
    final email = context.select<AuthController, String>(
      (auth) => auth.currentUser?.email ?? '',
    );

    final settingsRows = [
      _SettingsRow(Icons.notifications_outlined, 'Notifications', AppColors.primary),
      _SettingsRow(Icons.security_outlined, 'Security & Privacy', AppColors.accent),
      _SettingsRow(Icons.language_outlined, 'Language', AppColors.newsGradient.colors[0]),
      _SettingsRow(Icons.help_outline_rounded, 'Help & Support', AppColors.textHint),
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
                        top: i == 0
                            ? Radius.circular(20.r)
                            : Radius.zero,
                        bottom: isLast
                            ? Radius.circular(20.r)
                            : Radius.zero,
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
                              child: Icon(row.icon, color: row.color, size: 18.r),
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

class _SettingsRow {
  final IconData icon;
  final String label;
  final Color color;
  const _SettingsRow(this.icon, this.label, this.color);
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
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Icon(icon, size: 36.r, color: AppColors.textHint),
          ),
          SizedBox(height: 20.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.comingSoon,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textHint),
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
