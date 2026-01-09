import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_management_provider.dart';
import '../../../providers/organization_provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../domain/entities/user.dart';
import 'add_team_member_screen.dart';
import 'user_details_screen.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authManager = context.read<AuthManager>();
    final organizationId = authManager.currentUser?.organizationId;
    
    if (organizationId != null) {
      final userProvider = context.read<UserManagementProvider>();
      final orgProvider = context.read<OrganizationProvider>();
      
      await Future.wait([
        userProvider.loadUsers(organizationId: organizationId),
        orgProvider.loadCompanies(organizationId: organizationId),
        orgProvider.loadDepartments(organizationId: organizationId),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTeamMemberScreen(),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Consumer<UserManagementProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final users = provider.filteredUsers;

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(provider.searchQuery.isNotEmpty || 
                             provider.roleFilter != null ||
                             provider.departmentFilter != null
                            ? 'No users found'
                            : 'No team members yet'),
                        const SizedBox(height: 16),
                        if (provider.searchQuery.isEmpty && 
                            provider.roleFilter == null &&
                            provider.departmentFilter == null)
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddTeamMemberScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadData();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Team Member'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserCard(user);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        final hasFilters = provider.roleFilter != null ||
            provider.departmentFilter != null ||
            provider.statusFilter != null;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => provider.setSearchQuery(''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => provider.setSearchQuery(value),
              ),
              if (hasFilters) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (provider.roleFilter != null)
                      Chip(
                        label: Text('Role: ${provider.roleFilter}'),
                        onDeleted: () => provider.setRoleFilter(null),
                      ),
                    if (provider.departmentFilter != null)
                      Chip(
                        label: const Text('Department filtered'),
                        onDeleted: () => provider.setDepartmentFilter(null),
                      ),
                    if (provider.statusFilter != null)
                      Chip(
                        label: Text('Status: ${provider.statusFilter}'),
                        onDeleted: () => provider.setStatusFilter(null),
                      ),
                    TextButton.icon(
                      onPressed: () => provider.clearFilters(),
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear all'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(User user) {
    final roleColor = _getRoleColor(user.role);
    final statusColor = user.status == UserStatus.active ? Colors.green : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewUserDetails(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: roleColor.withOpacity(0.2),
                    child: Text(
                      '${user.firstName[0]}${user.lastName[0]}',
                      style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'change_role',
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 20),
                            SizedBox(width: 8),
                            Text('Change Role'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle_status',
                        child: Row(
                          children: [
                            Icon(
                              user.status == UserStatus.active ? Icons.block : Icons.check_circle,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(user.status == UserStatus.active ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleMenuAction(value.toString(), user),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(
                    user.role.toString().split('.').last.toUpperCase(),
                    Icons.badge,
                    roleColor,
                  ),
                  _buildChip(
                    user.status.toString().split('.').last,
                    Icons.circle,
                    statusColor,
                  ),
                  if (user.departmentId != null)
                    _buildChip('Dept: ${user.departmentId}', Icons.account_tree, Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(label, style: TextStyle(fontSize: 11, color: color)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withOpacity(0.1),
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

  void _handleMenuAction(String action, User user) {
    switch (action) {
      case 'view':
        _viewUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'change_role':
        _changeUserRole(user);
        break;
      case 'toggle_status':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _confirmDelete(user);
        break;
    }
  }

  void _viewUserDetails(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(user: user),
      ),
    );
  }

  Future<void> _editUser(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTeamMemberScreen(user: user),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _changeUserRole(User user) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change role for ${user.fullName}'),
            const SizedBox(height: 16),
            ...UserRole.values.map((role) {
              final roleName = role.toString().split('.').last;
              return RadioListTile<String>(
                title: Text(roleName),
                value: roleName,
                groupValue: user.role.toString().split('.').last,
                onChanged: (value) => Navigator.pop(context, value),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newRole != null && mounted) {
      final provider = context.read<UserManagementProvider>();
      final success = await provider.updateUserRole(user.id, newRole);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Role updated successfully' : 'Failed to update role'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleUserStatus(User user) async {
    final activate = user.status != UserStatus.active;
    final provider = context.read<UserManagementProvider>();
    final success = await provider.toggleUserStatus(user.id, activate);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? 'User ${activate ? 'activated' : 'deactivated'} successfully'
              : 'Failed to update user status'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<UserManagementProvider>();
      final success = await provider.deleteUser(user.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'User deleted' : 'Failed to delete user'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(),
    );
  }
}

class _FilterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<UserManagementProvider, OrganizationProvider>(
      builder: (context, userProvider, orgProvider, child) {
        return AlertDialog(
          title: const Text('Filter Users'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Role', style: TextStyle(fontWeight: FontWeight.bold)),
                ...UserRole.values.map((role) {
                  final roleName = role.toString().split('.').last;
                  return RadioListTile<String>(
                    title: Text(roleName),
                    value: roleName,
                    groupValue: userProvider.roleFilter,
                    onChanged: (value) {
                      userProvider.setRoleFilter(value);
                      Navigator.pop(context);
                    },
                  );
                }),
                const Divider(),
                const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                ...UserStatus.values.map((status) {
                  final statusName = status.toString().split('.').last;
                  return RadioListTile<String>(
                    title: Text(statusName),
                    value: statusName,
                    groupValue: userProvider.statusFilter,
                    onChanged: (value) {
                      userProvider.setStatusFilter(value);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                userProvider.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Clear Filters'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
