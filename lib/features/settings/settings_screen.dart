import 'package:flutter/material.dart';
import 'package:shake_fx/core/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  final AudioService audioService;
  const SettingsScreen({required this.audioService, super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedSound = 'sounds/whip.mp3';

  final List<Map<String, String>> sounds = [
    {'name': 'Airhorn', 'path': 'sounds/airhorn.mp3'},
    {'name': 'Ba Dum Tish', 'path': 'sounds/ba-dum-tish.mp3'},
    {'name': 'Ba Dum Tish Remix', 'path': 'sounds/ba-dum-tish-remix.mp3'},
    {'name': 'Beretta M9', 'path': 'sounds/beretta-m9-shot.mp3'},
    {'name': 'Laser', 'path': 'sounds/laser.mp3'},
    {'name': 'Pistol', 'path': 'sounds/pistol.mp3'},
    {'name': 'Pistol 2', 'path': 'sounds/pistol-2.mp3'},
    {'name': 'Whip', 'path': 'sounds/whip.mp3'},
  ];

  void _changeSound(String newSound) {
    setState(() {
      _selectedSound = newSound;
      widget.audioService.setSound(newSound);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: sounds.map((sound) {
          return ListTile(
            title: Text(sound['name']!),
            trailing: _selectedSound == sound['path']
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () => _changeSound(sound['path']!),
          );
        }).toList(),
      ),
    );
  }
}
