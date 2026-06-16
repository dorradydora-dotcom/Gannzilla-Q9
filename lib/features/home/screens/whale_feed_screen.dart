import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/market_data_service.dart';

// ─── Entry model ───────────────────────────────────────────
class WhaleTrade {
  final String symbol;
  final String price;
  final String size;
  final bool isBuy;
  final String time;

  WhaleTrade({
    required this.symbol,
    required this.price,
    required this.size,
    required this.isBuy,
    required this.time,
  });
}

// ─── Feed config for each tab ──────────────────────────────
class _FeedConfig {
  final String label;
  final IconData icon;
  final Color color;
  final List<String> symbols;
  final List<double> basePrices;
  final String unit;
  final Duration interval;

  const _FeedConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.symbols,
    required this.basePrices,
    required this.unit,
    required this.interval,
  });
}

const List<_FeedConfig> _feeds = [
  _FeedConfig(
    label: 'Forex',
    icon: Icons.show_chart_rounded,
    color: Color(0xFF2196F3),
    symbols: [
      'EUR/USD',
      'GBP/JPY',
      'USD/CHF',
      'AUD/USD',
      'USD/JPY',
      'USD/CAD',
      'NZD/USD',
      'EUR/GBP',
    ],
    basePrices: [
      1.0842,
      197.34,
      0.8961,
      0.6512,
      157.82,
      1.3641,
      0.6124,
      0.8531,
    ],
    unit: 'M',
    interval: Duration(milliseconds: 350),
  ),
  _FeedConfig(
    label: 'Crypto',
    icon: Icons.currency_bitcoin_rounded,
    color: Color(0xFFFFA726),
    symbols: [
      'BTC',
      'ETH',
      'SOL',
      'BNB',
      'XRP',
      'DOGE',
      'ADA',
      'MATIC',
    ],
    basePrices: [
      67400.0,
      3520.0,
      172.5,
      588.0,
      0.5231,
      0.1642,
      0.4512,
      0.8723,
    ],
    unit: 'K',
    interval: Duration(milliseconds: 250),
  ),
  _FeedConfig(
    label: 'Metals',
    icon: Icons.diamond_rounded,
    color: Color(0xFFD4AF37),
    symbols: [
      'XAU/USD',
      'XAG/USD',
      'XPT/USD',
      'XPD/USD',
      'COPPER',
      'WTI',
      'BRENT',
      'NATGAS',
    ],
    basePrices: [
      2324.5,
      28.74,
      961.0,
      1012.0,
      4.523,
      78.42,
      82.15,
      2.341,
    ],
    unit: 'oz',
    interval: Duration(milliseconds: 450),
  ),
];

// ─── Main Screen ───────────────────────────────────────────
class WhaleFeedScreen extends StatefulWidget {
  final int initialTab;
  const WhaleFeedScreen({super.key, this.initialTab = 0});

  @override
  State<WhaleFeedScreen> createState() => _WhaleFeedScreenState();
}

