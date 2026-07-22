import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAdhan(String prayerName) async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/adhan.mp3'),
      );
    } catch (e) {
      try {
        await _audioPlayer.play(
          AssetSource('sounds/adhan.wav'),
        );
      } catch (_) {}
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (_) {}
  }
}
