import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playNotificationSound(String soundKey) async {
    try {
      await stop();
      _isPlaying = true;
      String assetPath;
      String fallbackPath;
      switch (soundKey) {
        case 'adhan_madinah':
          assetPath = 'sounds/adhan_madinah.wav';
          fallbackPath = 'sounds/adhan_madinah.mp3';
          break;
        case 'ney':
          assetPath = 'sounds/ney_tone.wav';
          fallbackPath = 'sounds/ney_tone.mp3';
          break;
        case 'beep':
          assetPath = 'sounds/beep_tone.wav';
          fallbackPath = 'sounds/beep_tone.mp3';
          break;
        case 'adhan_makkah':
        case 'adhan':
        default:
          assetPath = 'sounds/adhan_makkah.wav';
          fallbackPath = 'sounds/adhan_makkah.mp3';
          break;
      }
      try {
        await _audioPlayer.play(AssetSource(assetPath));
      } catch (_) {
        await _audioPlayer.play(AssetSource(fallbackPath));
      }
    } catch (e) {
      try {
        await _audioPlayer.play(AssetSource('sounds/adhan.wav'));
      } catch (_) {}
    }
  }

  Future<void> playAdhan(String prayerName) async {
    await playNotificationSound('adhan');
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (_) {}
  }
}
