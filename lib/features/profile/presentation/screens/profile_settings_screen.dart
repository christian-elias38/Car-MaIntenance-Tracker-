import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/user_provider.dart';
import '../../../vehicles/presentation/providers/vehicle_provider.dart';
import '../../../maintenance/presentation/providers/maintenance_provider.dart';
import '../../../expenses/presentation/widgets/expense_chart.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  void _showEditProfileDialog(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final nameController = TextEditingController(text: userProvider.userName);
    final emailController = TextEditingController(text: userProvider.userEmail);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              userProvider.updateProfile(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();
    final vehicleProvider = context.watch<VehicleProvider>();
    final maintenanceProvider = context.watch<MaintenanceProvider>();

    // Calculate category breakdown map
    final Map<String, double> categoryCosts = {
      'Oil Change': 0.0,
      'Tire Rotation': 0.0,
      'Brake Service': 0.0,
      'Engine Check': 0.0,
      'Battery': 0.0,
      'Other': 0.0,
    };

    for (final r in maintenanceProvider.records) {
      final cost = double.tryParse(r.cost.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      final type = r.serviceType;
      if (categoryCosts.containsKey(type)) {
        categoryCosts[type] = (categoryCosts[type] ?? 0.0) + cost;
      } else {
        categoryCosts['Other'] = (categoryCosts['Other'] ?? 0.0) + cost;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLight, width: 2),
                    ),
                    child: const Center(
                      child: Text('👨‍💼', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userProvider.userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${vehicleProvider.vehicles.length} Vehicles',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const Text(' • '),
                            Text(
                              '${maintenanceProvider.records.length} Services',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditProfileDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Expense Breakdown Visual Chart
            ExpenseChart(
              categoryCosts: categoryCosts,
              currency: userProvider.currency,
            ),
            const SizedBox(height: 24),

            // Preferences & Theme Settings Header
            Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Settings Container
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  // Appearance Mode Switcher
                  ListTile(
                    leading: const Icon(Icons.brightness_6_outlined, color: AppColors.primaryLight),
                    title: const Text('Theme Mode'),
                    subtitle: Text(
                      themeProvider.themeMode == ThemeMode.system
                          ? 'System Default'
                          : (themeProvider.themeMode == ThemeMode.dark ? 'Dark Mode 🌙' : 'Light Mode ☀️'),
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<ThemeMode>(
                        value: themeProvider.themeMode,
                        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light ☀️'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark 🌙'),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            themeProvider.setThemeMode(mode);
                          }
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // Currency Preference
                  ListTile(
                    leading: const Icon(Icons.monetization_on_outlined, color: AppColors.primaryLight),
                    title: const Text('Currency Symbol'),
                    subtitle: Text('Current: ${userProvider.currency}'),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: userProvider.currency,
                        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                        items: const [
                          DropdownMenuItem(value: '\$', child: Text('\$ (USD)')),
                          DropdownMenuItem(value: 'ETB', child: Text('ETB (Br)')),
                          DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
                          DropdownMenuItem(value: '£', child: Text('£ (GBP)')),
                        ],
                        onChanged: (curr) {
                          if (curr != null) {
                            userProvider.setCurrency(curr);
                          }
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // Notifications Toggle
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryLight),
                    title: const Text('Service Reminders'),
                    subtitle: const Text('Receive alerts for due oil changes & checks'),
                    value: true,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout / Reset Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  userProvider.setLoggedIn(false);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.danger),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
