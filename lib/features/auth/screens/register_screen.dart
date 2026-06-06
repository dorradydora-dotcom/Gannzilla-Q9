import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success = await auth.signUp(
      email: _emailCtrl.text,
      password: _passCtrl.text,
      fullName: _nameCtrl.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? AppStrings.error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF0D0D0D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.go('/login'),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Title
                      const Text(
                        AppStrings.register,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your details to start',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Full Name
                      _buildField(
                        controller: _nameCtrl,
                        label: AppStrings.fullName,
                        hint: 'John Doe',
                        icon: Icons.person_outline,
                        validator: (v) => v == null || v.isEmpty
                            ? AppStrings.requiredField
                            : null,
                      ),

                      const SizedBox(height: 20),

                      // Email
                      _buildField(
                        controller: _emailCtrl,
                        label: AppStrings.email,
                        hint: 'example@email.com',
                        icon: Icons.email_outlined,
                        inputType: TextInputType.emailAddress,
                        isLtr: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (!v.contains('@')) return AppStrings.invalidEmail;
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password
                      _buildLabel(AppStrings.password),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (v.length < 8) return AppStrings.passwordTooShort;
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Confirm Password
                      _buildLabel(AppStrings.confirmPassword),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPassCtrl,
                        obscureText: _obscureConfirm,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (v != _passCtrl.text) {
                            return AppStrings.passwordsNotMatch;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 36),

                      // Register Button
                      _GradientButton(
                        label: AppStrings.register,
                        isLoading: auth.status == AuthStatus.loading,
                        onPressed: _register,
                      ),

                      const SizedBox(height: 24),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.alreadyHaveAccount,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text(AppStrings.signIn),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isLtr = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          textDirection: isLtr ? TextDirection.ltr : null,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
