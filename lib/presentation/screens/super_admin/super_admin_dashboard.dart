import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../providers/super_admin_provider.dart';
import '../dashboard/role_based_dashboard.dart';
import 'organizations_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final superAdminProvider = context.read<SuperAdminProvider>();
    await Future.wait([
      superAdminProvider.loadOrganizations(),
      superAdminProvider.loadSystemAnalytics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'Super Admin Dashboard',
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
              _buildRevenueMetrics(),
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
        
        return DashboardCard(
          title: 'Super Admin Dashboard',
          subtitle: 'System-wide administration and monitoring',
          leading: const Icon(
            Icons.admin_panel_settings,
            size: 32,
            color: Colors.red,
          ),
          color: Colors.red.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Super Admin Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back, ${user?.firstName ?? 'Super Admin'}! You have complete system access.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SUPER ADMIN ACCESS - FULL SYSTEM CONTROL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemOverview() {
    return Consumer<SuperAdminProvider>(
      builder: (context, provider, child) {
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
                  title: 'Organizations',
                  value: '${provider.totalOrganizations}',
                  subtitle: 'Total organizations',
                  icon: Icons.business,
                  color: Colors.blue.withOpacity(0.1),
                ),
                MetricCard(
                  title: 'Total Users',
                  value: '${provider.totalUsers}',
                  subtitle: 'Across all orgs',
                  icon: Icons.people,
                  color: Colors.green.withOpacity(0.1),
                ),
                MetricCard(
                  title: 'Companies',
                  value: '${provider.totalCompanies}',
                  subtitle: 'Total companies',
                  icon: Icons.corporate_fare,
                  color: Colors.purple.withOpacity(0.1),
                ),
                MetricCard(
                  title: 'Departments',
                  value: '${provider.totalDepartments}',
                  subtitle: 'Total departments',
                  icon: Icons.account_tree,
                  color: Colors.orange.withOpacity(0.1),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRevenueMetrics() {
    return Consumer<SuperAdminProvider>(
      builder: (context, provider, child) {
        return DashboardCard(
          title: 'Revenue Metrics',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revenue Metrics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildRevenueItem(
                      'MRR',
                      '\$${(provider.mrr / 1000).toStringAsFixed(0)}K',
                      'Monthly Recurring',
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildRevenueItem(
                      'ARR',
                      '\$${(provider.arr / 1000).toStringAsFixed(0)}K',
                      'Annual Recurring',
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildRevenueItem(
                      'Growth',
                      '${provider.growth.toStringAsFixed(1)}%',
                      'Month over month',
                      Colors.purple,
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

  Widget _buildRevenueItem(String title, String value, String subtitle, Color color) {
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

  Widget _buildSystemHealth() {
    return Consumer<SuperAdminProvider>(
      builder: (context, provider, child) {
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
              _buildHealthMetric('CPU Usage', provider.cpuUsage, 80),
              _buildHealthMetric('Memory Usage', provider.memoryUsage, 85),
              _buildHealthMetric('Disk Usage', provider.diskUsage, 90),
              const SizedBox(height: 12),
              Text('System Uptime: ${provider.uptime}'),
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
              title: 'Organizations',
              subtitle: 'Manage organizations',
              leading: const Icon(Icons.business, color: Colors.blue),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrganizationsScreen(),
                ),
              ),
            ),
            DashboardCard(
              title: 'System Analytics',
              subtitle: 'View system metrics',
              leading: const Icon(Icons.analytics, color: Colors.purple),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('System Analytics - Coming Soon')),
                );
              },
            ),
            DashboardCard(
              title: 'Admin Users',
              subtitle: 'Manage admins',
              leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin Users - Coming Soon')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
