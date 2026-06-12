import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/gannzilla_text.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // 8 feature items
  static const List<_FeatureItem> _features = [
    _FeatureItem(Icons.water_rounded, 'Whale\nAlerts', AppColors.whaleGradient),
    _FeatureItem(
        Icons.currency_bitcoin_rounded, 'Crypto', AppColors.cryptoGradient),
    _FeatureItem(Icons.bolt_rounded, 'Instant\nNews', AppColors.newsGradient),
    _FeatureItem(Icons.show_chart_rounded, 'Forex', AppColors.primaryGradient),
    _FeatureItem(
        Icons.psychology_rounded, 'Smart\nMoney', AppColors.whaleGradient),
    _FeatureItem(
        Icons.bar_chart_rounded, 'Market\nAnalysis', AppColors.cryptoGradient),
    _FeatureItem(Icons.notifications_active_rounded, 'Price\nAlerts',
        AppColors.primaryGradient),
    _FeatureItem(Icons.account_balance_wallet_rounded, 'Portfolio',
        AppColors.newsGradient),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final status = context.select<AuthController, AuthStatus>((a) => a.status);
    final errorMessage =
        context.select<AuthController, String?>((a) => a.errorMessage);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          FadeTransition(
            opacity: _fadeAnim,
            child: Image.asset(
              'assets/images/gannzilla_logo.png',
              fit: BoxFit.fill,
            ),
          ),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.overlayStart,
                  AppColors.overlayStart,
                  AppColors.overlayEnd,
                  AppColors.overlayEnd,
                ],
                stops: [0.0, 0.45, 0.72, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Bottom Glassmorphism Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30.r)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 28.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.82),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pill handle
                          Container(
                            width: 36.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          SizedBox(height: 14.h),

                          // GannZilla branding (no icon above)
                          GannZillaText(
                              fontSize: 28,
                              letterSpacing: 0.5,
                              isWhiteAndRed: true),
                          SizedBox(height: 4.h),
                          Text(
                            AppStrings.register,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Access your whale trades and market tracking\ndashboard instantly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: Colors.white60,
                              height: 1.5,
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // 8 Feature icons — 4 per row with staggered animation
                          _StaggeredFeaturesGrid(
                            features: _features,
                            parentAnimation: _animCtrl,
                          ),

                          SizedBox(height: 18.h),

                          // Google Sign-In Button
                          _BouncingButton(
                            onTap: status == AuthStatus.loading
                                ? null
                                : () async {
                                    await auth.signInWithGoogle();
                                  },
                            child: FractionallySizedBox(
                              widthFactor: 0.75,
                              child: Container(
                                height: 37.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.28),
                                      blurRadius: 14.r,
                                      offset: Offset(0, 6.h),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      status == AuthStatus.loading
                                          ? SizedBox(
                                              width: 18.r,
                                              height: 18.r,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                color: AppColors.primary,
                                              ),
                                            )
                                          : Image.asset(
                                              'assets/images/google_logo.png',
                                              width: 18.r,
                                              height: 18.r,
                                            ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Continue with Gmail',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Error message
                          if (errorMessage != null) ...[
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.h, horizontal: 14.w),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                    color:
                                        AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline_rounded,
                                      color: AppColors.error, size: 18.r),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      errorMessage,
                                      style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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

// ─── Feature Item model ───────────────────────────────────
class _FeatureItem {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  const _FeatureItem(this.icon, this.label, this.gradient);
}

// ─── Staggered 4-column features grid ────────────────────
class _StaggeredFeaturesGrid extends StatefulWidget {
  final List<_FeatureItem> features;
  final AnimationController parentAnimation;

  const _StaggeredFeaturesGrid({
    required this.features,
    required this.parentAnimation,
  });

  @override
  State<_StaggeredFeaturesGrid> createState() => _StaggeredFeaturesGridState();
}

class _StaggeredFeaturesGridState extends State<_StaggeredFeaturesGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late List<Animation<double>> _itemFades;
  late List<Animation<Offset>> _itemSlides;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    final count = widget.features.length;
    _itemFades = List.generate(count, (i) {
      final start = (i / count) * 0.65;
      final end = start + 0.35;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOut),
        ),
      );
    });

    _itemSlides = List.generate(count, (i) {
      final start = (i / count) * 0.65;
      final end = start + 0.35;
      return Tween<Offset>(
        begin: const Offset(0, 0.4),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOut),
        ),
      );
    });

    // Start stagger after parent panel appears
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _staggerCtrl.forward();
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.features.length, (i) {
          final f = widget.features[i];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.7.w),
            child: FadeTransition(
              opacity: _itemFades[i],
              child: SlideTransition(
                position: _itemSlides[i],
                child: SizedBox(
                  width: 50.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: f.gradient.colors[0].withValues(alpha: 0.12),
                          border: Border.all(
                            color: f.gradient.colors[0].withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  f.gradient.colors[0].withValues(alpha: 0.08),
                              blurRadius: 6.r,
                              spreadRadius: 1.r,
                            ),
                          ],
                        ),
                        child: Icon(f.icon,
                            color: f.gradient.colors[0], size: 16.r),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        f.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Bouncing Button ──────────────────────────────────────
class _BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _BouncingButton({required this.child, this.onTap});

  @override
  State<_BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: 1 - _controller.value,
        child: widget.child,
      ),
    );
  }
}
