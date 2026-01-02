import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/monitoring_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();
    final config = context.read<ActivityProvider>().config;
    _intervalController = TextEditingController(
      text: config.screenshotInterval.toString(),
    );
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          final config = provider.config;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Screenshot Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Screenshot Capture'),
                subtitle: const Text('Capture screenshots at intervals'),
                value: config.screenshotEnabled,
                onChanged: (value) {
                  provider.updateConfig(
                    config.copyWith(screenshotEnabled: value),
                  );
                },
              ),
              if (config.screenshotEnabled) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Screenshot Interval (seconds)',
                      helperText: 'How often to capture screenshots (minimum: 10 seconds)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Storage Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Screenshots are saved to:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Documents/screenshots/activity_tracker/',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Files are named with timestamp: screenshot_YYYYMMDD_HHMM_SS.png',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Privacy & Security',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Data Storage',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• All screenshots are stored locally on your device\n'
                      '• No data is sent to external servers\n'
                      '• You can delete screenshots manually from the folder',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveSettings() {
    final provider = context.read<ActivityProvider>();
    final config = provider.config;

    // Validate interval
    int interval = int.tryParse(_intervalController.text) ?? 30;
    if (interval < 10) {
      interval = 10; // Minimum 10 seconds
      _intervalController.text = '10';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum interval is 10 seconds'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    final newConfig = config.copyWith(
      screenshotInterval: interval,
    );

    print('💾 Saving settings: ${newConfig.toJson()}');
    provider.updateConfig(newConfig);
    print('✅ Settings saved successfully');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );

    Navigator.pop(context);
  }
}