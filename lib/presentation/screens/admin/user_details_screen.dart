import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';
import 'add_team_member_screen.dart';

class UserDetailsScreen extends StatelessWidget {
  final User user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTeamMemberScreen(user: user),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildInfoSection(context),
            const SizedBox(height: 24),
            _buildOrganizationSection(context),
            const SizedBox(height: 24),
            _buildActivitySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final roleColor = _getRoleColor(user.role);
    final statusColor = user.status == UserStatus.active ? Colors.green : Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: roleColor.withOpacity(0.2),
              child: Text(
                '${user.firstName[0]}${user.lastName[0]}',
                style: TextStyle(
                  fontSize: 32,
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Chip(
                  avatar: Icon(Icons.badge, size: 16, color: roleColor),
                  label: Text(
                    user.role.toString().split('.').last.toUpperCase(),
                    style: TextStyle(color: roleColor),
                  ),
                  backgroundColor: roleColor.withOpacity(0.1),
                ),
                Chip(
                  avatar: Icon(Icons.circle, size: 16, color: statusColor),
                  label: Text(
                    user.status.toString().split('.').last,
                    style: TextStyle(color: statusColor),
                  ),
                  backgroundColor: statusColor.withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.fingerprint, 'User ID', user.id),
            _buildInfoRow(Icons.email, 'Email', user.email),
            _buildInfoRow(
              Icons.calendar_today,
              'Created',
              _formatDate(user.createdAt),
            ),
            _buildInfoRow(
              Icons.update,
              'Last Updated',
              _formatDate(user.updatedAt),
            ),
            if (user.lastLoginAt != null)
              _buildInfoRow(
                Icons.login,
                'Last Login',
                _formatDate(user.lastLoginAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organization Structure',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (user.organizationId != null)
              _buildInfoRow(Icons.business, 'Organization', user.organizationId!),
            if (user.companyId != null)
              _buildInfoRow(Icons.corporate_fare, 'Company', user.companyId!),
            if (user.departmentId != null)
              _buildInfoRow(Icons.account_tree, 'Department', user.departmentId!),
            if (user.managerId != null)
              _buildInfoRow(Icons.person, 'Manager', user.managerId!),
            if (user.organizationId == null && 
                user.companyId == null && 
                user.departmentId == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No organizational assignments',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full activity logs
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Activity logs - Coming Soon')),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityMetric('Total Active Time', '0h 0m', Icons.timer),
            _buildActivityMetric('Productivity Score', '0%', Icons.trending_up),
            _buildActivityMetric('Tasks Completed', '0', Icons.check_circle),
            _buildActivityMetric('Last Activity', 'No data', Icons.access_time),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Activity tracking will be available once the user starts working.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityMetric(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(label),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.red;
      case UserRole.admin:
        return Colors.blue;
      case UserRole.manager:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
