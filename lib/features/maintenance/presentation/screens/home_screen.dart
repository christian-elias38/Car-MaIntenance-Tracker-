import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../vehicles/presentation/providers/vehicle_provider.dart';
import '../../../vehicles/presentation/widgets/app_vehicle_image.dart';
import '../../../reminders/presentation/providers/reminder_provider.dart';
import '../providers/maintenance_provider.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/maintenance_tip_card.dart';
import 'edit_maintenance_screen.dart';
import 'service_history_screen.dart';
import '../../../vehicles/presentation/screens/vehicle_details_screen.dart';


class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MaintenanceProvider>().fetchRecords();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this maintenance record?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<MaintenanceProvider>().deleteRecord(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Record deleted successfully!' : 'Failed to delete record.'),
                    backgroundColor: success ? AppColors.primaryLight : AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();
    final vehicleProvider = context.watch<VehicleProvider>();
    final reminderProvider = context.watch<ReminderProvider>();
    final activeCar = vehicleProvider.activeVehicle;

    return Scaffold(
      body: SafeArea(
        child: Consumer<MaintenanceProvider>(
          builder: (context, provider, _) {
            final records = provider.filteredRecords;
            final totalSpentFormatted = '${userProvider.currency}${provider.totalSpent.toStringAsFixed(0)}';

            return RefreshIndicator(
              color: AppColors.primaryLight,
              onRefresh: provider.fetchRecords,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Good evening + Theme Toggle + Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good evening,',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${userProvider.userName} 👋',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Quick Theme Mode Toggle Button (Light / Dark / System)
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: IconButton(
                                tooltip: 'Toggle Theme (Dark / Light / System)',
                                icon: Icon(
                                  themeProvider.themeMode == ThemeMode.light
                                      ? Icons.wb_sunny_rounded
                                      : (themeProvider.themeMode == ThemeMode.dark
                                          ? Icons.nightlight_round
                                          : Icons.brightness_auto_rounded),
                                  size: 22,
                                  color: AppColors.primaryLight,
                                ),
                                onPressed: () {
                                  if (themeProvider.themeMode == ThemeMode.system) {
                                    themeProvider.setThemeMode(ThemeMode.dark);
                                  } else if (themeProvider.themeMode == ThemeMode.dark) {
                                    themeProvider.setThemeMode(ThemeMode.light);
                                  } else {
                                    themeProvider.setThemeMode(ThemeMode.system);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Notification Icon
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_none_outlined, size: 24),
                                    onPressed: () {
                                      if (widget.onNavigateTab != null) {
                                        widget.onNavigateTab!(3);
                                      }
                                    },
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Profile Avatar
                            GestureDetector(
                              onTap: () {
                                if (widget.onNavigateTab != null) {
                                  widget.onNavigateTab!(4);
                                }
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryLight, width: 2),
                                ),
                                child: const Center(
                                  child: Text(
                                    '👨‍💼',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Hero Active Vehicle Banner Card
                    GestureDetector(
                      onTap: () {
                        if (activeCar != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VehicleDetailsScreen(vehicle: activeCar),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.primary.withValues(alpha: 0.12),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.25)
                                  : AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Vehicle Thumbnail Photo
                            AppVehicleImage(
                              imagePath: activeCar?.imagePath ?? 'assets/images/cool_car_landing.jpg',
                              width: 82,
                              height: 64,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          activeCar?.titleWithYear ?? 'Phantom Aero GT (2024)',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Active',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.darkSurface
                                              : AppColors.mintBackground,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          activeCar?.mileage ?? '12,500 km',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryLight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${activeCar?.horsepower ?? '850 hp'} • ${activeCar?.drivetrain ?? 'AWD'}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4 Stat Overview Grid with Visual Sparklines & Badges
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.35,
                      children: [
                        StatCardWidget(
                          icon: Icons.notifications_active_rounded,
                          label: 'Upcoming Services',
                          value: '${reminderProvider.upcomingReminders.length}',
                          badgeText: 'Due Soon',
                          badgeColor: AppColors.statAmber,
                          accentColor: AppColors.statAmber,
                          trendProgress: 0.60,
                          onTap: () {
                            if (widget.onNavigateTab != null) widget.onNavigateTab!(3);
                          },
                        ),
                        StatCardWidget(
                          icon: Icons.build_circle_rounded,
                          label: 'Total Services',
                          value: '${provider.totalServicesCount}',
                          badgeText: 'Tracked',
                          badgeColor: AppColors.primaryLight,
                          accentColor: AppColors.primaryLight,
                          trendProgress: 0.85,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ServiceHistoryScreen()),
                            );
                          },
                        ),
                        StatCardWidget(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Total Spent',
                          value: totalSpentFormatted,
                          badgeText: 'Total',
                          badgeColor: AppColors.statBlue,
                          accentColor: AppColors.statBlue,
                          trendProgress: 0.45,
                          onTap: () {
                            if (widget.onNavigateTab != null) widget.onNavigateTab!(2);
                          },
                        ),
                        StatCardWidget(
                          icon: Icons.event_available_rounded,
                          label: 'Next Service',
                          value: '12 Days',
                          badgeText: 'Scheduled',
                          badgeColor: AppColors.statPurple,
                          accentColor: AppColors.statPurple,
                          trendProgress: 0.90,
                          onTap: () {
                            if (widget.onNavigateTab != null) widget.onNavigateTab!(3);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Vehicle Maintenance Pro Tips Text Card Section
                    const MaintenanceTipCard(),
                    const SizedBox(height: 24),


                    // Search & Filter Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ServiceHistoryScreen()),
                            );
                          },
                          child: const Text(
                            'View all',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Search Input Field
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => provider.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search service history...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearchQuery('');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(context, 'All', provider, isDark),
                          _buildFilterChip(context, 'Oil Change', provider, isDark),
                          _buildFilterChip(context, 'Tire Rotation', provider, isDark),
                          _buildFilterChip(context, 'Brake Service', provider, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Maintenance Records List
                    if (provider.isLoading && provider.records.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primaryLight),
                        ),
                      )
                    else if (provider.errorMessage != null && provider.records.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              provider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => provider.fetchRecords(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (records.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.build_circle_outlined,
                              size: 56,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No maintenance records found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap the + button below to log your first service.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return MaintenanceCard(
                            record: record,
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditMaintenanceScreen(record: record),
                              ),
                            ),
                            onDelete: () => _confirmDelete(context, record.id),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }



  Widget _buildFilterChip(
    BuildContext context,
    String label,
    MaintenanceProvider provider,
    bool isDark,
  ) {
    final isSelected = provider.selectedCategoryFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primaryLight,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.mintBackground,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            provider.setCategoryFilter(label);
          }
        },
      ),
    );
  }
}
