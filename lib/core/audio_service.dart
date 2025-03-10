import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:vibration/vibration.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  String _currentSound = 'sounds/whip.mp3';
  double? _originalVolume;
  bool _isPlaying = false;

  Future<void> _setMaxVolume() async {
    if (_originalVolume == null) {
      _originalVolume = await FlutterVolumeController.getVolume();
    }
    await FlutterVolumeController.setVolume(1.0);
  }

  Future<void> _restoreVolume() async {
    if (_originalVolume != null) {
      await FlutterVolumeController.setVolume(_originalVolume!);
      _originalVolume = null; 
    }
  }

  void setSound(String soundPath) {
    _currentSound = soundPath;
  }

  Future<void> playSound() async {
    if (_isPlaying) return;
    _isPlaying = true;

    FlutterVolumeController.updateShowSystemUI(false);
    await _setMaxVolume();

    if (await Vibration.hasCustomVibrationsSupport()) {
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
    } else {
      Vibration.vibrate();
    }

    await _player.play(AssetSource(_currentSound));

    _player.onPlayerComplete.listen((_) async {
      await _restoreVolume();
      _isPlaying = false;
    });
  }
}
