import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';

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
      child: MaterialApp(
        title: 'Ezan Hatırlatıcı',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/settings': (context) => const SettingsScreen(),
          '/about': (context) => const AboutScreen(),
        },
      ),
    );
  }
}
