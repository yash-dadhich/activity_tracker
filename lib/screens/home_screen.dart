import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../services/monitoring_service.dart';
import '../services/permission_service.dart';
import 'reports_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, bool> _permissions = {};
  bool _isCheckingPermissions = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissionService = context.read<PermissionService>();
    final permissions = await permissionService.checkAllPermissions();
    setState(() {
      _permissions = permissions;
      _isCheckingPermissions = false;
    });
  }

  bool get _hasAllPermissions {
    if (!Platform.isMacOS) return true;
    return _permissions['screenRecording'] == true && 
           _permissions['accessibility'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportsScreen()),
            ),
            tooltip: 'Reports',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isCheckingPermissions
          ? const Center(child: CircularProgressIndicator())
          : !_hasAllPermissions
              ? _buildPermissionRequired()
              : _buildMainContent(),
    );
  }

  Widget _buildPermissionRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Permissions Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This application requires the following permissions to function:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPermissionItem(
              'Screen Recording',
              _permissions['screenRecording'] ?? false,
            ),
            _buildPermissionItem(
              'Accessibility',
              _permissions['accessibility'] ?? false,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final permissionService = context.read<PermissionService>();
                await permissionService.openSystemPreferences();
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open System Preferences'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _checkPermissions,
              child: const Text('Recheck Permissions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(String name, bool granted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(name),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildStatusCard(provider),
            _buildStatsCard(provider),
            Expanded(child: _buildActivityList(provider)),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(ActivityProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monitoring Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: provider.isMonitoring,
                  onChanged: (value) async {
                    print('🎛️ Monitoring toggle changed to: $value');
                    final monitoringService = context.read<MonitoringService>();
                    if (value) {
                      print('▶️ Starting monitoring...');
                      
                      // Set up callbacks
                      monitoringService.onActivityTracked = (log) {
                        print('📝 Activity tracked, adding to provider');
                        provider.addActivityLog(log);
                        provider.updateCurrentApplication(log.applicationName);
                        provider.incrementKeystrokes(log.keystrokes);
                        provider.incrementMouseClicks(log.mouseClicks);
                      };
                      
                      await monitoringService.startMonitoring(provider.config);
                      provider.startMonitoring();
                      print('✅ Monitoring started');
                    } else {
                      print('⏸️ Stopping monitoring...');
                      await monitoringService.stopMonitoring();
                      provider.stopMonitoring();
                      print('✅ Monitoring stopped');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  provider.isMonitoring ? Icons.circle : Icons.circle_outlined,
                  color: provider.isMonitoring ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  provider.isMonitoring ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: provider.isMonitoring ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            if (provider.isMonitoring) ...[
              const SizedBox(height: 12),
              Text(
                'Current App: ${provider.currentApplication}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(ActivityProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              Icons.keyboard,
              'Keystrokes',
              provider.todayKeystrokes.toString(),
            ),
            _buildStatItem(
              Icons.mouse,
              'Clicks',
              provider.todayMouseClicks.toString(),
            ),
            _buildStatItem(
              Icons.camera_alt,
              'Screenshots',
              provider.screenshotCount.toString(),
            ),
            _buildStatItem(
              Icons.list,
              'Logs',
              provider.activityLogs.length.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActivityList(ActivityProvider provider) {
    if (provider.activityLogs.isEmpty) {
      return const Center(
        child: Text('No activity logs yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.activityLogs.length,
      itemBuilder: (context, index) {
        final log = provider.activityLogs[index];
        return Card(
          child: ListTile(
            leading: Icon(
              log.screenshotPath != null 
                  ? Icons.camera_alt 
                  : (log.isIdle ? Icons.bedtime : Icons.computer),
              color: log.screenshotPath != null 
                  ? Colors.green 
                  : (log.isIdle ? Colors.grey : Colors.blue),
            ),
            title: Text(log.applicationName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.screenshotPath != null 
                      ? '📸 Screenshot captured'
                      : log.detailedSummary,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (log.screenshotPath != null)
                  Text(
                    log.screenshotPath!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (log.detailedInfo != null && log.detailedInfo!.isNotEmpty && log.screenshotPath == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 4,
                      children: log.detailedInfo!.entries.take(3).map((entry) {
                        return Chip(
                          label: Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
            trailing: Text(
              '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12),
            ),
            onTap: log.screenshotPath != null 
                ? () => _showScreenshot(context, log.screenshotPath!)
                : null,
          ),
        );
      },
    );
  }

  void _showScreenshot(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Screenshot'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Failed to load screenshot'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
