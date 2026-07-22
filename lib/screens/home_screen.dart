import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/prayer_card.dart';
import '../widgets/location_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    final prayerProvider =
        Provider.of<PrayerProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    await settingsProvider.init();
    await prayerProvider.initializeLocation();
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => LocationPicker(
        cities: context.read<PrayerProvider>().getCityList(),
        onCitySelected: (city) {
          context.read<PrayerProvider>().selectCity(city);
        },
        onUseGpsPressed: () {
          context.read<PrayerProvider>().useGpsLocation();
          Navigator.pop(context);
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ezan Hatırlatıcı'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer2<PrayerProvider, SettingsProvider>(
            builder: (context, prayerProvider, settingsProvider, _) {
              if (prayerProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (prayerProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Hata: ${prayerProvider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            prayerProvider.loadPrayerTimes(),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                );
              }

              if (prayerProvider.prayerTimes == null) {
                return const Center(
                  child: Text('Namaz saatleri yüklenemedi'),
                );
              }

              final prayers = prayerProvider.prayerTimes!.getPrayerList();
              final nextPrayer = prayerProvider.getNextPrayer();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Location info
                    Container(
                      color: Colors.green[50],
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  prayerProvider.location?.city ?? 'Bilinmiyor',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: _showLocationPicker,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Next prayer countdown
                    if (nextPrayer != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Sonraki Namaz',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nextPrayer.getDisplayTime(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),

                    // Prayer times list
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Bugünün Namaz Saatleri',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ...prayers.map((prayer) {
                      final minutes = settingsProvider.getReminderMinutes(
                        prayer.name,
                      );
                      return PrayerCard(
                        prayer: prayer,
                        minutesBefore: minutes,
                        isNext: prayer.name == nextPrayer?.name,
                      );
                    }).toList(),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
