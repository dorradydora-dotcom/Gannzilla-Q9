import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: AppStrings.home),
    _NavItem(icon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.notifications_rounded, label: AppStrings.notifications),
    _NavItem(icon: Icons.person_rounded, label: AppStrings.profile),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final userName = auth.currentUser?.userMetadata?['full_name']
            ?.toString()
            .split(' ')
            .first ??
        'User';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _buildBody(userName, auth),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(String userName, AuthController auth) {
    switch (_selectedIndex) {
      case 0:
        return _HomeTab(userName: userName, auth: auth);
      case 1:
        return const _PlaceholderTab(icon: Icons.search_rounded, label: 'Search');
      case 2:
        return const _PlaceholderTab(
            icon: Icons.notifications_rounded, label: 'Notifications');
      case 3:
        return _ProfileTab(auth: auth);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top: BorderSide(color: Color(0xFF2A2A4A), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textHint,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textHint,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final String userName;
  final AuthController auth;

  const _HomeTab({required this.userName, required this.auth});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.welcome}، $userName 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'What are you looking for today?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ),

        // Hero Banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: -30,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to Gannzilla! ⚡',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Track Whale Trades, Crypto, and Forex\nin one place',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.5,
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

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: const [
                    _QuickActionCard(
                      icon: Icons.currency_bitcoin_rounded,
                      label: 'Crypto',
                      gradient: [Color(0xFFF7931A), Color(0xFFFFB347)],
                    ),
                    _QuickActionCard(
                      icon: Icons.show_chart_rounded,
                      label: 'Forex',
                      gradient: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
                    ),
                    _QuickActionCard(
                      icon: Icons.newspaper_rounded,
                      label: 'News',
                      gradient: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                    ),
                    _QuickActionCard(
                      icon: Icons.water_rounded,
                      label: 'Whale Trades',
                      gradient: [Color(0xFFFF6584), Color(0xFFFF92A8)],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ─── Quick Action Card ────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Profile Tab ──────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final AuthController auth;
  const _ProfileTab({required this.auth});

  @override
  Widget build(BuildContext context) {
    final name = auth.currentUser?.userMetadata?['full_name'] ?? 'User';
    final email = auth.currentUser?.email ?? '';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(email,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 40),
          // Logout Button
          Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              border:
                  Border.all(color: AppColors.error.withValues(alpha: 0.6), width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => auth.signOut(),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded,
                          color: AppColors.error, size: 20),
                      SizedBox(width: 8),
                      Text(
                        AppStrings.logout,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

// ─── Placeholder Tab ──────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coming soon...',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// ─── Nav Item Model ───────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
