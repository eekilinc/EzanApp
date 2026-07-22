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
      if (soundKey == 'adhan') {
        await _audioPlayer.play(AssetSource('sounds/adhan.mp3'));
      } else {
        // Fallback preview for default or beep
        await _audioPlayer.play(AssetSource('sounds/adhan.mp3'));
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
