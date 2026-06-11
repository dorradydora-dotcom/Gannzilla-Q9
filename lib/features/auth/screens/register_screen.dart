import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

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

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final status = context.select<AuthController, AuthStatus>((a) => a.status);
    final errorMessage = context.select<AuthController, String?>((a) => a.errorMessage);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen background image
          FadeTransition(
            opacity: _fadeAnim,
            child: Image.asset(
              'assets/images/gannzilla_logo.png',
              fit: BoxFit.fill,
            ),
          ),

          // Dark gradient overlay
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(32.w, 48.h, 32.w, 56.h),
                      decoration: BoxDecoration(
                        color: AppColors.bgDark.withValues(alpha: 0.65),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.register,
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            AppStrings.registerSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          
                          SizedBox(height: 48.h),
                          
                          // Gmail Button
                          Container(
                            height: 60.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 16.r,
                                  offset: Offset(0, 8.h),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.r),
                                onTap: status == AuthStatus.loading
                                    ? null
                                    : () async {
                                        await auth.signInWithGoogle();
                                      },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    status == AuthStatus.loading
                                        ? SizedBox(
                                            width: 24.r,
                                            height: 24.r,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : Icon(Icons.email_rounded,
                                            color: Colors.redAccent, size: 28.r),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'Continue with Gmail',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          if (errorMessage != null) ...[
                            SizedBox(height: 24.h),
                            Text(
                              errorMessage,
                              style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                              textAlign: TextAlign.center,
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
