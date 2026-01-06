import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../providers/activity_provider.dart';
import '../../../services/monitoring_service.dart';
import 'role_based_dashboard.dart';
import 'detailed_activity_dashboard.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final activityProvider = context.read<ActivityProvider>();
    await activityProvider.loadTodayStats();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'My Productivity',
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildMonitoringStatus(),
              const SizedBox(height: 24),
              _buildTodayMetrics(),
              const SizedBox(height: 24),
              _buildProductivityOverview(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildTransparencySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthManager>(
      builder: (context, authManager, child) {
        final user = authManager.currentUser;
        final now = DateTime.now();
        final hour = now.hour;
        
        String greeting;
        if (hour < 12) {
          greeting = 'Good morning';
        } else if (hour < 17) {
          greeting = 'Good afternoon';
        } else {
          greeting = 'Good evening';
        }

        return DashboardCard(
          title: '$greeting, ${user?.firstName ?? 'User'}!',
          subtitle: 'Here\'s your productivity overview for today',
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        );
      },
    );
  }

  Widget _buildMonitoringStatus() {
    return Consumer2<ActivityProvider, AuthManager>(
      builder: (context, activityProvider, authManager, child) {
        final isMonitoring = activityProvider.isMonitoring;
        final canCapture = authManager.canPerformAction('capture_screenshots');
        
        return DashboardCard(
          title: 'Monitoring Status',
          subtitle: isMonitoring ? 'Activity tracking is active' : 'Activity tracking is paused',
          leading: Icon(
            isMonitoring ? Icons.visibility : Icons.visibility_off,
            color: isMonitoring ? Colors.green : Colors.orange,
            size: 32,
          ),
          trailing: Switch(
            value: isMonitoring,
            onChanged: canCapture ? (value) => _toggleMonitoring(value) : null,
          ),
          color: isMonitoring 
            ? Colors.green.withOpacity(0.1) 
            : Colors.orange.withOpacity(0.1),
        );
      },
    );
  }

  Widget _buildTodayMetrics() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildActiveTimeCard(activityProvider),
                MetricCard(
                  title: 'Screenshots',
                  value: '${activityProvider.screenshotCount}',
                  subtitle: 'Captured today',
                  icon: Icons.camera_alt,
                  color: Colors.purple.withOpacity(0.1),
                ),
                MetricCard(
                  title: 'Productivity',
                  value: '${(activityProvider.todayProductivityScore * 100).toInt()}%',
                  subtitle: 'Overall score',
                  icon: Icons.trending_up,
                  color: _getProductivityColor(activityProvider.todayProductivityScore),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Personal Insights')),
                        body: const Center(child: Text('Personal Insights - Coming Soon')),
                      ),
                    ),
                  ),
                ),
                MetricCard(
                  title: 'Applications',
                  value: '${activityProvider.todayAppCount}',
                  subtitle: 'Used today',
                  icon: Icons.apps,
                  color: Colors.orange.withOpacity(0.1),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveTimeCard(ActivityProvider activityProvider) {
    final activeTime = activityProvider.todayActiveTime;
    final totalHours = 8.0; // 8-hour workday
    final progress = activeTime.inMinutes / (totalHours * 60);
    
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Active Time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDurationHMS(activeTime),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hours worked',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityOverview() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        return DashboardCard(
          title: 'Productivity Breakdown',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productivity Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildProductivityBar(
                'Productive',
                activityProvider.todayProductiveTime,
                activityProvider.todayActiveTime,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildProductivityBar(
                'Neutral',
                activityProvider.todayNeutralTime,
                activityProvider.todayActiveTime,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildProductivityBar(
                'Distracting',
                activityProvider.todayDistractingTime,
                activityProvider.todayActiveTime,
                Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductivityBar(String label, Duration value, Duration total, Color color) {
    final percentage = total.inMilliseconds > 0 
      ? (value.inMilliseconds / total.inMilliseconds) 
      : 0.0;
    
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Detailed Monitoring',
                subtitle: 'Real-time activity data',
                leading: const Icon(Icons.monitor, color: Colors.purple),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailedActivityDashboard(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                title: 'View Insights',
                subtitle: 'Personal analytics',
                leading: const Icon(Icons.insights, color: Colors.blue),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('Personal Insights')),
                      body: const Center(child: Text('Personal Insights - Coming Soon')),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Settings',
                subtitle: 'Preferences',
                leading: const Icon(Icons.settings, color: Colors.grey),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                title: 'Data Export',
                subtitle: 'Download your data',
                leading: const Icon(Icons.download, color: Colors.orange),
                onTap: () => _showDataExportDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDataExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Activity Data'),
        content: const Text('Export your comprehensive activity data including keystrokes, mouse events, application usage, and more.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportActivityData();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _exportActivityData() {
    final provider = context.read<ActivityProvider>();
    final activityLog = provider.getDetailedActivityLog();
    final analytics = provider.getProductivityAnalytics();
    
    // In a real app, this would save to file or send to server
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${activityLog.length} activity events and analytics data'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DetailedActivityDashboard(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransparencySection() {
    return DashboardCard(
      title: 'Data Transparency',
      subtitle: 'View what data is being collected about you',
      leading: const Icon(Icons.privacy_tip, color: Colors.green),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Data Overview')),
            body: const Center(child: Text('Data Overview - Coming Soon')),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleMonitoring(bool enabled) async {
    final activityProvider = context.read<ActivityProvider>();
    final monitoringService = context.read<MonitoringService>();
    
    if (enabled) {
      // Set up callbacks
      monitoringService.onScreenshotCaptured = (path) {
        activityProvider.addScreenshot(path);
      };
      
      await monitoringService.startMonitoring(activityProvider.config);
      activityProvider.startMonitoring();
    } else {
      await monitoringService.stopMonitoring();
      activityProvider.stopMonitoring();
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDurationHMS(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getProductivityColor(double score) {
    if (score >= 0.8) return Colors.green.withOpacity(0.1);
    if (score >= 0.6) return Colors.lightGreen.withOpacity(0.1);
    if (score >= 0.4) return Colors.orange.withOpacity(0.1);
    return Colors.red.withOpacity(0.1);
  }
}