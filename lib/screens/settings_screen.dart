import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SharedPreferences? _prefs;
  bool _autoPlay = true;
  bool _saveHistory = true;
  bool _showSyncedLyrics = true;
  bool _dynamicColors = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _autoPlay = _prefs?.getBool('autoPlay') ?? true;
        _saveHistory = _prefs?.getBool('saveHistory') ?? true;
        _showSyncedLyrics = _prefs?.getBool('showSyncedLyrics') ?? true;
        _dynamicColors = _prefs?.getBool('dynamicColors') ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Playback Settings
        _buildSettingCard(
          title: 'Playback',
          icon: Icons.play_circle,
          child: SwitchListTile(
            title: const Text('Auto-play Next Song', style: TextStyle(color: Colors.white)),
            value: _autoPlay,
            onChanged: (value) async {
              await _prefs?.setBool('autoPlay', value);
              setState(() => _autoPlay = value);
            },
          ),
        ),

        // Lyrics Settings
        _buildSettingCard(
          title: 'Lyrics',
          icon: Icons.lyrics,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Show Synchronized Lyrics', style: TextStyle(color: Colors.white)),
                value: _showSyncedLyrics,
                onChanged: (value) async {
                  await _prefs?.setBool('showSyncedLyrics', value);
                  setState(() => _showSyncedLyrics = value);
                },
              ),
              SwitchListTile(
                title: const Text('Dynamic Colors', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Change colors based on album art', style: TextStyle(color: Colors.white70)),
                value: _dynamicColors,
                onChanged: (value) async {
                  await _prefs?.setBool('dynamicColors', value);
                  setState(() => _dynamicColors = value);
                },
              ),
            ],
          ),
        ),

        // Storage Settings
        _buildSettingCard(
          title: 'Storage',
          icon: Icons.storage,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Save Search History', style: TextStyle(color: Colors.white)),
                value: _saveHistory,
                onChanged: (value) async {
                  await _prefs?.setBool('saveHistory', value);
                  setState(() => _saveHistory = value);
                },
              ),
              ListTile(
                title: const Text('Clear Search History', style: TextStyle(color: Colors.white)),
                trailing: TextButton(
                  onPressed: () async {
                    await _prefs?.remove('searchHistory');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search history cleared')),
                      );
                    }
                  },
                  child: const Text('CLEAR'),
                ),
              ),
            ],
          ),
        ),

        // About Card
        _buildSettingCard(
          title: 'About',
          icon: Icons.info,
          child: Column(
            children: [
              ListTile(
                title: const Text('Made with ❤️ by', style: TextStyle(color: Colors.white)),
                trailing: const Text('Similoluwa', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                title: const Text('Rate App', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.star, color: Colors.white),
                onTap: () {
                  // Add app store link
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
} 