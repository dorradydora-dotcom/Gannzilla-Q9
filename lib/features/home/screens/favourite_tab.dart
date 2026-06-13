import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

class FavouriteTab extends StatefulWidget {
  const FavouriteTab({super.key});

  @override
  State<FavouriteTab> createState() => _FavouriteTabState();
}

class _FavouriteTabState extends State<FavouriteTab> {
  final List<Map<String, dynamic>> _favorites = [
    {
      'symbol': 'BTC/USDT',
      'name': 'Bitcoin',
      'price': '\$104,220',
      'change': '+2.41%',
      'isUp': true,
      'favorite': true,
      'gradient': AppColors.cryptoGradient
    },
    {
      'symbol': 'ETH/USDT',
      'name': 'Ethereum',
      'price': '\$3,891.50',
      'change': '-0.85%',
      'isUp': false,
      'favorite': true,
      'gradient': AppColors.primaryGradient
    },
    {
      'symbol': 'SOL/USDT',
      'name': 'Solana',
      'price': '\$188.45',
      'change': '+5.23%',
      'isUp': true,
      'favorite': true,
      'gradient': AppColors.whaleGradient
    },
    {
      'symbol': 'GBP/USD',
      'name': 'Pound / US Dollar',
      'price': '1.2654',
      'change': '+0.34%',
      'isUp': true,
      'favorite': true,
      'gradient': AppColors.cryptoGradient
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeFavorites = _favorites.where((f) => f['favorite'] == true).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Favorites',
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
                child: Icon(Icons.star_rounded,
                    color: const Color(0xFFFFC107), size: 22.r),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Your pinned assets and custom currency watchlist.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),

          // Favorites list
          Expanded(
            child: activeFavorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border_rounded,
                          color: AppColors.textHint,
                          size: 48.r,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No favorites yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Add items from Markets tab',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(bottom: 96.h),
                    itemCount: activeFavorites.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = activeFavorites[index];
                      final changeColor = item['isUp']
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
                                gradient: item['gradient'] as LinearGradient,
                              ),
                              child: Center(
                                child: Text(
                                  item['symbol'][0],
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
                                    item['symbol'],
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    item['name'],
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
                                  item['price'],
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
                                        item['isUp']
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        color: changeColor,
                                        size: 10.r,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        item['change'],
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
                            SizedBox(width: 12.w),
                            // Favorite star (interactive removal)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  item['favorite'] = false;
                                });
                              },
                              child: Icon(
                                Icons.star_rounded,
                                color: const Color(0xFFFFC107),
                                size: 20.r,
                              ),
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
