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
      // Silently fail
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }
}
