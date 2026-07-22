import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerProvider>();
    final location = prayerProvider.location;

    final qiblaAngle = location != null
        ? QiblaService.calculateQiblaDirection(location.latitude, location.longitude)
        : 147.0;

    final distanceKm = location != null
        ? QiblaService.calculateDistanceToMecca(location.latitude, location.longitude)
        : 2400.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble Pusulası'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade900, Colors.green.shade700, Colors.grey.shade900],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Location summary badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        location?.city ?? 'Konum Seçilmedi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Compass Dial Card
                Container(
                  width: 300,
                  height: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.amber.shade400, width: 3),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Degree Markings
                      ...List.generate(12, (index) {
                        final angle = index * 30.0;
                        return Transform.rotate(
                          angle: angle * (math.pi / 180),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 2,
                              height: 10,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      }),

                      // Cardinal Directions
                      const Positioned(
                        top: 25,
                        child: Text('K (North)', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const Positioned(
                        bottom: 25,
                        child: Text('G (South)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      const Positioned(
                        right: 25,
                        child: Text('D (East)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      const Positioned(
                        left: 25,
                        child: Text('B (West)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ),

                      // Animated Qibla Needle
                      Transform.rotate(
                        angle: qiblaAngle * (math.pi / 180),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.navigation,
                              size: 72,
                              color: Colors.amber,
                            ),
                            Container(
                              width: 6,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade300,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Kaaba Icon in Center
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: const Icon(Icons.mosque, color: Colors.amber, size: 24),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Qibla Info Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Kıble Açısı', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${qiblaAngle.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      Column(
                        children: [
                          const Text('Kâbe\'ye Uzaklık', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${distanceKm.toStringAsFixed(0)} km',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '💡 Doğru yön için cihazınızı düz bir zeminde tutunuz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
