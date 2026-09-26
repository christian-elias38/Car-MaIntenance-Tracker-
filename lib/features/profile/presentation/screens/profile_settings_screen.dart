import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/user_provider.dart';
import '../../../vehicles/presentation/screens/vehicles_screen.dart';
import '../../../maintenance/presentation/screens/service_history_screen.dart';
import '../../../reminders/presentation/screens/reminders_screen.dart';
import '../../../expenses/presentation/screens/fuel_costs_screen.dart';
import 'end_cover_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/otp_auth_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  void _showSettingsModal(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings & System Appearance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Theme Mode Selector
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.brightness_6_outlined, color: AppColors.primaryLight),
                title: const Text('Theme Mode & System Colors'),
                subtitle: Text(
                  themeProvider.themeMode == ThemeMode.system
                      ? 'System Default ⚙️'
                      : (themeProvider.themeMode == ThemeMode.dark ? 'Dark Mode 🌙' : 'Light Mode ☀️'),
                ),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System ⚙️')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light ☀️')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark 🌙')),
                    ],
                    onChanged: (mode) {
                      if (mode != null) {
                        themeProvider.setThemeMode(mode);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ),
              ),
              const Divider(),

              // Currency Selector
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.attach_money, color: AppColors.primaryLight),
                title: const Text('Currency Symbol'),
                subtitle: Text('Current: ${userProvider.currency}'),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: userProvider.currency,
                    items: const [
                      DropdownMenuItem(value: '\$', child: Text('\$ (USD)')),
                      DropdownMenuItem(value: 'ETB', child: Text('ETB (Br)')),
                      DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
                      DropdownMenuItem(value: '£', child: Text('£ (GBP)')),
                    ],
                    onChanged: (curr) {
                      if (curr != null) {
                        userProvider.setCurrency(curr);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Forest Green Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF093327),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    // Avatar Image Circle
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.userName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProvider.userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Theme Quick Selector Segmented Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance & Theme Mode',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildThemeSegment(
                              context,
                              label: 'System',
                              icon: Icons.brightness_auto_rounded,
                              isSelected: themeProvider.themeMode == ThemeMode.system,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildThemeSegment(
                              context,
                              label: 'Light',
                              icon: Icons.wb_sunny_rounded,
                              isSelected: themeProvider.themeMode == ThemeMode.light,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildThemeSegment(
                              context,
                              label: 'Dark',
                              icon: Icons.nightlight_round,
                              isSelected: themeProvider.themeMode == ThemeMode.dark,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Menu Options Container Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.directions_car_rounded,
                        title: 'My Vehicles & Garage',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildMenuItem(
                        context,
                        icon: Icons.receipt_long_rounded,
                        title: 'Service History',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ServiceHistoryScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildMenuItem(
                        context,
                        icon: Icons.notifications_none_rounded,
                        title: 'Reminders',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RemindersScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildMenuItem(
                        context,
                        icon: Icons.bar_chart_rounded,
                        title: 'Fuel & Costs',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FuelCostsScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildMenuItem(
                        context,
                        icon: Icons.phonelink_ring_rounded,
                        title: 'Mobile OTP Security & Phone',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OtpAuthScreen(isProfileConfigMode: true),
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildMenuItem(
                        context,
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        isDark: isDark,
                        onTap: () => _showSettingsModal(context),
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildMenuItem(
                        context,
                        icon: Icons.auto_awesome_rounded,
                        title: 'CarTrack Showcase',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EndCoverScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Log Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      userProvider.setLoggedIn(false);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSegment(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.mintBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        size: 24,
      ),
    );
  }
}
