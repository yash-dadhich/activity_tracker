import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/organization_provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../domain/entities/department.dart';

class CreateDepartmentScreen extends StatefulWidget {
  final Department? department;

  const CreateDepartmentScreen({super.key, this.department});

  @override
  State<CreateDepartmentScreen> createState() => _CreateDepartmentScreenState();
}

class _CreateDepartmentScreenState extends State<CreateDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costCenterController = TextEditingController();
  final _budgetController = TextEditingController();

  String? _selectedCompanyId;
  String? _selectedManagerId;
  bool _isLoading = false;
  bool get _isEditing => widget.department != null;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    if (_isEditing) {
      _populateFields();
    }
  }

  Future<void> _loadCompanies() async {
    final authManager = context.read<AuthManager>();
    final organizationId = authManager.currentUser?.organizationId;
    
    if (organizationId != null) {
      await context.read<OrganizationProvider>().loadCompanies(
        organizationId: organizationId,
      );
    }
  }

  void _populateFields() {
    final dept = widget.department!;
    _nameController.text = dept.name;
    _descriptionController.text = dept.description ?? '';
    _costCenterController.text = dept.costCenter ?? '';
    _budgetController.text = dept.budget?.toString() ?? '';
    _selectedCompanyId = dept.companyId;
    _selectedManagerId = dept.managerId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costCenterController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a company')),
      );
      return;
    }

    final authManager = context.read<AuthManager>();
    final organizationId = authManager.currentUser?.organizationId;

    if (organizationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organization ID not found')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<OrganizationProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateDepartment(
        widget.department!.id,
        {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          'companyId': _selectedCompanyId,
          'managerId': _selectedManagerId,
          'costCenter': _costCenterController.text.trim().isEmpty 
              ? null 
              : _costCenterController.text.trim(),
          'budget': _budgetController.text.trim().isEmpty 
              ? null 
              : double.tryParse(_budgetController.text.trim()),
        },
      );
    } else {
      success = await provider.createDepartment(
        companyId: _selectedCompanyId!,
        organizationId: organizationId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        managerId: _selectedManagerId,
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Department updated successfully' : 'Department created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to ${_isEditing ? 'update' : 'create'} department'),
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
        title: Text(_isEditing ? 'Edit Department' : 'Create Department'),
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
            Consumer<OrganizationProvider>(
              builder: (context, provider, child) {
                if (provider.companies.isEmpty) {
                  return Card(
                    color: Colors.orange.withOpacity(0.1),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('No companies available. Please create a company first.'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedCompanyId,
                  decoration: const InputDecoration(
                    labelText: 'Company *',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.companies.map((company) {
                    return DropdownMenuItem(
                      value: company.id,
                      child: Text(company.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCompanyId = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a company';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Department Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter department name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedManagerId,
              decoration: const InputDecoration(
                labelText: 'Manager',
                border: OutlineInputBorder(),
                hintText: 'Select a manager (optional)',
              ),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('No manager assigned'),
                ),
                // TODO: Load actual managers from API
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
              'Budget & Cost Center',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costCenterController,
              decoration: const InputDecoration(
                labelText: 'Cost Center',
                border: OutlineInputBorder(),
                hintText: 'e.g., CC-1001',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Annual Budget',
                border: OutlineInputBorder(),
                hintText: 'e.g., 500000',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                }
                return null;
              },
            ),
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
                  : Text(_isEditing ? 'Update Department' : 'Create Department'),
            ),
          ],
        ),
      ),
    );
  }
}
