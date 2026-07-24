import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/dhikr_screen.dart';
import 'screens/islamic_events_screen.dart';
import 'screens/monthly_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/duas_screen.dart';
import 'screens/alarm_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('tr', null);
    await initializeDateFormatting('en', null);
  } catch (_) {}
  final notificationService = NotificationService();
  await notificationService.initialize(
    onSelectNotification: (payload) {
      navigatorKey.currentState?.pushNamed('/alarm');
    },
  );
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
            navigatorKey: navigatorKey,
            title: 'Ezan Hatırlatıcı',
            debugShowCheckedModeBanner: false,
            themeMode: settingsProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: settingsProvider.primaryColor,
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
                selectedColor: settingsProvider.primaryColor.withValues(alpha: 0.2),
                labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                secondaryLabelStyle: TextStyle(color: settingsProvider.primaryColor, fontWeight: FontWeight.bold),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: settingsProvider.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: settingsProvider.primaryColor,
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
                selectedColor: settingsProvider.primaryColor,
                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/about': (context) => const AboutScreen(),
              '/qibla': (context) => const QiblaScreen(),
              '/dhikr': (context) => const DhikrScreen(),
              '/calendar': (context) => const IslamicEventsScreen(),
              '/monthly': (context) => const MonthlyScreen(),
              '/duas': (context) => const DuasScreen(),
              '/alarm': (context) => const AlarmScreen(),
            },
          );
        },
      ),
    );
  }
}
