import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_management_provider.dart';
import '../../../providers/organization_provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../domain/entities/user.dart';

class AddTeamMemberScreen extends StatefulWidget {
  final User? user;

  const AddTeamMemberScreen({super.key, this.user});

  @override
  State<AddTeamMemberScreen> createState() => _AddTeamMemberScreenState();
}

class _AddTeamMemberScreenState extends State<AddTeamMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _jobTitleController = TextEditingController();

  String _selectedRole = 'employee';
  String? _selectedCompanyId;
  String? _selectedDepartmentId;
  String? _selectedManagerId;
  String _selectedEmploymentType = 'full_time';
  bool _isLoading = false;
  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (_isEditing) {
      _populateFields();
    }
  }

  Future<void> _loadData() async {
    final authManager = context.read<AuthManager>();
    final organizationId = authManager.currentUser?.organizationId;
    
    if (organizationId != null) {
      final orgProvider = context.read<OrganizationProvider>();
      await Future.wait([
        orgProvider.loadCompanies(organizationId: organizationId),
        orgProvider.loadDepartments(organizationId: organizationId),
      ]);
    }
  }

  void _populateFields() {
    final user = widget.user!;
    _emailController.text = user.email;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _selectedRole = user.role.toString().split('.').last;
    _selectedCompanyId = user.companyId;
    _selectedDepartmentId = user.departmentId;
    _selectedManagerId = user.managerId;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authManager = context.read<AuthManager>();
    final organizationId = authManager.currentUser?.organizationId;

    if (organizationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organization ID not found')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<UserManagementProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateUser(
        widget.user!.id,
        {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'role': _selectedRole,
          'companyId': _selectedCompanyId,
          'departmentId': _selectedDepartmentId,
          'managerId': _selectedManagerId,
          'jobTitle': _jobTitleController.text.trim().isEmpty 
              ? null 
              : _jobTitleController.text.trim(),
          'employmentType': _selectedEmploymentType,
        },
      );
    } else {
      success = await provider.createUser(
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _selectedRole,
        organizationId: organizationId,
        companyId: _selectedCompanyId,
        departmentId: _selectedDepartmentId,
        managerId: _selectedManagerId,
        jobTitle: _jobTitleController.text.trim().isEmpty 
            ? null 
            : _jobTitleController.text.trim(),
        employmentType: _selectedEmploymentType,
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'User updated successfully' : 'User created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to ${_isEditing ? 'update' : 'create'} user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Team Member' : 'Add Team Member'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                hintText: 'user@company.com',
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isEditing, // Can't change email
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jobTitleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
                hintText: 'e.g., Software Engineer',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Role & Access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role *',
                border: OutlineInputBorder(),
              ),
              items: UserRole.values.map((role) {
                final roleName = role.toString().split('.').last;
                return DropdownMenuItem(
                  value: roleName,
                  child: Text(roleName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedRole = value!);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Organization Structure',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<OrganizationProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedCompanyId,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No company assigned'),
                    ),
                    ...provider.companies.map((company) {
                      return DropdownMenuItem(
                        value: company.id,
                        child: Text(company.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCompanyId = value;
                      _selectedDepartmentId = null; // Reset department
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<OrganizationProvider>(
              builder: (context, provider, child) {
                final availableDepartments = _selectedCompanyId != null
                    ? provider.departments.where((d) => d.companyId == _selectedCompanyId).toList()
                    : provider.departments;

                return DropdownButtonFormField<String>(
                  value: _selectedDepartmentId,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No department assigned'),
                    ),
                    ...availableDepartments.map((dept) {
                      return DropdownMenuItem(
                        value: dept.id,
                        child: Text(dept.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedDepartmentId = value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedManagerId,
              decoration: const InputDecoration(
                labelText: 'Manager',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('No manager assigned'),
                ),
                // TODO: Load actual managers
                DropdownMenuItem(
                  value: 'mgr-001',
                  child: Text('Jane Manager'),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedManagerId = value);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Employment Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEmploymentType,
              decoration: const InputDecoration(
                labelText: 'Employment Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'full_time', child: Text('Full Time')),
                DropdownMenuItem(value: 'part_time', child: Text('Part Time')),
                DropdownMenuItem(value: 'contract', child: Text('Contract')),
                DropdownMenuItem(value: 'intern', child: Text('Intern')),
              ],
              onChanged: (value) {
                setState(() => _selectedEmploymentType = value!);
              },
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 24),
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
                        'A temporary password will be generated and sent to the user\'s email.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Update Team Member' : 'Add Team Member'),
            ),
          ],
        ),
      ),
    );
  }
}
