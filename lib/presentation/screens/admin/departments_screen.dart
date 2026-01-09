import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/organization_provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/entities/company.dart';
import 'create_department_screen.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  String _searchQuery = '';
  String? _selectedCompanyId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authManager = context.read<AuthManager>();
    final organizationId = authManager.currentUser?.organizationId;
    
    if (organizationId != null) {
      final provider = context.read<OrganizationProvider>();
      await Future.wait([
        provider.loadCompanies(organizationId: organizationId),
        provider.loadDepartments(organizationId: organizationId),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateDepartmentScreen(),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search departments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
                const SizedBox(height: 12),
                Consumer<OrganizationProvider>(
                  builder: (context, provider, child) {
                    if (provider.companies.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedCompanyId,
                      decoration: InputDecoration(
                        labelText: 'Filter by Company',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Companies'),
                        ),
                        ...provider.companies.map((company) {
                          return DropdownMenuItem(
                            value: company.id,
                            child: Text(company.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCompanyId = value);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<OrganizationProvider>(
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

                var departments = provider.departments.where((dept) {
                  if (_selectedCompanyId != null && dept.companyId != _selectedCompanyId) {
                    return false;
                  }
                  if (_searchQuery.isEmpty) return true;
                  return dept.name.toLowerCase().contains(_searchQuery) ||
                      (dept.description?.toLowerCase().contains(_searchQuery) ?? false);
                }).toList();

                if (departments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_tree, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(_searchQuery.isEmpty ? 'No departments yet' : 'No departments found'),
                        const SizedBox(height: 16),
                        if (_searchQuery.isEmpty && provider.companies.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateDepartmentScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadData();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Department'),
                          ),
                        if (provider.companies.isEmpty)
                          const Text('Please create a company first'),
                      ],
                    ),
                  );
                }

                // Group departments by company
                final departmentsByCompany = <String, List<Department>>{};
                for (final dept in departments) {
                  departmentsByCompany.putIfAbsent(dept.companyId, () => []).add(dept);
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: departmentsByCompany.length,
                    itemBuilder: (context, index) {
                      final companyId = departmentsByCompany.keys.elementAt(index);
                      final depts = departmentsByCompany[companyId]!;
                      final company = provider.companies.firstWhere(
                        (c) => c.id == companyId,
                        orElse: () => Company(
                          id: companyId,
                          organizationId: '',
                          name: 'Unknown Company',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          isActive: true,
                        ),
                      );

                      return _buildCompanySection(company, depts);
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

  Widget _buildCompanySection(Company company, List<Department> departments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.corporate_fare, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                company.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${departments.length} dept${departments.length != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        ...departments.map((dept) => _buildDepartmentCard(dept)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDepartmentCard(Department department) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_tree, color: Colors.purple, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (department.description != null)
                        Text(
                          department.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
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
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editDepartment(department);
                    } else if (value == 'delete') {
                      _confirmDelete(department);
                    }
                  },
                ),
              ],
            ),
            if (department.managerId != null || department.budget != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (department.managerId != null)
                    _buildChip('Manager: ${department.managerId}', Icons.person),
                  if (department.budget != null)
                    _buildChip('Budget: \$${department.budget!.toStringAsFixed(0)}', Icons.attach_money),
                  if (department.costCenter != null)
                    _buildChip('CC: ${department.costCenter}', Icons.account_balance),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _editDepartment(Department department) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDepartmentScreen(department: department),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _confirmDelete(Department department) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Are you sure you want to delete "${department.name}"? This will affect all users in this department.'),
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
      final provider = context.read<OrganizationProvider>();
      final success = await provider.deleteDepartment(department.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Department deleted' : 'Failed to delete department'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
