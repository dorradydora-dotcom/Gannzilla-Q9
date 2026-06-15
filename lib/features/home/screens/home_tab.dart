import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/gannzilla_text.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/market_data_service.dart';
import 'package:shimmer/shimmer.dart';

class HomeTab extends StatelessWidget {
  final Animation<double> glowAnim;
  const HomeTab({super.key, required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    // Market data service for tickers
    final marketDataService = MarketDataService();

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
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 0),
            child: Consumer<AuthController>(
              builder: (context, auth, _) {
                final email = auth.currentUser?.email ?? '';
                final maskedEmail = _maskEmail(email);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Logo + copyright
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GannZillaText(
                            fontSize: 24,
                            letterSpacing: 0.5,
                            isWhiteAndRed: true),
                        SizedBox(width: 2.w),
                        // © circle — superscript style
                        Padding(
                          padding: EdgeInsets.only(bottom: 9.h),
                          child: Container(
                            width: 13.r,
                            height: 13.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.textPrimary,
                                width: 1,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.all(2.r),
                                child: Text(
                                  'C',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Version
                    Transform.translate(
                      offset: Offset(0, -3.h),
                      child: Text(
                        '   V 1.121 [yakatwa]',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            " User : $maskedEmail",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textHint,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Subscription status button
                        Builder(builder: (context) {
                          final isSubscribed =
                              context.watch<AuthController>().isSubscribed;
                          final color = isSubscribed
                              ? const Color(0xFF4CAF50)
                              : AppColors.error;
                          final label =
                              isSubscribed ? 'Subscribed ✓' : 'Unsubscribed';
                          return GestureDetector(
                            onTap: () {
                              // TODO: handle subscribe / unsubscribe
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: color.withValues(alpha: 0.5),
                                    width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6.r,
                                    height: 6.r,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        ),

        // ── Market Tickers ────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 20.h, bottom: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Headline ──
                Padding(
                  padding: EdgeInsets.only(left: 20.w, bottom: 10.h),
                  child: Text(
                    'Market Top',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                // Crypto strip — static
                SizedBox(
                  height: 50.h,
                  child: StreamBuilder<List<TickerData>>(
                    stream: marketDataService.getCryptoTickersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const _TickerShimmerLoader();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _StaticTickerRow(items: snapshot.data!);
                    },
                  ),
                ),
                SizedBox(height: 10.h),
                // Forex strip — static
                SizedBox(
                  height: 50.h,
                  child: StreamBuilder<List<TickerData>>(
                    stream: marketDataService.getForexTickersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const _TickerShimmerLoader();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _StaticTickerRow(items: snapshot.data!);
                    },
                  ),
                ),
                SizedBox(height: 10.h),
                // Metals strip — static
                SizedBox(
                  height: 50.h,
                  child: StreamBuilder<List<TickerData>>(
                    stream: marketDataService.getMetalTickersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const _TickerShimmerLoader();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _StaticTickerRow(
                          items: snapshot.data!, showIcon: false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Hero Banner ───────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(30.w, 20.h, 30.w, 0),
            child: AnimatedBuilder(
              animation: glowAnim,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.teal,
                      Colors.teal,
                      Colors.black,
                      AppColors.accent
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    bottomRight: Radius.circular(40.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 216, 215, 238)
                          .withValues(alpha: glowAnim.value),
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
                              Text('Welcome to ',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color.fromARGB(
                                          235, 255, 255, 255))),
                              GannZillaText(fontSize: 20, isWhiteAndRed: true)
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            AppStrings.bannerSubtitle,
                            style: TextStyle(
                              fontSize: 10.sp,
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
                              'Subscribe Now to unlock GannZilla →',
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 10.sp,
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

        SliverToBoxAdapter(child: SizedBox(height: 96.h)),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  const SectionHeader(
      {super.key, required this.title, required this.actionLabel});

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

// ─── Shimmer Loader ────────────────────────────────────────
class _TickerShimmerLoader extends StatelessWidget {
  const _TickerShimmerLoader();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.borderSubtle,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, __) => Container(
          width: 120.w,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

// ─── Static (non-scrolling) Ticker Row ───────────────────
class _StaticTickerRow extends StatelessWidget {
  final List<TickerData> items;
  final bool showIcon;
  const _StaticTickerRow({required this.items, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(width: 10.w),
      itemBuilder: (_, i) => TickerCard(data: items[i], showIcon: showIcon),
    );
  }
}

// ─── Auto-Scrolling Ticker Marquee ───────────────────────
class TickerMarquee extends StatefulWidget {
  final List<TickerData> items;
  final double pixelsPerSecond;

  const TickerMarquee({
    super.key,
    required this.items,
    required this.pixelsPerSecond,
  });

  @override
  State<TickerMarquee> createState() => _TickerMarqueeState();
}

class _TickerMarqueeState extends State<TickerMarquee> {
  final ScrollController _controller = ScrollController();
  List<TickerData> _items = [];
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  @override
  void didUpdateWidget(TickerMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update data without resetting scroll position
    setState(() => _items = widget.items);
  }

  Future<void> _startScroll() async {
    if (_running) return;
    _running = true;
    while (mounted && _running) {
      if (!_controller.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }
      final current = _controller.offset;
      final remaining = max - current;
      if (remaining <= 0) {
        _controller.jumpTo(0);
        continue;
      }
      final durationMs = (remaining / widget.pixelsPerSecond * 1000).round();
      await _controller.animateTo(
        max,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );
      if (!mounted) break;
      _controller.jumpTo(0);
    }
    _running = false;
  }

  @override
  void dispose() {
    _running = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Repeat items 4× for a seamless infinite feel
    final repeated = [
      ..._items,
      ..._items,
      ..._items,
      ..._items,
    ];
    return ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: repeated.length,
      separatorBuilder: (_, __) => SizedBox(width: 10.w),
      itemBuilder: (_, i) => TickerCard(data: repeated[i]),
    );
  }
}

// ─── Market Ticker Card ───────────────────────────────────
class TickerCard extends StatefulWidget {
  final TickerData data;
  final bool showIcon;
  const TickerCard({super.key, required this.data, this.showIcon = true});

  @override
  State<TickerCard> createState() => _TickerCardState();
}

class _TickerCardState extends State<TickerCard> {
  Color _priceColor = AppColors.textPrimary;
  bool _isGlowing = false;
  Timer? _colorTimer;

  @override
  void didUpdateWidget(covariant TickerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.rawPrice > oldWidget.data.rawPrice) {
      setState(() {
        _priceColor = const Color(0xFF00E676); // Bright greenAccent
        _isGlowing = true;
      });
      _resetColor();
    } else if (widget.data.rawPrice < oldWidget.data.rawPrice) {
      setState(() {
        _priceColor = const Color(0xFFFF1744); // Bright redAccent
        _isGlowing = true;
      });
      _resetColor();
    }
  }

  void _resetColor() {
    _colorTimer?.cancel();
    _colorTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _priceColor = AppColors.textPrimary;
          _isGlowing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _colorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final changeColor = data.isUp ? const Color(0xFF00E676) : Colors.red;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Symbol row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showIcon) ...[
                Container(
                  width: 15.r,
                  height: 15.r,
                  decoration: BoxDecoration(
                    gradient: data.gradient,
                    shape: BoxShape.circle,
                  ),
                  child: data.logoUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            data.logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Text(
                                data.symbol
                                        .replaceAll(RegExp(r'[^a-zA-Z]'), '')
                                        .isNotEmpty
                                    ? data.symbol
                                        .replaceAll(RegExp(r'[^a-zA-Z]'), '')[0]
                                    : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            data.symbol
                                    .replaceAll(RegExp(r'[^a-zA-Z]'), '')
                                    .isNotEmpty
                                ? data.symbol
                                    .replaceAll(RegExp(r'[^a-zA-Z]'), '')[0]
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ),
                SizedBox(width: 4.w),
              ],
              Text(
                data.symbol,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Price
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: _priceColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              shadows: _isGlowing
                  ? [
                      Shadow(
                        color: _priceColor.withValues(alpha: 0.8),
                        blurRadius: 8,
                      )
                    ]
                  : [],
            ),
            child: Text(data.price),
          ),
          // Percentage badge below price
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              data.change,
              style: TextStyle(
                color: changeColor,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
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

// ── Email Masking Helper ───────────────────────────────────
String _maskEmail(String email) {
  if (email.isEmpty) return '';
  // أظهر أول 3 حروف + 5 نجوم + .com
  final prefix = email.length >= 3 ? email.substring(0, 3) : email;
  return '$prefix*****.com';
}
