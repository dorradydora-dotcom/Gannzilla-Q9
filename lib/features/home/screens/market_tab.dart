import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

class MarketTab extends StatefulWidget {
  const MarketTab({super.key});

  @override
  State<MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends State<MarketTab> {
  int _activeFilterIndex = 0;
  final List<String> _filters = ['All Markets', 'Top Gainers', 'Top Losers'];

  final List<Map<String, dynamic>> _markets = [
    {
      'symbol': 'BTC/USDT',
      'name': 'Bitcoin',
      'price': '\$104,220',
      'change': '+2.41%',
      'isUp': true,
      'gradient': AppColors.cryptoGradient
    },
    {
      'symbol': 'ETH/USDT',
      'name': 'Ethereum',
      'price': '\$3,891.50',
      'change': '-0.85%',
      'isUp': false,
      'gradient': AppColors.primaryGradient
    },
    {
      'symbol': 'BNB/USDT',
      'name': 'Binance Coin',
      'price': '\$712.20',
      'change': '+1.12%',
      'isUp': true,
      'gradient': AppColors.newsGradient
    },
    {
      'symbol': 'SOL/USDT',
      'name': 'Solana',
      'price': '\$188.45',
      'change': '+5.23%',
      'isUp': true,
      'gradient': AppColors.whaleGradient
    },
    {
      'symbol': 'EUR/USD',
      'name': 'Euro / US Dollar',
      'price': '1.0842',
      'change': '-0.12%',
      'isUp': false,
      'gradient': AppColors.primaryGradient
    },
    {
      'symbol': 'GBP/USD',
      'name': 'Pound / US Dollar',
      'price': '1.2654',
      'change': '+0.34%',
      'isUp': true,
      'gradient': AppColors.cryptoGradient
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredMarkets = _markets.where((m) {
      if (_activeFilterIndex == 1) return m['isUp'] == true;
      if (_activeFilterIndex == 2) return m['isUp'] == false;
      return true;
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          // Search & Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Markets',
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
                child: Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20.r),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _activeFilterIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilterIndex = index),
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            )
                          : null,
                      color: isSelected ? null : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 20.h),

          // Market list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: 96.h),
              itemCount: filteredMarkets.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final market = filteredMarkets[index];
                final changeColor = market['isUp']
                    ? const Color(0xFF4CAF50)
                    : AppColors.error;

                return Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      // Icon/Logo circular container
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: market['gradient'] as LinearGradient,
                        ),
                        child: Center(
                          child: Text(
                            market['symbol'][0],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              market['symbol'],
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              market['name'],
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price & Change
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            market['price'],
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: changeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  market['isUp']
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  color: changeColor,
                                  size: 10.r,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  market['change'],
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
