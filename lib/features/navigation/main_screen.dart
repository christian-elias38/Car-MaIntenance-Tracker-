import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../maintenance/presentation/screens/home_screen.dart';
import '../vehicles/presentation/screens/vehicles_screen.dart';
import '../maintenance/presentation/screens/add_maintenance_screen.dart';
import '../reminders/presentation/screens/reminders_screen.dart';
import '../profile/presentation/screens/profile_settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) {
      // Center Add button opens AddMaintenanceScreen modal/screen directly
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddMaintenanceScreen()),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      HomeScreen(onNavigateTab: (idx) => setState(() => _currentIndex = idx)),
      const VehiclesScreen(),
      const SizedBox.shrink(), // Center Add placeholder
      const RemindersScreen(),
      const ProfileSettingsScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex == 2 ? 0 : _currentIndex,
                  onDestinationSelected: _onTabTapped,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                  selectedIconTheme: const IconThemeData(color: AppColors.primaryLight, size: 28),
                  unselectedIconTheme: IconThemeData(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, size: 24),
                  selectedLabelTextStyle: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelTextStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 12),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 26),
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddMaintenanceScreen()),
                            );
                          },
                          backgroundColor: AppColors.primaryLight,
                          tooltip: 'Add Log',
                          child: const Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_filled),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.directions_car_outlined),
                      selectedIcon: Icon(Icons.directions_car_rounded),
                      label: Text('Vehicles'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded),
                      label: Text('Reminders'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primaryLight,
              unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car_rounded),
                  label: 'Vehicles',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4016A34A),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_rounded),
                  label: 'Reminders',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
