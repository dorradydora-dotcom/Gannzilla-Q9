import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/gannzilla_text.dart';
import '../../../core/widgets/strategy_badge.dart';
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
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15.h),
                          // App Logo + copyright
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GannZillaText(
                                  fontSize: 30,
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
                              _AdminCounterWidget(email: email),
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
                                final isSubscribed = context
                                    .watch<AuthController>()
                                    .isSubscribed;
                                final color = isSubscribed
                                    ? const Color(0xFF4CAF50)
                                    : AppColors.error;
                                final label = isSubscribed
                                    ? 'Subscribed ✓'
                                    : 'Unsubscribed';
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
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Live stats box
                    const PlatformStatsBox(),
                  ],
                );
              },
            ),
          ),
        ),

        // ── Market Tickers ────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 6.h, bottom: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // News Ticker
                const NewsMarqueeWidget(),
                SizedBox(height: 2.h),
                // ── Headline ──
                Padding(
                  padding: EdgeInsets.only(left: 20.w, bottom: 4.h),
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
                SizedBox(height: 2.h),
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
                SizedBox(height: 2.h),
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
            padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 0),
            child: AnimatedBuilder(
              animation: glowAnim,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF101828), // Very dark navy
                      Color(0xFF1D2939), // Dark slate gray
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFD4AF37)
                        .withValues(alpha: 0.15 + (glowAnim.value * 0.15)),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 15.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30.w,
                      top: -10.h,
                      child: Icon(
                        Icons.trending_up_rounded,
                        size: 140.r,
                        color: Colors.white.withValues(alpha: 0.03),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text('Welcome to ',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  )),
                              GannZillaText(fontSize: 16, isWhiteAndRed: true)
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Professional grade tools for crypto & forex markets',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white60,
                              height: 1.4,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD4AF37), // Gold
                                  Color(0xFFAA771C), // Dark Gold
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 3.h),
                                ),
                              ],
                            ),
                            child: Text(
                              'Upgrade to Premium',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
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
            padding: EdgeInsets.fromLTRB(24.w, 6.h, 24.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: AppStrings.headSectors),
                SizedBox(height: 2.h),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 0.85,
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
                      icon: Icons.diamond_rounded,
                      label: AppStrings.metals,
                      subtitle: 'Gold, Silver & more',
                      gradient: AppColors.metalsGradient,
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
            padding: EdgeInsets.fromLTRB(24.w, 6.h, 24.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with See All button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionHeader(title: '🐋 Whale Activity'),
                    GestureDetector(
                      onTap: () => context.push('/whale-feed?tab=0'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'See All',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: AppColors.primary, size: 9.r),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/whale-feed?tab=0'),
                        child: _WhaleColumn(
                          label: 'Forex',
                          icon: Icons.show_chart_rounded,
                          color: const Color(0xFF2196F3),
                          symbols: const [
                            'EUR/USD',
                            'GBP/JPY',
                            'USD/CHF',
                            'AUD/USD',
                            'USD/JPY',
                            'USD/CAD',
                          ],
                          basePrices: const [
                            1.0842,
                            197.34,
                            0.8961,
                            0.6512,
                            157.82,
                            1.3641,
                          ],
                          unit: 'M',
                          interval: const Duration(milliseconds: 1800),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/whale-feed?tab=1'),
                        child: _WhaleColumn(
                          label: 'Crypto',
                          icon: Icons.currency_bitcoin_rounded,
                          color: Colors.orange,
                          symbols: const [
                            'BTC',
                            'ETH',
                            'SOL',
                            'BNB',
                            'XRP',
                            'DOGE',
                          ],
                          basePrices: const [
                            67400.0,
                            3520.0,
                            172.5,
                            588.0,
                            0.5231,
                            0.1642,
                          ],
                          unit: 'K',
                          interval: const Duration(milliseconds: 1400),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/whale-feed?tab=2'),
                        child: _WhaleColumn(
                          label: 'Metals',
                          icon: Icons.diamond_rounded,
                          color: const Color(0xFFD4AF37),
                          symbols: const [
                            'XAU/USD',
                            'XAG/USD',
                            'XPT/USD',
                            'XPD/USD',
                            'COPPER',
                            'WTI',
                          ],
                          basePrices: const [
                            2324.5,
                            28.74,
                            961.0,
                            1012.0,
                            4.523,
                            78.42,
                          ],
                          unit: 'oz',
                          interval: const Duration(milliseconds: 2500),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Signals Section ───────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
            child: Consumer<AuthController>(
              builder: (context, auth, _) {
                final email = auth.currentUser?.email ?? '';
                return _SignalsFeed(adminEmail: email);
              },
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

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ))
    ]);
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
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE0E0E0), // Light silver
              Color(0xFF757575), // Dark silver
              Color(0xFFFFFFFF), // Bright reflection
              Color(0xFF9E9E9E), // Medium silver
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        padding: const EdgeInsets.all(0.6), // Shiny border width
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15.r),
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        color: AppColors.textHint.withValues(alpha: 0.5),
                        size: 14.r,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    gradient.colors[0].withValues(alpha: 0.4),
                                blurRadius: 8.r,
                                offset: Offset(0, 3.h),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: Colors.white, size: 14.r),
                        ),
                        SizedBox(height: 8.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 7.sp,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
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

// ─── Whale Column — live animated trade feed ──────────────
class _WhaleColumn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final List<String> symbols;
  final List<double> basePrices;
  final String unit;
  final Duration interval;

  const _WhaleColumn({
    required this.label,
    required this.icon,
    required this.color,
    required this.symbols,
    required this.basePrices,
    required this.unit,
    required this.interval,
  });

  @override
  State<_WhaleColumn> createState() => _WhaleColumnState();
}

