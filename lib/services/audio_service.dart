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
      switch (soundKey) {
        case 'adhan_madinah':
          assetPath = 'sounds/adhan_madinah.mp3';
          break;
        case 'ney':
          assetPath = 'sounds/ney_tone.mp3';
          break;
        case 'beep':
          assetPath = 'sounds/beep_tone.mp3';
          break;
        case 'adhan_makkah':
        case 'adhan':
        default:
          assetPath = 'sounds/adhan_makkah.mp3';
          break;
      }
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      try {
        await _audioPlayer.play(AssetSource('sounds/adhan.mp3'));
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
