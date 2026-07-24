import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      notifyListeners();
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      final playing = state == PlayerState.playing;
      if (_isPlaying != playing) {
        _isPlaying = playing;
        notifyListeners();
      }
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playNotificationSound(String soundKey) async {
    try {
      await stop();
      _isPlaying = true;
      notifyListeners();

      String assetPath;
      switch (soundKey) {
        case 'adhan_madinah':
          assetPath = 'sounds/adhan_madinah.mp3';
          break;
        case 'adhan_istanbul':
          assetPath = 'sounds/adhan_istanbul.mp3';
          break;
        case 'adhan_cairo':
          assetPath = 'sounds/adhan_cairo.mp3';
          break;
        case 'adhan_aqsa':
          assetPath = 'sounds/adhan_aqsa.mp3';
          break;
        case 'cagri':
          assetPath = 'sounds/cagri_theme.wav';
          break;
        case 'chime':
          assetPath = 'sounds/salavat_chime.wav';
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
      } catch (_) {
        _isPlaying = false;
        notifyListeners();
      }
    }
  }

  Future<void> playAdhan(String prayerName) async {
    await playNotificationSound('adhan');
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (_) {}
  }
}
