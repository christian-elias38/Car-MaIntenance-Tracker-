import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/maintenance/presentation/providers/maintenance_provider.dart';
import 'features/vehicles/presentation/providers/vehicle_provider.dart';
import 'features/reminders/presentation/providers/reminder_provider.dart';
import 'features/profile/presentation/providers/user_provider.dart';
import 'features/auth/presentation/screens/welcome_onboarding_screen.dart';
import 'features/navigation/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
      ],
      child: Consumer2<ThemeProvider, UserProvider>(
        builder: (context, themeProvider, userProvider, _) {
          return MaterialApp(
            title: 'CarTrack - Car Maintenance Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: userProvider.hasCompletedOnboarding
                ? const MainScreen()
                : const WelcomeOnboardingScreen(),
          );
        },
      ),
    );
  }
}
