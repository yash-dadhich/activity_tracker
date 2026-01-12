import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../services/monitoring_service.dart';
import '../services/permission_service.dart';
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
        title: const Text('Screenshot Tracker'),
        actions: [
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
              'This application requires the following permissions to capture screenshots:',
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
            Expanded(child: _buildScreenshotGallery(provider)),
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
                  'Screenshot Capture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: provider.isMonitoring,
                  onChanged: (value) async {
                    print('🎛️ Screenshot capture toggle changed to: $value');
                    final monitoringService = context.read<MonitoringService>();
                    if (value) {
                      print('▶️ Starting screenshot capture...');
                      
                      // Set up callbacks
                      monitoringService.onScreenshotCaptured = (path) {
                        print('📝 Screenshot captured, adding to provider: $path');
                        provider.addScreenshot(path);
                      };
                      
                      await monitoringService.startMonitoring(provider.config);
                      provider.startMonitoring();
                      print('✅ Screenshot capture started');
                    } else {
                      print('⏸️ Stopping screenshot capture...');
                      await monitoringService.stopMonitoring();
                      provider.stopMonitoring();
                      print('✅ Screenshot capture stopped');
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
            if (provider.isMonitoring && provider.config.screenshotEnabled) ...[
              const SizedBox(height: 12),
              Text(
                'Screenshots saved to: Documents/screenshots/activity_tracker/',
                style: const TextStyle(fontSize: 11, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Interval: ${provider.config.screenshotInterval}s | Total: ${provider.screenshotCount}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotGallery(ActivityProvider provider) {
    if (provider.screenshotPaths.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No screenshots captured yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Screenshots will appear here once capture starts',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 16 / 9,
      ),
      itemCount: provider.screenshotPaths.length,
      itemBuilder: (context, index) {
        final screenshotPath = provider.screenshotPaths[index];
        final file = File(screenshotPath);
        
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showScreenshot(context, screenshotPath),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _getFileTimestamp(screenshotPath),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFileTimestamp(String filePath) {
    try {
      final fileName = filePath.split('/').last;
      // Extract timestamp from filename like: screenshot_20241202_1430_25.png
      final match = RegExp(r'screenshot_(\d{8})_(\d{4})_(\d{2})\.png').firstMatch(fileName);
      if (match != null) {
        final date = match.group(1)!;
        final time = match.group(2)!;
        final seconds = match.group(3)!;
        
        final year = date.substring(0, 4);
        final month = date.substring(4, 6);
        final day = date.substring(6, 8);
        final hour = time.substring(0, 2);
        final minute = time.substring(2, 4);
        
        return '$day/$month $hour:$minute:$seconds';
      }
    } catch (e) {
      // Fallback to file modification time
    }
    
    try {
      final file = File(filePath);
      final stat = file.statSync();
      final modified = stat.modified;
      return '${modified.day}/${modified.month} ${modified.hour}:${modified.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
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