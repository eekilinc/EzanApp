import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/audio_service.dart';
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
      if (payload == 'alarm') {
        bool isAlreadyOnAlarm = false;
        navigatorKey.currentState?.popUntil((route) {
          if (route.settings.name == '/alarm') {
            isAlreadyOnAlarm = true;
          }
          return true;
        });

        if (!isAlreadyOnAlarm) {
          navigatorKey.currentState?.pushNamed('/alarm');
        } else {
          final context = navigatorKey.currentContext;
          if (context != null) {
            try {
              final settingsProvider = context.read<SettingsProvider>();
              if (settingsProvider.effectiveAdhanSoundEnabled) {
                AudioService().playNotificationSound(
                  settingsProvider.adhanSound,
                );
              }
            } catch (_) {}
          }
        }
      } else {
        // Persistent status bar notification or home payload -> open main app screen cleanly
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    },
  );

  // Ayarları runApp'den önce yükle: aksi hâlde MaterialApp ilk frame'i
  // varsayılan temayla çizip splash'ta görünür bir renk değişimi (flash)
  // yapar. Provider artık hazır olduğu için aşağıda .value ile veriliyor.
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(EzanApp(settingsProvider: settingsProvider));
}

class EzanApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const EzanApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Ezan Hatırlatıcı',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: settings.primaryColor,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.lightScaffold,
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
                selectedColor: settings.primaryColor.withValues(alpha: 0.2),
                labelStyle: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                secondaryLabelStyle: TextStyle(
                  color: settings.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: settings.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: settings.primaryColor,
                brightness: Brightness.dark,
                surface: AppColors.darkSurface,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.darkScaffold,
              cardTheme: CardThemeData(
                color: AppColors.darkCard,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: AppColors.darkCardAlt,
                selectedColor: settings.primaryColor,
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                secondaryLabelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkAppBar,
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
