import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../auth/controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/gannzilla_progress_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // Loading status messages
  String _loadingStatus = AppStrings.splashLoading1;

  @override
  void initState() {
    super.initState();

    // Logo (image fade-in) Animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Text / overlay Animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _startAnimations();
  }

  void _startAnimations() async {
    // 1. Set up minimum visual delay (4.6s) to allow entry animations and loading steps to be read
    final minDelay = Future.delayed(const Duration(milliseconds: 4600));

    // 2. Set up parallel initialization tasks (session check, caching, etc.)
    final initTasks = _initializeData();

    // 3. Play entry animations sequentially
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _textController.forward();

    // 4. Start the loading status messages sequence
    _updateStatusSequence();

    // 5. Wait for both animations and initialization tasks to complete
    await Future.wait([minDelay, initTasks]);

    // 6. Navigate to the next screen
    _navigate();
  }

  void _updateStatusSequence() async {
    final steps = [
      AppStrings.splashLoading1,
      AppStrings.splashLoading2,
      AppStrings.splashLoading3,
      AppStrings.splashLoading4,
      AppStrings.splashLoading5,
    ];

    for (var i = 0; i < steps.length; i++) {
      if (i > 0) {
        await Future.delayed(const Duration(milliseconds: 900));
      }
      if (!mounted) return;
      setState(() {
        _loadingStatus = steps[i];
      });
    }
  }

  Future<void> _initializeData() async {
    try {
      // Parallel startup tasks (e.g. warming up cache, restoring settings)
      // Since AuthController automatically initializes on creation, we add a brief pause
      // as a placeholder for any future asynchronous startup checks
      await Future.delayed(const Duration(milliseconds: 600));
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  void _navigate() {
    if (!mounted) return;
    final auth = context.read<AuthController>();
    if (auth.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/register');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen background image ──────────────────────────────
          FadeTransition(
            opacity: _logoOpacity,
            child: Image.asset('assets/images/gannzilla_logo.png',
                fit: BoxFit.fill),
          ),

          // ── Dark gradient overlay (top → transparent → dark bottom) ───
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

          // ── Bottom overlay: progress bar + status text ────────────────
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GannZillaProgressBar(
                            duration: const Duration(milliseconds: 3800),
                          ),
                          SizedBox(height: 16.h),

                          // Status message
                          SizedBox(
                            height: 22.h,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.25),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                _loadingStatus,
                                key: ValueKey<String>(_loadingStatus),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
