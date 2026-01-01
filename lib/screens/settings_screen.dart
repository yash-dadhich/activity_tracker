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
  late TextEditingController _serverUrlController;
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final config = context.read<ActivityProvider>().config;
    _intervalController = TextEditingController(
      text: config.screenshotInterval.toString(),
    );
    _serverUrlController = TextEditingController(text: config.serverUrl);
    _apiKeyController = TextEditingController(text: config.apiKey);
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _serverUrlController.dispose();
    _apiKeyController.dispose();
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
                'Monitoring Settings',
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
              if (config.screenshotEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Screenshot Interval (seconds)',
                      helperText: 'How often to capture screenshots',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Keystroke Tracking'),
                subtitle: const Text('Track keyboard activity'),
                value: config.keystrokeTracking,
                onChanged: (value) {
                  provider.updateConfig(
                    config.copyWith(keystrokeTracking: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Mouse Tracking'),
                subtitle: const Text('Track mouse activity'),
                value: config.mouseTracking,
                onChanged: (value) {
                  provider.updateConfig(
                    config.copyWith(mouseTracking: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Application Tracking'),
                subtitle: const Text('Track active applications'),
                value: config.applicationTracking,
                onChanged: (value) {
                  provider.updateConfig(
                    config.copyWith(applicationTracking: value),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Server Configuration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _serverUrlController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'https://api.example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Enter your API key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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

    final newConfig = config.copyWith(
      screenshotInterval: int.tryParse(_intervalController.text) ?? 300,
      serverUrl: _serverUrlController.text,
      apiKey: _apiKeyController.text,
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