class _WhaleColumnState extends State<_WhaleColumn> {
  final List<WhaleTrade> _trades = [];
  Timer? _timer;
  Timer? _priceUpdateTimer;
  Timer? _fallbackTimer;
  StreamSubscription<WhaleTrade>? _socketSub;
  final Random _rnd = Random();
  static const int _maxTrades = 7;
  late List<double> _livePrices;

  bool get _isWeekend {
    final day = DateTime.now().weekday;
    return day == DateTime.saturday || day == DateTime.sunday;
  }

  @override
  void initState() {
    super.initState();
    _livePrices = List<double>.from(widget.basePrices);
    // seed 8 initial trades instantly
    for (int i = 0; i < 8; i++) {
      _trades.insert(0, _newTrade());
    }

    final labelLower = widget.label.toLowerCase();
    if (labelLower == 'crypto') {
      _fallbackTimer = Timer(const Duration(seconds: 4), () {
        if (!mounted) return;
        _timer = Timer.periodic(widget.interval, (_) => _addTrade());
      });
      _socketSub = WhalePriceService.getCryptoWhaleTradesStream(widget.symbols)
          .listen((trade) {
        if (!mounted) return;
        _fallbackTimer?.cancel();
        setState(() {
          _trades.insert(0, trade);
          if (_trades.length > _maxTrades) {
            _trades.removeLast();
          }
        });
      });
    } else {
      // start live feed
      _timer = Timer.periodic(widget.interval, (_) => _addTrade());
    }

    // Fetch real-time prices initially (force to load closing prices on weekend) and setup periodic updates
    _fetchRealPrices(force: true);
    _priceUpdateTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _fetchRealPrices());
  }

  Future<void> _fetchRealPrices({bool force = false}) async {
    final labelLower = widget.label.toLowerCase();
    if (!force &&
        (labelLower == 'forex' || labelLower == 'metals') &&
        _isWeekend) {
      return;
    }
    try {
      Map<String, double> fetchedPrices = {};
      if (widget.label.toLowerCase() == 'crypto') {
        fetchedPrices =
            await WhalePriceService.fetchCryptoPrices(widget.symbols);
      } else if (widget.label.toLowerCase() == 'forex') {
        fetchedPrices = await WhalePriceService.fetchForexPrices();
      } else if (widget.label.toLowerCase() == 'metals') {
        fetchedPrices = await WhalePriceService.fetchMetalPrices();
      }

      if (fetchedPrices.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          for (int i = 0; i < widget.symbols.length; i++) {
            final sym = widget.symbols[i];
            if (fetchedPrices.containsKey(sym)) {
              _livePrices[i] = fetchedPrices[sym]!;
            }
          }
        });
      }
    } catch (_) {}
  }

  WhaleTrade _newTrade() {
    if (widget.symbols.isEmpty) {
      return WhaleTrade(
        symbol: '',
        price: '0.0',
        size: '0.0',
        isBuy: true,
        time: '',
      );
    }
    final idx = _rnd.nextInt(widget.symbols.length);
    final base = _livePrices[idx];
    final priceDelta = base * (_rnd.nextDouble() * 0.003 - 0.0015);
    final price = (base + priceDelta);
    final sizeVal = _rnd.nextDouble() * 900 + 10;
    final now = DateTime.now();
    return WhaleTrade(
      symbol: widget.symbols[idx],
      price: price >= 1000
          ? price.toStringAsFixed(1)
          : price >= 1
              ? price.toStringAsFixed(4)
              : price.toStringAsFixed(6),
      size: sizeVal >= 1
          ? '${sizeVal.toStringAsFixed(1)}${widget.unit}'
          : '${(sizeVal * 1000).toStringAsFixed(0)}K${widget.unit}',
      isBuy: _rnd.nextBool(),
      time:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
    );
  }

  void _addTrade() {
    if (!mounted) return;
    final labelLower = widget.label.toLowerCase();
    if ((labelLower == 'forex' || labelLower == 'metals') && _isWeekend) {
      return;
    }
    setState(() {
      _trades.insert(0, _newTrade());
      if (_trades.length > _maxTrades) {
        _trades.removeLast();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _priceUpdateTimer?.cancel();
    _fallbackTimer?.cancel();
    _socketSub?.cancel();
    super.dispose();
  }


  Widget _buildRow(WhaleTrade t, {bool isFirst = false}) {
    final buyColor = const Color(0xFF00E676);
    final sellColor = const Color(0xFFFF1744);
    final sideColor = t.isBuy ? buyColor : sellColor;

    final row = Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: sideColor.withValues(alpha: 0.07),
        border: Border(
          left: BorderSide(color: sideColor, width: 2.5),
        ),
      ),
      child: Row(
        children: [
          // Side indicator dot
          Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(
              color: sideColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          // Symbol
          Expanded(
            flex: 3,
            child: Text(
              t.symbol,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Price
          Expanded(
            flex: 4,
            child: Text(
              t.price,
              style: TextStyle(
                color: sideColor,
                fontSize: 8.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Size
          Expanded(
            flex: 3,
            child: Text(
              t.size,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 7.5.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (!isFirst) return row;
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: row,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12.r),
        border:
            Border.all(color: widget.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 11.r),
                SizedBox(width: 4.w),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                // live dot
                _PulseDot(color: widget.color),
              ],
            ),
          ),
          // ── Column labels ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            child: Row(
              children: [
                SizedBox(width: 9.w),
                Expanded(
                  flex: 3,
                  child: Text('Pair',
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 4,
                  child: Text('Price',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Size',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // ── Live feed ──
          SizedBox(
            height: 150.h,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _trades.length,
              itemBuilder: (context, index) =>
                  _buildRow(_trades[index], isFirst: index == 0),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pulsing live dot ─────────────────────────────────────
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.6),
                  blurRadius: 4,
                )
              ],
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            'LIVE',
            style: TextStyle(
              color: widget.color,
              fontSize: 6.5.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
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

// ─── News Marquee ─────────────────────────────────────────
class NewsMarqueeWidget extends StatefulWidget {
  const NewsMarqueeWidget({super.key});

  @override
  State<NewsMarqueeWidget> createState() => _NewsMarqueeWidgetState();
}

class _NewsMarqueeWidgetState extends State<NewsMarqueeWidget> {
  List<String> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final List<String> fallbackNews = [
      "Bitcoin breaks \$70,000 resistance amidst institutional buying",
      "Ethereum network upgrade scheduled for next month",
      "Forex markets volatile as Federal Reserve holds interest rates",
      "Gold reaches new all-time high amid inflation fears",
      "Major crypto exchange announces integration with traditional banking",
      "US Dollar Index strengthens following positive jobs report"
    ];

    try {
      final response = await http
          .get(Uri.parse(
              'https://min-api.cryptocompare.com/data/v2/news/?lang=EN'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        if (data['Data'] != null) {
          final newsList = data['Data'] as List;
          setState(() {
            _news = newsList
                .map((item) => item['title'].toString())
                .take(15)
                .toList();
            if (_news.isEmpty) _news = fallbackNews;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      // Ignored, will use fallback
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _news = fallbackNews;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _news.isEmpty) {
      _news = [
        "Bitcoin breaks \$70,000 resistance amidst institutional buying",
        "Ethereum network upgrade scheduled for next month",
        "Forex markets volatile as Federal Reserve holds interest rates",
        "Gold reaches new all-time high amid inflation fears",
        "Major crypto exchange announces integration with traditional banking",
        "US Dollar Index strengthens following positive jobs report"
      ];
    }

    if (_news.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent
            ],
            stops: [0.0, 0.15, 0.85, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: CustomPaint(
          painter: _ArcLinesPainter(),
          child: SizedBox(
            height: 26.h,
            child: _NewsScroller(newsItems: _news),
          ),
        ),
      ),
    );
  }
}

class _ArcLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final shadowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    // Very slight upward curve (starts/ends at 2, peaks at -1.0)
    final topPath = Path()
      ..moveTo(0, 2.0)
      ..quadraticBezierTo(size.width / 2, -1.0, size.width, 2.0);

    // Very slight downward curve (starts/ends at height-2, peaks at height+1.0)
    final bottomPath = Path()
      ..moveTo(0, size.height - 2.0)
      ..quadraticBezierTo(
          size.width / 2, size.height + 1.0, size.width, size.height - 2.0);

    canvas.drawPath(topPath, shadowPaint);
    canvas.drawPath(bottomPath, shadowPaint);

    canvas.drawPath(topPath, paint);
    canvas.drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NewsScroller extends StatefulWidget {
  final List<String> newsItems;
  const _NewsScroller({required this.newsItems});

  @override
  State<_NewsScroller> createState() => _NewsScrollerState();
}

class _NewsScrollerState extends State<_NewsScroller> {
  final ScrollController _controller = ScrollController();
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
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
      final durationMs = (remaining / 10 * 1000)
          .round(); // 30 pixels per second for slow scrolling
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
    // Repeat items multiple times to create an infinite scroll illusion
    final repeatedNews = [
      ...widget.newsItems,
      ...widget.newsItems,
      ...widget.newsItems,
      ...widget.newsItems,
      ...widget.newsItems,
    ];

    return ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: repeatedNews.length,
      separatorBuilder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Center(
          child: Text(
            '#',
            style: TextStyle(
              color: Colors.orange.withValues(alpha: 0.4),
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
      itemBuilder: (_, i) => Center(
        child: Text(
          repeatedNews[i],
          style: TextStyle(
            color: Colors.orange.withValues(alpha: 0.7), // Faded orange text
            fontSize: 11.sp, // Thin/small
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Platform Stats Box ────────────────────────────────────
class PlatformStatsBox extends StatefulWidget {
  const PlatformStatsBox({super.key});

  @override
  State<PlatformStatsBox> createState() => _PlatformStatsBoxState();
}

class _PlatformStatsBoxState extends State<PlatformStatsBox> {
  Timer? _timerUserOnline; // every 5 seconds
  Timer? _timerCopiedTrades; // every 2 seconds
  Timer? _timerMarketFunding; // every 10 seconds
  Timer? _timerColdWallet; // every 1 second
  StreamSubscription<List<Map<String, dynamic>>>? _dbSubscription;

  // Ranges (can be updated from Supabase)
  int userMin = 3600;
  int userMax = 16000;
  int userDeltaMin = 2;
  int userDeltaMax = 13;

  int copiedMin = 620;
  int copiedMax = 69871;
  int copiedDeltaMin = 23;
  int copiedDeltaMax = 60;

  double marketMin = 0.3;
  double marketMax = 5.0;
  double marketDeltaMin = 0.02;
  double marketDeltaMax = 0.09;

  int coldMin = 135;
  int coldMax = 892;
  int coldDeltaMin = 5;
  int coldDeltaMax = 8;

  int _userOnline = 3600;
  int _copiedTrades = 620;
  double _marketFunding = 0.3;
  int _coldWallet = 135;

  int _prevUserOnline = 3600;
  int _prevCopiedTrades = 620;
  double _prevMarketFunding = 0.3;
  int _prevColdWallet = 135;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _userOnline = userMin + _random.nextInt(userMax - userMin + 1);
    _marketFunding = marketMin + _random.nextDouble() * (marketMax - marketMin);
    _coldWallet = coldMin + _random.nextInt(coldMax - coldMin + 1);

    _initCopiedTrades();
    _listenToDbRanges();

    // Row 1 – User Online: every 5 seconds
    _timerUserOnline = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _prevUserOnline = _userOnline;
        int delta =
            userDeltaMin + _random.nextInt(userDeltaMax - userDeltaMin + 1);
        if (_random.nextBool()) delta = -delta;
        _userOnline = (_userOnline + delta).clamp(userMin, userMax);
      });
    });

    // Row 2 – Copied Trades: every 2 seconds
    _timerCopiedTrades = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _prevCopiedTrades = _copiedTrades;
        int delta = copiedDeltaMin +
            _random.nextInt(copiedDeltaMax - copiedDeltaMin + 1);
        _copiedTrades += delta;
        if (_copiedTrades > copiedMax) _copiedTrades = copiedMax;
        final now = DateTime.now();
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        if (endOfDay.difference(now).inSeconds <= 0) _copiedTrades = copiedMin;
      });
    });

    // Row 3 – Market Funding: every 10 seconds
    _timerMarketFunding = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      setState(() {
        _prevMarketFunding = _marketFunding;
        double delta = marketDeltaMin +
            _random.nextDouble() * (marketDeltaMax - marketDeltaMin);
        if (_random.nextBool()) delta = -delta;
        _marketFunding = (_marketFunding + delta).clamp(marketMin, marketMax);
      });
    });

    // Row 4 – Cold Wallet: every 1 second
    _timerColdWallet = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _prevColdWallet = _coldWallet;
        int delta =
            coldDeltaMin + _random.nextInt(coldDeltaMax - coldDeltaMin + 1);
        if (_random.nextBool()) delta = -delta;
        _coldWallet = (_coldWallet + delta).clamp(coldMin, coldMax);
      });
    });
  }

  void _listenToDbRanges() {
    try {
      _dbSubscription = Supabase.instance.client
          .from('platform_stats_ranges')
          .stream(primaryKey: ['id'])
          .eq('id', 1)
          .listen((data) {
            if (data.isNotEmpty && mounted) {
              final row = data.first;
              setState(() {
                userMin = row['user_online_min'] ?? userMin;
                userMax = row['user_online_max'] ?? userMax;
                userDeltaMin = row['user_online_delta_min'] ?? userDeltaMin;
                userDeltaMax = row['user_online_delta_max'] ?? userDeltaMax;

                copiedMin = row['copied_trades_min'] ?? copiedMin;
                copiedMax = row['copied_trades_max'] ?? copiedMax;
                copiedDeltaMin =
                    row['copied_trades_delta_min'] ?? copiedDeltaMin;
                copiedDeltaMax =
                    row['copied_trades_delta_max'] ?? copiedDeltaMax;

                marketMin = (row['market_funding_min'] ?? marketMin).toDouble();
                marketMax = (row['market_funding_max'] ?? marketMax).toDouble();
                marketDeltaMin =
                    (row['market_funding_delta_min'] ?? marketDeltaMin)
                        .toDouble();
                marketDeltaMax =
                    (row['market_funding_delta_max'] ?? marketDeltaMax)
                        .toDouble();

                coldMin = row['cold_wallet_min'] ?? coldMin;
                coldMax = row['cold_wallet_max'] ?? coldMax;
                coldDeltaMin = row['cold_wallet_delta_min'] ?? coldDeltaMin;
                coldDeltaMax = row['cold_wallet_delta_max'] ?? coldDeltaMax;

                _userOnline = _userOnline.clamp(userMin, userMax);
                _marketFunding = _marketFunding.clamp(marketMin, marketMax);
                _coldWallet = _coldWallet.clamp(coldMin, coldMax);
              });
            }
          });
    } catch (e) {
      // Ignored if Supabase isn't initialized or fails
    }
  }

  void _initCopiedTrades() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final elapsedSeconds = now.difference(startOfDay).inSeconds;
    final totalSecondsInDay = 24 * 60 * 60;

    final progress = elapsedSeconds / totalSecondsInDay;
    _copiedTrades = copiedMin + ((copiedMax - copiedMin) * progress).round();
    _prevCopiedTrades = _copiedTrades;
  }

  @override
  void dispose() {
    _timerUserOnline?.cancel();
    _timerCopiedTrades?.cancel();
    _timerMarketFunding?.cancel();
    _timerColdWallet?.cancel();
    _dbSubscription?.cancel();
    super.dispose();
  }

  Color _getColor(num current, num previous) {
    if (current > previous) return const Color(0xFF00E676);
    if (current < previous) return const Color(0xFFFF1744);
    return AppColors.textPrimary;
  }

  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildRow('User Online', '$_userOnline',
              _getColor(_userOnline, _prevUserOnline)),
          _buildRow('Copied Trades', '$_copiedTrades',
              _getColor(_copiedTrades, _prevCopiedTrades)),
          _buildRow('Market Funding', '${_marketFunding.toStringAsFixed(1)} B',
              _getColor(_marketFunding, _prevMarketFunding)),
          _buildRow('Cold Wallet', '$_coldWallet m',
              _getColor(_coldWallet, _prevColdWallet)),
        ],
      ),
    );
  }
}

// ─── Admin Counter Widget ──────────────────────────────
class _AdminCounterWidget extends StatefulWidget {
  final String email;
  const _AdminCounterWidget({required this.email});

  @override
  State<_AdminCounterWidget> createState() => _AdminCounterWidgetState();
}

class _AdminCounterWidgetState extends State<_AdminCounterWidget> {
  bool _isAdmin = false;
  int? _userCount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAndFetchCount();
  }

  Future<void> _checkAdminAndFetchCount() async {
    if (widget.email.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    try {
      final supabase = Supabase.instance.client;
      // 1. Check if email is in admins table
      final adminCheck = await supabase
          .from('admins')
          .select('email')
          .eq('email', widget.email)
          .maybeSingle();

      if (adminCheck != null) {
        if (!mounted) return;
        setState(() {
          _isAdmin = true;
        });

        // 2. Fetch user count
        final count = await supabase.from('users').count(CountOption.exact);

        if (!mounted) return;
        setState(() {
          _userCount = count;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isAdmin = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching admin counter: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_isAdmin || _userCount == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 4.h, left: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_alt_rounded,
            color: AppColors.primary,
            size: 11.r,
          ),
          SizedBox(width: 4.w),
          Text(
            '$_userCount',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Signals Feed Widget (3 rows + Admin CRUD) ─────────────

const _kCategories = [
  (
    label: 'Forex',
    cat: 'forex',
    icon: Icons.show_chart_rounded,
    color: Color(0xFF2196F3)
  ),
  (
    label: 'Crypto',
    cat: 'crypto',
    icon: Icons.currency_bitcoin_rounded,
    color: Colors.orange
  ),
  (
    label: 'Metals',
    cat: 'metals',
    icon: Icons.diamond_rounded,
    color: Color(0xFFD4AF37)
  ),
];

class _SignalsFeed extends StatefulWidget {
  final String adminEmail;
  const _SignalsFeed({required this.adminEmail});

  @override
  State<_SignalsFeed> createState() => _SignalsFeedState();
}

class _SignalsFeedState extends State<_SignalsFeed> {
  bool _isAdmin = false;
  List<SupabaseSignal> _signals = [];
  StreamSubscription<List<SupabaseSignal>>? _sub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _sub = WhalePriceService.getSignalsStream().listen((signals) {
      if (!mounted) return;
      setState(() {
        _signals = signals;
        _isLoading = false;
      });
    }, onError: (_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _checkAdmin() async {
    if (widget.adminEmail.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('admins')
          .select('email')
          .eq('email', widget.adminEmail)
          .maybeSingle();
      if (mounted && res != null) setState(() => _isAdmin = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _deleteSignal(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Delete Signal',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp)),
        content: Text('Are you sure?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await Supabase.instance.client.from('signals').delete().eq('id', id);
    }
  }

  void _openForm({SupabaseSignal? signal, String? presetCategory}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SignalFormSheet(
        existing: signal,
        presetCategory: presetCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeader(title: '📡 Live Signals'),
            GestureDetector(
              onTap: () => context.push('/signals'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: AppColors.primary, size: 9.r),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        if (_isLoading)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ))
        else
          // ── 3 category rows ──
          Column(
            children: _kCategories.asMap().entries.map((entry) {
              final tabIndex = entry.key;
              final c = entry.value;
              final catSignals = _signals
                  .where((s) => s.category.toLowerCase() == c.cat)
                  .toList();
              return GestureDetector(
                onTap: () => context.push('/signals?tab=$tabIndex'),
                child: _buildCategoryRow(
                  label: c.label,
                  cat: c.cat,
                  icon: c.icon,
                  color: c.color,
                  signals: catSignals,
                  tabIndex: tabIndex,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildCategoryRow({
    required String label,
    required String cat,
    required IconData icon,
    required Color color,
    required List<SupabaseSignal> signals,
    int tabIndex = 0,
  }) {
    // Formal muted color derived from category
    final formalBorder = const Color(0xFF334155); // slate-700
    final formalBg = const Color(0xFF0F172A); // slate-900
    final formalLabel = const Color(0xFF94A3B8); // slate-400

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: formalBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: formalBorder, width: 0.8),
      ),
      child: Column(
        children: [
          // ── Centered category label inside border ──
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: formalLabel, size: 10.r),
                SizedBox(width: 5.w),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: formalLabel,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                if (_isAdmin) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _openForm(presetCategory: cat),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(color: formalBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              color: formalLabel, size: 9.r),
                          SizedBox(width: 2.w),
                          Text('Add',
                              style: TextStyle(
                                  color: formalLabel,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(color: formalBorder, height: 1, thickness: 0.5),

          // Column labels
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Pair',
                        style: TextStyle(
                            color: const Color(0xFF475569),
                            fontSize: 6.5.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4))),
                Expanded(
                    flex: 4,
                    child: Text('Type / Strategy',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: const Color(0xFF475569),
                            fontSize: 6.5.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4))),
                Expanded(
                    flex: 2,
                    child: Text('Entry',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xFF475569),
                            fontSize: 6.5.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4))),
                Expanded(
                    flex: 2,
                    child: Text('TP / SL',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: const Color(0xFF475569),
                            fontSize: 6.5.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4))),
                if (_isAdmin) SizedBox(width: 36.w),
              ],
            ),
          ),
          Divider(
              color: formalBorder.withValues(alpha: 0.5),
              height: 1,
              thickness: 0.4),

          // Signal rows or empty state
          signals.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Center(
                    child: Text(
                      'No active ${label.toLowerCase()} signals',
                      style: TextStyle(
                          color: const Color(0xFF475569),
                          fontSize: 8.5.sp,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              : Column(
                  children:
                      signals.map((s) => _buildSignalRow(s, color)).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSignalRow(SupabaseSignal s, Color catColor) {
    final isBuy = s.type.toUpperCase() == 'BUY';
    final buyColor = const Color(0xFF34D399);
    final sellColor = const Color(0xFFF87171);
    final actionColor = isBuy ? buyColor : sellColor;
    final rowBg = Colors.transparent;

    // Status badge
    final statusStyle = _statusStyle(s.status);
    final stratInfo = getStrategyInfo(s.strategy);

    return Container(
      decoration: BoxDecoration(
        color: rowBg,
        border: Border(
          left: BorderSide(color: actionColor.withValues(alpha: 0.7), width: 2),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: Row(
        children: [
          // Symbol
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDate(s.signalTime),
                  style: TextStyle(color: AppColors.textHint, fontSize: 6.5.sp),
                ),
                Text(
                  s.symbol.toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // BUY / SELL / Strategy badges
          Expanded(
            flex: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: actionColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                        color: actionColor.withValues(alpha: 0.3), width: 0.7),
                  ),
                  child: Text(
                    s.type.toUpperCase(),
                    style: TextStyle(
                      color: actionColor,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (stratInfo != null) ...[
                  SizedBox(width: 16.w),
                  Flexible(
                    child: StrategyBadge(info: stratInfo),
                  ),
                ],
              ],
            ),
          ),
          // Entry
          Expanded(
            flex: 2,
            child: Text(
              s.entryPrice,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFCBD5E1),
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // TP / SL
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (s.targetPrice != null)
                  Text('TP: ${s.targetPrice}',
                      style: TextStyle(
                        color: buyColor.withValues(alpha: 0.8),
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w600,
                      )),
                if (s.stopLoss != null)
                  Text('SL: ${s.stopLoss}',
                      style: TextStyle(
                        color: sellColor.withValues(alpha: 0.8),
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w600,
                      )),
              ],
            ),
          ),
          // Status badge
          SizedBox(width: 4.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: statusStyle.bg,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: statusStyle.border, width: 0.6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusStyle.icon, color: statusStyle.fg, size: 7.r),
                SizedBox(width: 2.w),
                Text(
                  statusStyle.label,
                  style: TextStyle(
                    color: statusStyle.fg,
                    fontSize: 6.5.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Admin edit / delete
          if (_isAdmin) ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () => _openForm(signal: s),
              child: Padding(
                padding: EdgeInsets.all(3.r),
                child: Icon(Icons.edit_rounded,
                    color: const Color(0xFF64748B), size: 11.r),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => _deleteSignal(s.id),
              child: Padding(
                padding: EdgeInsets.all(3.r),
                child: Icon(Icons.delete_outline_rounded,
                    color: const Color(0xFFF87171).withValues(alpha: 0.6),
                    size: 11.r),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ── Status badge styling helper ──
  ({Color fg, Color bg, Color border, IconData icon, String label})
      _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'win':
        return (
          fg: const Color(0xFF34D399),
          bg: const Color(0xFF022C22),
          border: const Color(0xFF34D399),
          icon: Icons.check_circle_rounded,
          label: 'WIN',
        );
      case 'loss':
        return (
          fg: const Color(0xFFF87171),
          bg: const Color(0xFF2D0A0A),
          border: const Color(0xFFF87171),
          icon: Icons.cancel_rounded,
          label: 'LOSS',
        );
      default:
        return (
          fg: const Color(0xFF94A3B8),
          bg: const Color(0xFF1E293B),
          border: const Color(0xFF334155),
          icon: Icons.schedule_rounded,
          label: 'WAIT',
        );
    }
  }
}

// ─── Signal Add / Edit Bottom Sheet Form ──────────────
class _SignalFormSheet extends StatefulWidget {
  final SupabaseSignal? existing;
  final String? presetCategory;
  const _SignalFormSheet({this.existing, this.presetCategory});

  @override
  State<_SignalFormSheet> createState() => _SignalFormSheetState();
}

class _SignalFormSheetState extends State<_SignalFormSheet> {
  late TextEditingController _symbolCtrl;
  late TextEditingController _entryCtrl;
  late TextEditingController _tpCtrl;
  late TextEditingController _slCtrl;
  late String _category;
  late String _type;
  late String _status;
  String? _strategy;
  late DateTime _signalTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _category = s?.category ?? widget.presetCategory ?? 'crypto';
    _type = s?.type.toUpperCase() ?? 'BUY';
    _status = s?.status ?? 'pending';
    _symbolCtrl = TextEditingController(text: s?.symbol ?? '');
    _entryCtrl = TextEditingController(text: s?.entryPrice ?? '');
    _tpCtrl = TextEditingController(text: s?.targetPrice ?? '');
    _slCtrl = TextEditingController(text: s?.stopLoss ?? '');
    _strategy = s?.strategy;
    _signalTime = s?.signalTime ?? DateTime.now();
  }

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _entryCtrl.dispose();
    _tpCtrl.dispose();
    _slCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _signalTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.bgDark,
          ),
          child: child!,
        );
      },
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_signalTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.bgDark,
          ),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

    setState(() {
      _signalTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_symbolCtrl.text.isEmpty || _entryCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    try {
      final data = {
        'category': _category,
        'symbol': _symbolCtrl.text.trim().toUpperCase(),
        'type': _type,
        'entry_price': _entryCtrl.text.trim(),
        'target_price':
            _tpCtrl.text.trim().isEmpty ? null : _tpCtrl.text.trim(),
        'stop_loss': _slCtrl.text.trim().isEmpty ? null : _slCtrl.text.trim(),
        'status': _status,
        'signal_time': _signalTime.toUtc().toIso8601String(),
        'strategy': _strategy,
      };
      final supabase = Supabase.instance.client;
      if (widget.existing != null) {
        await supabase
            .from('signals')
            .update(data)
            .eq('id', widget.existing!.id);
      } else {
        await supabase.from('signals').insert(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving signal: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textHint, fontSize: 11.sp),
        filled: true,
        fillColor: AppColors.bgDark,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppColors.borderSubtle)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppColors.borderSubtle)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              isEdit ? 'Edit Signal' : 'Add Signal',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 14.h),

            // Category & Type row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 10.sp)),
                      SizedBox(height: 4.h),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: _inputDeco(''),
                        dropdownColor: AppColors.bgCard,
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 11.sp),
                        items: const [
                          DropdownMenuItem(
                              value: 'crypto', child: Text('Crypto')),
                          DropdownMenuItem(
                              value: 'forex', child: Text('Forex')),
                          DropdownMenuItem(
                              value: 'metals', child: Text('Metals')),
                        ],
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 10.sp)),
                      SizedBox(height: 4.h),
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: _inputDeco(''),
                        dropdownColor: AppColors.bgCard,
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 11.sp),
                        items: const [
                          DropdownMenuItem(value: 'BUY', child: Text('BUY')),
                          DropdownMenuItem(value: 'SELL', child: Text('SELL')),
                        ],
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status',
                    style:
                        TextStyle(color: AppColors.textHint, fontSize: 10.sp)),
                SizedBox(height: 4.h),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: _inputDeco(''),
                  dropdownColor: AppColors.bgCard,
                  style:
                      TextStyle(color: AppColors.textPrimary, fontSize: 11.sp),
                  items: const [
                    DropdownMenuItem(
                        value: 'pending', child: Text('⏳ Pending')),
                    DropdownMenuItem(value: 'win', child: Text('✅ Win')),
                    DropdownMenuItem(value: 'loss', child: Text('❌ Loss')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Strategy / Tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Strategy / Tag (Optional)',
                    style:
                        TextStyle(color: AppColors.textHint, fontSize: 10.sp)),
                SizedBox(height: 4.h),
                DropdownButtonFormField<String?>(
                  value: _strategy,
                  decoration: _inputDeco(''),
                  dropdownColor: AppColors.bgCard,
                  style:
                      TextStyle(color: AppColors.textPrimary, fontSize: 11.sp),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(
                        value: 'pump_coming', child: Text('🔥 Pump Coming')),
                    DropdownMenuItem(value: 'news', child: Text('📰 News')),
                    DropdownMenuItem(
                        value: 'gann_pattern', child: Text('📐 Gann Pattern')),
                    DropdownMenuItem(
                        value: 'price_action', child: Text('📊 Price Action')),
                  ],
                  onChanged: (v) => setState(() => _strategy = v),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Symbol
            TextField(
              controller: _symbolCtrl,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp),
              decoration: _inputDeco('Symbol (e.g. BTC/USDT)'),
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 10.h),

            // Entry price
            TextField(
              controller: _entryCtrl,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp),
              decoration: _inputDeco('Entry Price'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 10.h),

            // TP & SL row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tpCtrl,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 12.sp),
                    decoration: _inputDeco('Take Profit (opt.)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: _slCtrl,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 12.sp),
                    decoration: _inputDeco('Stop Loss (opt.)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Signal Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signal Date & Time',
                    style:
                        TextStyle(color: AppColors.textHint, fontSize: 10.sp)),
                SizedBox(height: 4.h),
                InkWell(
                  onTap: _selectDateTime,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_signalTime.day.toString().padLeft(2, '0')}/${_signalTime.month.toString().padLeft(2, '0')}/${_signalTime.year} '
                          '${_signalTime.hour.toString().padLeft(2, '0')}:${_signalTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 11.sp),
                        ),
                        Icon(Icons.calendar_today_rounded,
                            color: AppColors.primary, size: 14.r),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'Save Changes' : 'Add Signal',
                        style: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
