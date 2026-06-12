import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/gannzilla_text.dart';

class HomeTab extends StatelessWidget {
  final Animation<double> glowAnim;
  const HomeTab({super.key, required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    // Mock market ticker data
    final tickers = [
      TickerData('BTC', '\$104,220', '+2.4%', true, AppColors.cryptoGradient),
      TickerData('ETH', '\$3,891', '-0.8%', false, AppColors.primaryGradient),
      TickerData('BNB', '\$712', '+1.1%', true, AppColors.newsGradient),
      TickerData('SOL', '\$188', '+5.2%', true, AppColors.whaleGradient),
    ];

    // Mock whale alerts
    final whaleAlerts = [
      WhaleAlert('🐋', 'BTC', '12,400 BTC', 'Transferred to Binance', '2m ago',
          Colors.orange),
      WhaleAlert('🐳', 'ETH', '86,000 ETH', 'Moved to cold wallet', '11m ago',
          AppColors.primary),
      WhaleAlert('🦈', 'USDT', '\$320M', 'Minted on Tron', '34m ago',
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
                      'Dashboard',
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
                itemBuilder: (context, i) => TickerCard(data: tickers[i]),
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
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.primary.withValues(alpha: glowAnim.value),
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
                        mainAxisSize: MainAxisSize.min,
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
                          SizedBox(height: 2.h),
                          Text(
                            AppStrings.bannerSubtitle,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 4.h),
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
                SectionHeader(
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
                    QuickActionCard(
                      icon: Icons.currency_bitcoin_rounded,
                      label: AppStrings.crypto,
                      subtitle: 'Live prices & charts',
                      gradient: AppColors.cryptoGradient,
                    ),
                    QuickActionCard(
                      icon: Icons.show_chart_rounded,
                      label: AppStrings.forex,
                      subtitle: 'FX pairs & signals',
                      gradient: AppColors.primaryGradient,
                    ),
                    QuickActionCard(
                      icon: Icons.newspaper_rounded,
                      label: AppStrings.news,
                      subtitle: 'Breaking market news',
                      gradient: AppColors.newsGradient,
                    ),
                    QuickActionCard(
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
                SectionHeader(
                  title: '🐋 Whale Activity',
                  actionLabel: 'View all',
                ),
                SizedBox(height: 12.h),
                ...whaleAlerts.map((alert) => WhaleAlertTile(data: alert)),
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
class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  const SectionHeader({super.key, required this.title, required this.actionLabel});

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
class TickerData {
  final String symbol;
  final String price;
  final String change;
  final bool isUp;
  final LinearGradient gradient;
  const TickerData(
      this.symbol, this.price, this.change, this.isUp, this.gradient);
}

class TickerCard extends StatelessWidget {
  final TickerData data;
  const TickerCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final changeColor = data.isUp ? const Color(0xFF4CAF50) : AppColors.error;
    return Container(
      width: 120.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;

  const QuickActionCard({
    super.key,
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
class WhaleAlert {
  final String emoji;
  final String coin;
  final String amount;
  final String description;
  final String time;
  final Color color;
  const WhaleAlert(this.emoji, this.coin, this.amount, this.description,
      this.time, this.color);
}

class WhaleAlertTile extends StatelessWidget {
  final WhaleAlert data;
  const WhaleAlertTile({super.key, required this.data});

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
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
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
