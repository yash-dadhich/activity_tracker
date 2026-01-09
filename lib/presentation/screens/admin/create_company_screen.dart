import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/organization_provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../domain/entities/company.dart';

class CreateCompanyScreen extends StatefulWidget {
  final Company? company;

  const CreateCompanyScreen({super.key, this.company});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _industryController = TextEditingController();

  String _selectedSize = 'medium';
  bool _isLoading = false;
  bool get _isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final company = widget.company!;
    _nameController.text = company.name;
    _descriptionController.text = company.description ?? '';
    _locationController.text = company.location ?? '';
    _addressController.text = company.address ?? '';
    _cityController.text = company.city ?? '';
    _stateController.text = company.state ?? '';
    _countryController.text = company.country ?? '';
    _postalCodeController.text = company.postalCode ?? '';
    _phoneController.text = company.phone ?? '';
    _emailController.text = company.email ?? '';
    _industryController.text = company.industry ?? '';
    _selectedSize = company.size ?? 'medium';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _industryController.dispose();
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

    final provider = context.read<OrganizationProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateCompany(
        widget.company!.id,
        {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          'location': _locationController.text.trim().isEmpty 
              ? null 
              : _locationController.text.trim(),
          'address': _addressController.text.trim().isEmpty 
              ? null 
              : _addressController.text.trim(),
          'city': _cityController.text.trim().isEmpty 
              ? null 
              : _cityController.text.trim(),
          'state': _stateController.text.trim().isEmpty 
              ? null 
              : _stateController.text.trim(),
          'country': _countryController.text.trim().isEmpty 
              ? null 
              : _countryController.text.trim(),
          'postalCode': _postalCodeController.text.trim().isEmpty 
              ? null 
              : _postalCodeController.text.trim(),
          'phone': _phoneController.text.trim().isEmpty 
              ? null 
              : _phoneController.text.trim(),
          'email': _emailController.text.trim().isEmpty 
              ? null 
              : _emailController.text.trim(),
          'industry': _industryController.text.trim().isEmpty 
              ? null 
              : _industryController.text.trim(),
          'size': _selectedSize,
        },
      );
    } else {
      success = await provider.createCompany(
        organizationId: organizationId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        industry: _industryController.text.trim().isEmpty 
            ? null 
            : _industryController.text.trim(),
        size: _selectedSize,
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Company updated successfully' : 'Company created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to ${_isEditing ? 'update' : 'create'} company'),
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
        title: Text(_isEditing ? 'Edit Company' : 'Create Company'),
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter company name';
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _industryController,
              decoration: const InputDecoration(
                labelText: 'Industry',
                border: OutlineInputBorder(),
                hintText: 'e.g., Technology, Healthcare',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSize,
              decoration: const InputDecoration(
                labelText: 'Company Size',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'small', child: Text('Small (1-50 employees)')),
                DropdownMenuItem(value: 'medium', child: Text('Medium (51-500 employees)')),
                DropdownMenuItem(value: 'large', child: Text('Large (501-5000 employees)')),
                DropdownMenuItem(value: 'enterprise', child: Text('Enterprise (5000+ employees)')),
              ],
              onChanged: (value) {
                setState(() => _selectedSize = value!);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                hintText: 'e.g., San Francisco, CA',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State/Province',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                hintText: '+1 (555) 123-4567',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                hintText: 'contact@company.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
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
                  : Text(_isEditing ? 'Update Company' : 'Create Company'),
            ),
          ],
        ),
      ),
    );
  }
}
