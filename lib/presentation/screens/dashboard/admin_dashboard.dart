import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../providers/admin_provider.dart';
import 'role_based_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final adminProvider = context.read<AdminProvider>();
    await adminProvider.loadSystemOverview();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'System Administration',
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildSystemOverview(),
              const SizedBox(height: 24),
              _buildOrganizationMetrics(),
              const SizedBox(height: 24),
              _buildSecurityStatus(),
              const SizedBox(height: 24),
              _buildComplianceStatus(),
              const SizedBox(height: 24),
              _buildSystemHealth(),
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
        final isSuperAdmin = user?.role.toString().contains('superAdmin') ?? false;
        
        return DashboardCard(
          title: isSuperAdmin ? 'Super Admin Dashboard' : 'Admin Dashboard',
          subtitle: 'System administration and compliance management',
          leading: Icon(
            isSuperAdmin ? Icons.admin_panel_settings : Icons.security,
            size: 32,
            color: isSuperAdmin ? Colors.red : Colors.blue,
          ),
          color: isSuperAdmin 
            ? Colors.red.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSuperAdmin ? 'Super Admin Dashboard' : 'Admin Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back, ${user?.firstName ?? 'Admin'}! Monitor system health and manage organizational settings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              if (isSuperAdmin) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SUPER ADMIN ACCESS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemOverview() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                MetricCard(
                  title: 'Total Users',
                  value: '${adminProvider.totalUsers}',
                  subtitle: '${adminProvider.activeUsers} active',
                  icon: Icons.people,
                  color: Colors.blue.withOpacity(0.1),
                ),
                MetricCard(
                  title: 'Departments',
                  value: '${adminProvider.totalDepartments}',
                  subtitle: 'Across organization',
                  icon: Icons.business,
                  color: Colors.green.withOpacity(0.1),
                ),
                MetricCard(
                  title: 'Data Storage',
                  value: adminProvider.storageUsed,
                  subtitle: 'of ${adminProvider.storageLimit}',
                  icon: Icons.storage,
                  color: Colors.purple.withOpacity(0.1),
                ),
                MetricCard(
                  title: 'System Health',
                  value: '${adminProvider.systemHealthScore}%',
                  subtitle: adminProvider.systemStatus,
                  icon: Icons.health_and_safety,
                  color: _getHealthColor(adminProvider.systemHealthScore),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrganizationMetrics() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return DashboardCard(
          title: 'Organization Metrics',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Organization Metrics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Daily Active Users',
                      '${adminProvider.dailyActiveUsers}',
                      '${adminProvider.dauGrowth > 0 ? '+' : ''}${adminProvider.dauGrowth.toStringAsFixed(1)}%',
                      adminProvider.dauGrowth >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Avg Productivity',
                      '${(adminProvider.avgProductivity * 100).toInt()}%',
                      '${adminProvider.productivityTrend > 0 ? '+' : ''}${adminProvider.productivityTrend.toStringAsFixed(1)}%',
                      adminProvider.productivityTrend >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Data Processed',
                      adminProvider.dataProcessedToday,
                      'Today',
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'API Requests',
                      '${adminProvider.apiRequestsToday}',
                      '${adminProvider.apiGrowth > 0 ? '+' : ''}${adminProvider.apiGrowth.toStringAsFixed(1)}%',
                      adminProvider.apiGrowth >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
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
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return DashboardCard(
          title: 'Security Status',
          leading: Icon(
            Icons.security,
            color: adminProvider.securityScore >= 90 ? Colors.green : Colors.orange,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Security Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSecurityColor(adminProvider.securityScore),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${adminProvider.securityScore}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSecurityItem('Failed Login Attempts', '${adminProvider.failedLogins}', 
                adminProvider.failedLogins > 10 ? Colors.red : Colors.green),
              _buildSecurityItem('Active Sessions', '${adminProvider.activeSessions}', Colors.blue),
              _buildSecurityItem('Security Alerts', '${adminProvider.securityAlerts}', 
                adminProvider.securityAlerts > 0 ? Colors.red : Colors.green),
              _buildSecurityItem('Last Security Scan', adminProvider.lastSecurityScan, Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurityItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceStatus() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return DashboardCard(
          title: 'Compliance Status',
          leading: Icon(
            Icons.verified_user,
            color: adminProvider.complianceScore >= 95 ? Colors.green : Colors.orange,
          ),
          trailing: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Compliance Dashboard')),
                  body: const Center(child: Text('Compliance Dashboard - Coming Soon')),
                ),
              ),
            ),
            child: const Text('View Details'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compliance Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildComplianceItem('GDPR Compliance', adminProvider.gdprCompliance),
              _buildComplianceItem('SOC 2 Type II', adminProvider.soc2Compliance),
              _buildComplianceItem('ISO 27001', adminProvider.iso27001Compliance),
              _buildComplianceItem('Data Retention', adminProvider.dataRetentionCompliance),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: adminProvider.complianceScore / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  adminProvider.complianceScore >= 95 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Overall Compliance: ${adminProvider.complianceScore}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplianceItem(String standard, bool isCompliant) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(standard),
          Icon(
            isCompliant ? Icons.check_circle : Icons.warning,
            color: isCompliant ? Colors.green : Colors.orange,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealth() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return DashboardCard(
          title: 'System Health',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Health',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildHealthMetric('CPU Usage', adminProvider.cpuUsage, 80),
              _buildHealthMetric('Memory Usage', adminProvider.memoryUsage, 85),
              _buildHealthMetric('Disk Usage', adminProvider.diskUsage, 90),
              _buildHealthMetric('Network I/O', adminProvider.networkIO, 70),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Uptime: ${adminProvider.systemUptime}'),
                  Text('Last Restart: ${adminProvider.lastRestart}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthMetric(String label, double value, double threshold) {
    final isHealthy = value < threshold;
    final color = isHealthy ? Colors.green : Colors.red;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
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
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            DashboardCard(
              title: 'User Management',
              subtitle: 'Manage users & roles',
              leading: const Icon(Icons.people, color: Colors.blue),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('User Management')),
                    body: const Center(child: Text('User Management - Coming Soon')),
                  ),
                ),
              ),
            ),
            DashboardCard(
              title: 'System Settings',
              subtitle: 'Configure system',
              leading: const Icon(Icons.settings, color: Colors.grey),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('System Settings')),
                    body: const Center(child: Text('System Settings - Coming Soon')),
                  ),
                ),
              ),
            ),
            DashboardCard(
              title: 'Analytics',
              subtitle: 'Organization insights',
              leading: const Icon(Icons.analytics, color: Colors.purple),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Organization Analytics')),
                    body: const Center(child: Text('Organization Analytics - Coming Soon')),
                  ),
                ),
              ),
            ),
            DashboardCard(
              title: 'Compliance',
              subtitle: 'Audit & reports',
              leading: const Icon(Icons.verified_user, color: Colors.green),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Compliance Dashboard')),
                    body: const Center(child: Text('Compliance Dashboard - Coming Soon')),
                  ),
                ),
              ),
            ),
            DashboardCard(
              title: 'Security Center',
              subtitle: 'Security monitoring',
              leading: const Icon(Icons.security, color: Colors.red),
              onTap: () => Navigator.pushNamed(context, '/security-center'),
            ),
            DashboardCard(
              title: 'Backup & Recovery',
              subtitle: 'Data management',
              leading: const Icon(Icons.backup, color: Colors.orange),
              onTap: () => Navigator.pushNamed(context, '/backup-recovery'),
            ),
          ],
        ),
      ],
    );
  }

  Color _getHealthColor(int score) {
    if (score >= 90) return Colors.green.withOpacity(0.1);
    if (score >= 70) return Colors.orange.withOpacity(0.1);
    return Colors.red.withOpacity(0.1);
  }

  Color _getSecurityColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}