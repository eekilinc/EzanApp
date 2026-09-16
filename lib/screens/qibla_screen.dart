import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _deviceHeading = 0.0; // Device Heading from North (0..360°)
  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _hasCompassSensor = false;
  bool _manualMode = false;
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    _initCompass();
  }

  double _smoothHeading(double oldHeading, double newHeading) {
    double diff = newHeading - oldHeading;
    if (diff < -180) diff += 360;
    if (diff > 180) diff -= 360;
    return (oldHeading + diff * 0.25 + 360) % 360;
  }

  void _initCompass() {
    try {
      final events = FlutterCompass.events;
      if (events == null) {
        // Pusula sensörü yok — manuel modda başla.
        if (mounted) {
          setState(() {
            _hasCompassSensor = false;
            _manualMode = true;
          });
        }
        return;
      }
      _compassSubscription = events.listen((event) {
        if (event.heading != null && mounted && !_manualMode) {
          final targetHeading = (event.heading! + 360) % 360;
          final smoothed = _smoothHeading(_deviceHeading, targetHeading);
          // Hizalanma titreşimi build() içinde değil burada (side-effect güvenli).
          var aligned = _wasAligned;
          try {
            final loc = context.read<PrayerProvider>().location;
            if (loc != null) {
              final q = QiblaService.calculateQiblaDirection(
                  loc.latitude, loc.longitude);
              final rel = (q - smoothed + 360) % 360;
              final nowAligned = (rel < 6 || rel > 354);
              if (nowAligned && !_wasAligned) {
                HapticFeedback.mediumImpact();
              }
              aligned = nowAligned;
            }
          } catch (_) {}
          setState(() {
            _deviceHeading = smoothed;
            _hasCompassSensor = true;
            _wasAligned = aligned;
          });
        }
      }, onError: (_) {
        if (mounted) {
          setState(() {
            _hasCompassSensor = false;
            _manualMode = true;
          });
        }
      });
    } catch (_) {
      _hasCompassSensor = false;
      _manualMode = true;
    }
  }

  void _switchToManual(double value) {
    // Kullanıcı kaydırıcıya dokununca canlı sensörü bırak, manuel kalibrasyona geç.
    _compassSubscription?.cancel();
    _compassSubscription = null;
    setState(() {
      _manualMode = true;
      _deviceHeading = value;
      _wasAligned = false;
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final location = prayerProvider.location;

    // Konum yoksa sahte İstanbul değeri gösterme — yer tutucu + bilgi.
    final qiblaAngle = location != null
        ? QiblaService.calculateQiblaDirection(location.latitude, location.longitude)
        : null;

    final distanceKm = location != null
        ? QiblaService.calculateDistanceToMecca(location.latitude, location.longitude)
        : null;

    // Calculate relative rotation angle for needle/dial relative to device heading
    final relativeQiblaAngle =
        qiblaAngle != null ? (qiblaAngle - _deviceHeading + 360) % 360 : 0.0;
    final isAligned =
        qiblaAngle != null && (relativeQiblaAngle < 6 || relativeQiblaAngle > 354);

    // Manuel modda hizalanma rozeti canlı titreşim üretmez; _wasAligned
    // yalnızca canlı sensör akışında güncellenir (listener içinde).

    return Scaffold(
      appBar: AppBar(
        title: Text(settingsProvider.tr('qibla')),
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
            colors: isAligned
                ? [Colors.green.shade900, Colors.teal.shade800, Colors.grey.shade900]
                : [Colors.green.shade900, Colors.green.shade800, Colors.grey.shade900],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Alignment status badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAligned
                        ? Colors.lightGreen.shade700
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isAligned ? Colors.amber : Colors.white.withValues(alpha: 0.3),
                      width: isAligned ? 2 : 1,
                    ),
                    boxShadow: isAligned
                        ? [
                            BoxShadow(
                              color: Colors.lightGreen.withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAligned ? Icons.check_circle : Icons.location_on,
                        color: isAligned ? Colors.amber : Colors.amber.shade300,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAligned
                            ? settingsProvider.tr('qibla_aligned')
                            : (qiblaAngle != null
                                ? '${(location?.city == "Current Location" || location?.city == "current_location") ? settingsProvider.tr("current_location") : (location?.city ?? settingsProvider.tr("location"))}: ${qiblaAngle.toStringAsFixed(1)}°'
                                : settingsProvider.tr('qibla_no_location')),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Compass Dial Card
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 300,
                  height: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.35),
                    boxShadow: [
                      BoxShadow(
                        color: isAligned
                            ? Colors.amber.withValues(alpha: 0.4)
                            : Colors.greenAccent.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(
                      color: isAligned ? Colors.amber.shade300 : Colors.amber.shade600,
                      width: isAligned ? 4 : 3,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating Compass Ring (Relative to device heading)
                      Transform.rotate(
                        angle: -_deviceHeading * (math.pi / 180),
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
                            Positioned(
                              top: 20,
                              child: Text('${settingsProvider.tr('cardinal_n')} (0°)', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            Positioned(
                              bottom: 20,
                              child: Text('${settingsProvider.tr('cardinal_s')} (180°)', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ),
                            Positioned(
                              right: 20,
                              child: Text('${settingsProvider.tr('cardinal_e')} (90°)', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ),
                            Positioned(
                              left: 20,
                              child: Text('${settingsProvider.tr('cardinal_w')} (270°)', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),

                      // Animated Qibla Needle (Rotated relative to device heading)
                      Transform.rotate(
                        angle: relativeQiblaAngle * (math.pi / 180),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.navigation,
                              size: 76,
                              color: isAligned ? Colors.amber.shade300 : Colors.amber,
                            ),
                            Container(
                              width: 6,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isAligned ? Colors.amber : Colors.amber.shade400,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Kaaba Icon in Center
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isAligned ? Colors.teal.shade900 : Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Icon(Icons.mosque, color: isAligned ? Colors.amber : Colors.amber.shade200, size: 26),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Manual Heading Adjustment Slider for Calibration
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                settingsProvider.tr('device_heading'),
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (_hasCompassSensor && !_manualMode) ? Colors.green.shade800 : Colors.orange.shade900,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  (_hasCompassSensor && !_manualMode)
                                      ? settingsProvider.tr('qibla_live')
                                      : settingsProvider.tr('qibla_manual'),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_deviceHeading.toInt()}°',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Slider(
                        value: _deviceHeading,
                        min: 0,
                        max: 360,
                        activeColor: Colors.amber,
                        inactiveColor: Colors.white24,
                        onChanged: _switchToManual,
                      ),
                      if (!_hasCompassSensor || _manualMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            settingsProvider.tr('qibla_manual_hint'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

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
                          Text(settingsProvider.tr('qibla_angle'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            qiblaAngle != null
                                ? '${qiblaAngle.toStringAsFixed(1)}°'
                                : '--',
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
                          Text(settingsProvider.tr('distance_to_kaaba'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            distanceKm != null
                                ? '${distanceKm.toStringAsFixed(0)} km'
                                : '--',
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
                Text(
                  settingsProvider.tr('qibla_guide'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
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
