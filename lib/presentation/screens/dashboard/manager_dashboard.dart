import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/team_provider.dart';
import 'role_based_dashboard.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final teamProvider = context.read<TeamProvider>();
    await teamProvider.loadTeamData();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'Team Management',
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildTeamOverview(),
              const SizedBox(height: 24),
              _buildTeamMetrics(),
              const SizedBox(height: 24),
              _buildProductivityTrends(),
              const SizedBox(height: 24),
              _buildTeamAlerts(),
              const SizedBox(height: 24),
              _buildQuickActions(),
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
        
        return DashboardCard(
          title: 'Team Dashboard',
          subtitle: 'Monitor and manage your team\'s productivity',
          leading: const Icon(
            Icons.groups,
            size: 32,
            color: Colors.blue,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back, ${user?.firstName ?? 'Manager'}! Here\'s your team overview.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<TeamProvider>(
                builder: (context, teamProvider, child) {
                  return Row(
                    children: [
                      _buildQuickStat(
                        'Team Members',
                        '${teamProvider.teamMembers.length}',
                        Icons.people,
                        Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildQuickStat(
                        'Active Today',
                        '${teamProvider.activeToday}',
                        Icons.online_prediction,
                        Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildQuickStat(
                        'Avg Score',
                        '${(teamProvider.averageProductivityScore * 100).toInt()}%',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamOverview() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Overview',
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
                MetricCard(
                  title: 'Total Hours',
                  value: _formatHours(teamProvider.totalHoursToday),
                  subtitle: 'Worked today',
                  icon: Icons.access_time,
                  color: Colors.blue.withOpacity(0.1),
                ),
                MetricCard(
                  title: 'Productivity',
                  value: '${(teamProvider.averageProductivityScore * 100).toInt()}%',
                  subtitle: 'Team average',
                  icon: Icons.trending_up,
                  color: _getProductivityColor(teamProvider.averageProductivityScore),
                ),
                MetricCard(
                  title: 'Top Performer',
                  value: teamProvider.topPerformer?.firstName ?? 'N/A',
                  subtitle: 'This week',
                  icon: Icons.star,
                  color: Colors.amber.withOpacity(0.1),
                ),
                MetricCard(
                  title: 'Alerts',
                  value: '${teamProvider.activeAlerts}',
                  subtitle: 'Require attention',
                  icon: Icons.warning,
                  color: teamProvider.activeAlerts > 0 
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamMetrics() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        return DashboardCard(
          title: 'Team Performance Metrics',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Performance Metrics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildMetricBar(
                'Productive Time',
                teamProvider.teamProductiveTime,
                teamProvider.teamTotalTime,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildMetricBar(
                'Neutral Time',
                teamProvider.teamNeutralTime,
                teamProvider.teamTotalTime,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildMetricBar(
                'Distracting Time',
                teamProvider.teamDistractingTime,
                teamProvider.teamTotalTime,
                Colors.red,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Team Analytics')),
                          body: const Center(child: Text('Team Analytics - Coming Soon')),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Detailed Analytics'),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Team Reports')),
                          body: const Center(child: Text('Team Reports - Coming Soon')),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.assessment),
                    label: const Text('Generate Report'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricBar(String label, Duration value, Duration total, Color color) {
    final percentage = total.inMilliseconds > 0 
      ? (value.inMilliseconds / total.inMilliseconds) 
      : 0.0;
    
    return Row(
      children: [
        SizedBox(
          width: 100,
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

  Widget _buildProductivityTrends() {
    return DashboardCard(
      title: 'Productivity Trends',
      subtitle: 'Last 7 days team performance',
      leading: const Icon(Icons.show_chart, color: Colors.purple),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productivity Trends',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last 7 days team performance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder for chart - would integrate with fl_chart package
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Productivity Trend Chart\n(Integration with fl_chart)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamAlerts() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        if (teamProvider.alerts.isEmpty) {
          return DashboardCard(
            title: 'Team Alerts',
            subtitle: 'No alerts at this time',
            leading: const Icon(Icons.check_circle, color: Colors.green),
            color: Colors.green.withOpacity(0.1),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Alerts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...teamProvider.alerts.take(3).map((alert) => Card(
              color: _getAlertColor(alert.severity),
              child: ListTile(
                leading: Icon(
                  _getAlertIcon(alert.type),
                  color: _getAlertIconColor(alert.severity),
                ),
                title: Text(alert.title),
                subtitle: Text(alert.description),
                trailing: Text(
                  _formatTime(alert.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => _handleAlertTap(alert),
              ),
            )),
            if (teamProvider.alerts.length > 3)
              TextButton(
                onPressed: () => _showAllAlerts(),
                child: Text('View all ${teamProvider.alerts.length} alerts'),
              ),
          ],
        );
      },
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
            DashboardCard(
              title: 'Team Management',
              subtitle: 'Manage team members',
              leading: const Icon(Icons.people_alt, color: Colors.blue),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Team Management')),
                    body: const Center(child: Text('Team Management - Coming Soon')),
                  ),
                ),
              ),
            ),
            DashboardCard(
              title: 'Analytics',
              subtitle: 'Detailed insights',
              leading: const Icon(Icons.analytics, color: Colors.purple),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Team Analytics')),
                    body: const Center(child: Text('Team Analytics - Coming Soon')),
                  ),
                ),
              ),
            ),
            DashboardCard(
              title: 'Reports',
              subtitle: 'Generate reports',
              leading: const Icon(Icons.assessment, color: Colors.green),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Team Reports')),
                    body: const Center(child: Text('Team Reports - Coming Soon')),
                  ),
                ),
              ),
            ),
            DashboardCard(
              title: 'Settings',
              subtitle: 'Team preferences',
              leading: const Icon(Icons.settings, color: Colors.grey),
              onTap: () => Navigator.pushNamed(context, '/team-settings'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatHours(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Color _getProductivityColor(double score) {
    if (score >= 0.8) return Colors.green.withOpacity(0.1);
    if (score >= 0.6) return Colors.lightGreen.withOpacity(0.1);
    if (score >= 0.4) return Colors.orange.withOpacity(0.1);
    return Colors.red.withOpacity(0.1);
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red.withOpacity(0.1);
      case 'high':
        return Colors.orange.withOpacity(0.1);
      case 'medium':
        return Colors.yellow.withOpacity(0.1);
      default:
        return Colors.blue.withOpacity(0.1);
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'productivity':
        return Icons.trending_down;
      case 'attendance':
        return Icons.schedule;
      case 'security':
        return Icons.security;
      default:
        return Icons.info;
    }
  }

  Color _getAlertIconColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow[700]!;
      default:
        return Colors.blue;
    }
  }

  void _handleAlertTap(dynamic alert) {
    // Navigate to alert details or take action
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.title),
        content: Text(alert.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle alert action
            },
            child: const Text('Take Action'),
          ),
        ],
      ),
    );
  }

  void _showAllAlerts() {
    Navigator.pushNamed(context, '/alerts');
  }
}