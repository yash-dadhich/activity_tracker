import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/activity_provider.dart';
import '../../../services/comprehensive_monitoring_service.dart';
import 'role_based_dashboard.dart';

class DetailedActivityDashboard extends StatefulWidget {
  const DetailedActivityDashboard({super.key});

  @override
  State<DetailedActivityDashboard> createState() => _DetailedActivityDashboardState();
}

class _DetailedActivityDashboardState extends State<DetailedActivityDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'Detailed Activity Monitoring',
      body: Column(
        children: [
          _buildMonitoringControls(),
          _buildRealTimeStats(),
          Expanded(
            child: _buildDetailedTabs(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringControls() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  provider.isMonitoring ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: provider.isMonitoring ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.isMonitoring ? 'Monitoring Active' : 'Monitoring Stopped',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: provider.isMonitoring ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider.isMonitoring 
                            ? 'Capturing all user activities in real-time'
                            : 'Click start to begin comprehensive monitoring',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (provider.isMonitoring) {
                      await provider.stopMonitoring();
                    } else {
                      await provider.startMonitoring();
                    }
                  },
                  icon: Icon(provider.isMonitoring ? Icons.stop : Icons.play_arrow),
                  label: Text(provider.isMonitoring ? 'Stop' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.isMonitoring ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRealTimeStats() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Real-Time Activity Counters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (provider.isMonitoring)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!provider.isMonitoring) ...[
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.pause_circle_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Monitoring is paused',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildStatChip('Keystrokes', provider.keystrokeCount, Icons.keyboard),
                      _buildStatChip('Mouse Clicks', provider.mouseClickCount, Icons.mouse),
                      _buildStatChip('App Switches', provider.applicationSwitches, Icons.apps),
                      _buildStatChip('File Operations', provider.fileOperations, Icons.folder),
                      _buildStatChip('Website Visits', provider.websiteVisits, Icons.web),
                      _buildStatChip('Screenshots', provider.screenshotsTaken, Icons.camera_alt),
                    ],
                  ),
                  if (provider.keystrokeCount == 0 && 
                      provider.mouseClickCount == 0 && 
                      provider.applicationSwitches == 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Monitoring is active. Start using your computer to see activity data.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String label, int count, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text('$label: $count'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildDetailedTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.keyboard), text: 'Keystrokes'),
            Tab(icon: Icon(Icons.mouse), text: 'Mouse'),
            Tab(icon: Icon(Icons.apps), text: 'Applications'),
            Tab(icon: Icon(Icons.web), text: 'Browser'),
            Tab(icon: Icon(Icons.folder), text: 'Files'),
            Tab(icon: Icon(Icons.screenshot), text: 'Screenshots'),
            Tab(icon: Icon(Icons.desktop_windows), text: 'Screen'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildKeystrokesTab(),
              _buildMouseTab(),
              _buildApplicationsTab(),
              _buildBrowserTab(),
              _buildFilesTab(),
              _buildScreenshotsTab(),
              _buildScreenTab(),
              _buildAnalyticsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeystrokesTab() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final keystrokes = provider.keystrokes;
        
        if (!provider.isMonitoring) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Monitoring is not active',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start monitoring to see keystroke data',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await provider.startMonitoring();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Monitoring'),
                ),
              ],
            ),
          );
        }
        
        if (keystrokes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Collecting keystroke data...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start typing to see keystroke events appear here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: keystrokes.length,
          itemBuilder: (context, index) {
            final keystroke = keystrokes[keystrokes.length - 1 - index]; // Reverse order
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Text(
                    keystroke.key.isNotEmpty ? keystroke.key.toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text('Key: ${keystroke.key} (${keystroke.keyCode})'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App: ${keystroke.application}'),
                    Text('Window: ${keystroke.window}'),
                    if (keystroke.modifiers.isNotEmpty)
                      Text('Modifiers: ${keystroke.modifiers.join(', ')}'),
                  ],
                ),
                trailing: Text(
                  _formatTime(keystroke.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMouseTab() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final mouseEvents = provider.mouseEvents;
        
        if (!provider.isMonitoring) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mouse, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Monitoring is not active',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start monitoring to see mouse activity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        if (mouseEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Collecting mouse data...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Move your mouse or click to see events',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mouseEvents.length,
          itemBuilder: (context, index) {
            final event = mouseEvents[mouseEvents.length - 1 - index]; // Reverse order
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  child: Icon(_getMouseIcon(event.eventType)),
                ),
                title: Text('${event.eventType.toUpperCase()} - ${event.button} button'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Position: (${event.x.toInt()}, ${event.y.toInt()})'),
                    Text('App: ${event.application}'),
                    if (event.clickCount > 1)
                      Text('Click count: ${event.clickCount}'),
                  ],
                ),
                trailing: Text(
                  _formatTime(event.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApplicationsTab() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final appEvents = provider.applicationEvents;
        final timeTracking = provider.applicationTimeTracking;
        
        if (!provider.isMonitoring) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apps, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Monitoring is not active',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start monitoring to track application usage',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // Time tracking summary
            if (timeTracking.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Time Tracking',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...timeTracking.entries.take(5).map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(entry.key)),
                            Text(_formatDuration(entry.value)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ] else if (provider.isMonitoring) ...[
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Collecting application data...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Switch between applications to see tracking data',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Application events
            Expanded(
              child: appEvents.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.apps, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          provider.isMonitoring 
                            ? 'Waiting for application events...'
                            : 'No application events recorded',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: appEvents.length,
                    itemBuilder: (context, index) {
                      final event = appEvents[appEvents.length - 1 - index]; // Reverse order
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.2),
                            child: const Icon(Icons.apps),
                          ),
                          title: Text(event.applicationName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event: ${event.eventType}'),
                              Text('PID: ${event.processId}'),
                              if (event.version.isNotEmpty)
                                Text('Version: ${event.version}'),
                            ],
                          ),
                          trailing: Text(
                            _formatTime(event.timestamp),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrowserTab() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final browserEvents = provider.browserEvents;
        final websiteTracking = provider.websiteTimeTracking;
        
        return Column(
          children: [
            // Website time tracking
            if (websiteTracking.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Website Time Tracking',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...websiteTracking.entries.take(5).map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(entry.key)),
                            Text(_formatDuration(entry.value)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
            // Browser events
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: browserEvents.length,
                itemBuilder: (context, index) {
                  final event = browserEvents[browserEvents.length - 1 - index]; // Reverse order
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(_getBrowserIcon(event.browserName)),
                      ),
                      title: Text(event.title.isNotEmpty ? event.title : event.url),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('URL: ${event.url}'),
                          Text('Browser: ${event.browserName}'),
                          Text('Domain: ${event.domain}'),
                        ],
                      ),
                      trailing: Text(
                        _formatTime(event.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilesTab() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final fileEvents = provider.fileEvents;
        
        if (fileEvents.isEmpty) {
          return const Center(
            child: Text('No file activity detected. File monitoring will show opened/saved files.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fileEvents.length,
          itemBuilder: (context, index) {
            final event = fileEvents[fileEvents.length - 1 - index]; // Reverse order
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(_getFileIcon(event.fileExtension)),
                ),
                title: Text(event.fileName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Operation: ${event.operation}'),
                    Text('Path: ${event.filePath}'),
                    Text('Size: ${_formatFileSize(event.fileSize)}'),
                    Text('App: ${event.application}'),
                  ],
                ),
                trailing: Text(
                  _formatTime(event.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScreenshotsTab() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final screenshots = provider.screenshots;
        
        if (screenshots.isEmpty) {
          return const Center(
            child: Text('No screenshots captured yet. Screenshots are taken automatically every 30 seconds.'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 16 / 9,
          ),
          itemCount: screenshots.length,
          itemBuilder: (context, index) {
            final screenshot = screenshots[screenshots.length - 1 - index]; // Reverse order
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTime(screenshot.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (screenshot.currentApplication != null)
                          Text(
                            screenshot.currentApplication!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScreenTab() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final screenEvents = provider.screenEvents;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: screenEvents.length,
          itemBuilder: (context, index) {
            final event = screenEvents[screenEvents.length - 1 - index]; // Reverse order
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.desktop_windows),
                ),
                title: Text('${event.eventType.toUpperCase()}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Window: ${event.windowTitle}'),
                    Text('App: ${event.applicationName}'),
                    if (event.windowId.isNotEmpty)
                      Text('Window ID: ${event.windowId}'),
                  ],
                ),
                trailing: Text(
                  _formatTime(event.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final analytics = provider.getProductivityAnalytics();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productivity Analytics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAnalyticsRow('Productivity Score', '${(analytics['productivity_score'] * 100).toInt()}%'),
                      _buildAnalyticsRow('Total Active Time', _formatDuration(Duration(seconds: analytics['total_time']))),
                      _buildAnalyticsRow('Productive Time', _formatDuration(Duration(seconds: analytics['productive_time']))),
                      _buildAnalyticsRow('Distracting Time', _formatDuration(Duration(seconds: analytics['distracting_time']))),
                      _buildAnalyticsRow('Neutral Time', _formatDuration(Duration(seconds: analytics['neutral_time']))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Counters',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAnalyticsRow('Keystrokes', '${analytics['keystroke_count']}'),
                      _buildAnalyticsRow('Mouse Clicks', '${analytics['mouse_click_count']}'),
                      _buildAnalyticsRow('Application Switches', '${analytics['application_switches']}'),
                      _buildAnalyticsRow('File Operations', '${analytics['file_operations']}'),
                      _buildAnalyticsRow('Website Visits', '${analytics['website_visits']}'),
                      _buildAnalyticsRow('Screenshots Taken', '${analytics['screenshots_taken']}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getMouseIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'click':
        return Icons.touch_app;
      case 'move':
        return Icons.mouse;
      case 'scroll':
        return Icons.unfold_more;
      default:
        return Icons.mouse;
    }
  }

  IconData _getBrowserIcon(String browserName) {
    switch (browserName.toLowerCase()) {
      case 'chrome':
        return Icons.web;
      case 'safari':
        return Icons.web;
      case 'firefox':
        return Icons.web;
      default:
        return Icons.web;
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'txt':
      case 'md':
        return Icons.text_snippet;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}