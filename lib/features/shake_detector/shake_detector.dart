import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  final Function onShake;
  final double shakeThreshold;
  StreamSubscription? _subscription;

  ShakeDetector({required this.onShake, this.shakeThreshold = 15.0});

  void start() {
    _subscription = accelerometerEventStream().listen((event) {
      double acceleration = event.x * event.x + event.y * event.y + event.z * event.z;
      if (acceleration > shakeThreshold * shakeThreshold) {
        onShake();
      }
    });
  }

  void stop() {
    _subscription?.cancel();
  }
}