class _WhaleFeedScreenState extends State<WhaleFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _feeds.length,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, _feeds.length - 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // ── Custom AppBar ──────────────────────────────
          AnimatedBuilder(
            animation: _tabController,
            builder: (_, __) {
              final color = _feeds[_tabController.index].color;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  border: Border(
                    bottom: BorderSide(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Title row
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.3),
                                      width: 1),
                                ),
                                child: Icon(Icons.arrow_back_ios_new_rounded,
                                    color: color, size: 16.r),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '🐋 Whale Activity',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const Spacer(),
                            _LiveBadge(color: color),
                          ],
                        ),
                      ),
                      // Tab bar
                      TabBar(
                        controller: _tabController,
                        onTap: (_) => setState(() {}),
                        indicatorColor: color,
                        indicatorWeight: 2.5,
                        labelColor: color,
                        unselectedLabelColor: AppColors.textHint,
                        labelStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: _feeds
                            .map((f) => Tab(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(f.icon, size: 14.r),
                                      SizedBox(width: 5.w),
                                      Text(f.label),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Column header labels ───────────────────────
          Container(
            color: AppColors.bgCard.withValues(alpha: 0.5),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
            child: Row(
              children: [
                SizedBox(width: 14.w),
                Expanded(
                  flex: 3,
                  child: Text('Pair',
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Side',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 4,
                  child: Text('Price',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Size',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Time',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // ── Tab views ─────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _feeds.map((f) => _FullFeedView(config: f)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Full-screen live feed for one tab ────────────────────
class _FullFeedView extends StatefulWidget {
  final _FeedConfig config;
  const _FullFeedView({required this.config});

  @override
  State<_FullFeedView> createState() => _FullFeedViewState();
}

class _FullFeedViewState extends State<_FullFeedView>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<WhaleTrade> _trades = [];
  Timer? _timer;
  Timer? _priceUpdateTimer;
  final Random _rnd = Random();
  static const int _maxTrades = 120;
  late List<double> _livePrices;

  bool get _isWeekend {
    final day = DateTime.now().weekday;
    return day == DateTime.saturday || day == DateTime.sunday;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _livePrices = List<double>.from(widget.config.basePrices);
    for (int i = 0; i < 30; i++) {
      _trades.add(_newTrade());
    }
    _timer = Timer.periodic(widget.config.interval, (_) => _addTrade());

    // Fetch real-time prices initially (force to load closing prices on weekend) and setup periodic updates
    _fetchRealPrices(force: true);
    _priceUpdateTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _fetchRealPrices());
  }

  Future<void> _fetchRealPrices({bool force = false}) async {
    final labelLower = widget.config.label.toLowerCase();
    if (!force &&
        (labelLower == 'forex' || labelLower == 'metals') &&
        _isWeekend) {
      return;
    }
    try {
      Map<String, double> fetchedPrices = {};
      if (widget.config.label.toLowerCase() == 'crypto') {
        fetchedPrices =
            await WhalePriceService.fetchCryptoPrices(widget.config.symbols);
      } else if (widget.config.label.toLowerCase() == 'forex') {
        fetchedPrices = await WhalePriceService.fetchForexPrices();
      } else if (widget.config.label.toLowerCase() == 'metals') {
        fetchedPrices = await WhalePriceService.fetchMetalPrices();
      }

      if (fetchedPrices.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          for (int i = 0; i < widget.config.symbols.length; i++) {
            final sym = widget.config.symbols[i];
            if (fetchedPrices.containsKey(sym)) {
              _livePrices[i] = fetchedPrices[sym]!;
            }
          }
        });
      }
    } catch (_) {}
  }

  WhaleTrade _newTrade() {
    if (widget.config.symbols.isEmpty) {
      return WhaleTrade(
        symbol: '',
        price: '0.00',
        size: '0.0',
        isBuy: true,
        time: '',
      );
    }
    final idx = _rnd.nextInt(widget.config.symbols.length);
    final base = _livePrices[idx];
    final priceDelta = base * (_rnd.nextDouble() * 0.004 - 0.002);
    final price = base + priceDelta;
    final sizeVal = _rnd.nextDouble() * 950 + 5;
    final now = DateTime.now();
    return WhaleTrade(
      symbol: widget.config.symbols[idx],
      price: price >= 1000
          ? price.toStringAsFixed(2)
          : price >= 1
              ? price.toStringAsFixed(4)
              : price.toStringAsFixed(6),
      size: sizeVal >= 100
          ? '${sizeVal.toStringAsFixed(1)}${widget.config.unit}'
          : '${sizeVal.toStringAsFixed(2)}${widget.config.unit}',
      isBuy: _rnd.nextBool(),
      time:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
    );
  }

  void _addTrade() {
    if (!mounted) return;
    final labelLower = widget.config.label.toLowerCase();
    if ((labelLower == 'forex' || labelLower == 'metals') && _isWeekend) {
      return;
    }
    final entry = _newTrade();
    _trades.insert(0, entry);
    _listKey.currentState
        ?.insertItem(0, duration: const Duration(milliseconds: 250));
    if (_trades.length > _maxTrades) {
      final removed = _trades.removeAt(_trades.length - 1);
      _listKey.currentState?.removeItem(
        _trades.length,
        (ctx, anim) => _buildRow(removed, anim),
        duration: const Duration(milliseconds: 120),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _priceUpdateTimer?.cancel();
    super.dispose();
  }

  Widget _buildRow(WhaleTrade t, Animation<double> animation) {
    const buyColor = Color(0xFF00E676);
    const sellColor = Color(0xFFFF1744);
    final sideColor = t.isBuy ? buyColor : sellColor;
    final sideLabel = t.isBuy ? 'BUY' : 'SELL';

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: sideColor.withValues(alpha: 0.06),
            border: Border(
              left: BorderSide(color: sideColor, width: 3),
            ),
          ),
          child: Row(
            children: [
              // Dot
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: sideColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: sideColor.withValues(alpha: 0.5), blurRadius: 4)
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Symbol
              Expanded(
                flex: 3,
                child: Text(
                  t.symbol,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Side badge
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: sideColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      sideLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: sideColor,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Price
              Expanded(
                flex: 4,
                child: Text(
                  t.price,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: sideColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              // Size
              Expanded(
                flex: 3,
                child: Text(
                  t.size,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Time
              Expanded(
                flex: 2,
                child: Text(
                  t.time,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedList(
      key: _listKey,
      initialItemCount: _trades.length,
      itemBuilder: (context, index, animation) {
        if (index >= _trades.length) return const SizedBox.shrink();
        return _buildRow(_trades[index], animation);
      },
    );
  }
}

// ─── Live badge ───────────────────────────────────────────
class _LiveBadge extends StatefulWidget {
  final Color color;
  const _LiveBadge({required this.color});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20.r),
          border:
              Border.all(color: widget.color.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.r,
              height: 6.r,
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
            SizedBox(width: 5.w),
            Text(
              'LIVE',
              style: TextStyle(
                color: widget.color,
                fontSize: 9.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
