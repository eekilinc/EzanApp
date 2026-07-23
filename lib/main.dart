import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/dhikr_screen.dart';
import 'screens/islamic_events_screen.dart';
import 'screens/monthly_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Ezan Hatırlatıcı',
            debugShowCheckedModeBanner: false,
            themeMode: settingsProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green.shade800,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF6F8F6),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: Colors.grey.shade200,
                selectedColor: Colors.green.shade100,
                labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                secondaryLabelStyle: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF10B981),
                brightness: Brightness.dark,
                surface: const Color(0xFF162018),
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF0C130E),
              cardTheme: CardThemeData(
                color: const Color(0xFF18241B),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: const Color(0xFF1A261D),
                selectedColor: Colors.green.shade900,
                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                secondaryLabelStyle: TextStyle(color: Colors.green.shade200, fontWeight: FontWeight.bold),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0F1A11),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              dividerTheme: DividerThemeData(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            home: const HomeScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/about': (context) => const AboutScreen(),
              '/qibla': (context) => const QiblaScreen(),
              '/dhikr': (context) => const DhikrScreen(),
              '/calendar': (context) => const IslamicEventsScreen(),
              '/monthly': (context) => const MonthlyScreen(),
            },
          );
        },
      ),
    );
  }
}
