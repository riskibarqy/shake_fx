import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shake_fx/features/shake_detector/shake_detector.dart';
import 'package:shake_fx/core/audio_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  final ThemeMode themeMode = await ThemePreference.getTheme();
  runApp(MyApp(initialThemeMode: themeMode));
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "ShakeFX",
      content: "Shake detection running...",
    );
  }

  final audioService = AudioService();
  final shakeDetector = ShakeDetector(
    onShake: () => audioService.playSound(),
    shakeThreshold: 15.0,
  );

  shakeDetector.start();
}

bool onIosBackground(ServiceInstance service) {
  return true;
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    await ThemePreference.setTheme(_themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: ShakeScreen(onThemeToggle: _toggleTheme),
    );
  }
}

class ShakeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const ShakeScreen({super.key, required this.onThemeToggle});

  @override
  _ShakeScreenState createState() => _ShakeScreenState();
}

class _ShakeScreenState extends State<ShakeScreen> {
  final AudioService _audioService = AudioService();
  ShakeDetector? _shakeDetector;
  bool _isRunning = false;
  double _sensitivity = 50.0;
  String _selectedSound = 'sounds/whip.mp3';

  final List<Map<String, String>> _sounds = [
    {'name': 'Airhorn', 'path': 'sounds/airhorn.mp3'},
    {'name': 'Ba Dum Tish', 'path': 'sounds/ba-dum-tish.mp3'},
    {'name': 'Ba Dum Tish Remix', 'path': 'sounds/ba-dum-tish-remix.mp3'},
    {'name': 'Beretta M9', 'path': 'sounds/beretta-m9-shot.mp3'},
    {'name': 'Laser', 'path': 'sounds/laser.mp3'},
    {'name': 'Pistol', 'path': 'sounds/pistol.mp3'},
    {'name': 'Pistol 2', 'path': 'sounds/pistol-2.mp3'},
    {'name': 'Whip', 'path': 'sounds/whip.mp3'},
  ];

  void _toggleShakeDetection() {
    if (_isRunning) {
      _shakeDetector?.stop();
    } else {
      _shakeDetector = ShakeDetector(
        onShake: () => _audioService.playSound(),
        shakeThreshold: _sensitivity,
      );
      _shakeDetector?.start();
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _changeSound(String newSound) {
    setState(() {
      _selectedSound = newSound;
      _audioService.setSound(newSound);
    });
  }

  void _changeSensitivity(double newSensitivity) {
    setState(() {
      _sensitivity = newSensitivity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ShakeFX", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text("Shake Detection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: Text(_isRunning ? "Running in background" : "Stopped"),
                      value: _isRunning,
                      onChanged: (bool value) => _toggleShakeDetection(),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text("Select Sound", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: _selectedSound,
                      isExpanded: true,
                      onChanged: (String? newSound) {
                        if (newSound != null) _changeSound(newSound);
                      },
                      items: _sounds.map<DropdownMenuItem<String>>((sound) {
                        return DropdownMenuItem<String>(
                          value: sound['path'],
                          child: Text(sound['name']!),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Shake Sensitivity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Slider(
                      value: _sensitivity,
                      min: 5,
                      max: 50,
                      divisions: 9,
                      label: _sensitivity.toStringAsFixed(1),
                      onChanged: _isRunning ? null : _changeSensitivity,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemePreference {
  static const String _key = "themeMode";

  static Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }

  static Future<ThemeMode> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt(_key);
    return ThemeMode.values[themeIndex ?? ThemeMode.system.index];
  }
}
