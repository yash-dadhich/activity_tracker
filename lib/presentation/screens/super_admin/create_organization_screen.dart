import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/super_admin_provider.dart';

class CreateOrganizationScreen extends StatefulWidget {
  const CreateOrganizationScreen({super.key});

  @override
  State<CreateOrganizationScreen> createState() => _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState extends State<CreateOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();
  final _maxUsersController = TextEditingController(text: '100');
  final _maxCompaniesController = TextEditingController(text: '5');

  String _selectedSize = 'medium';
  String _selectedPlan = 'professional';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _maxUsersController.dispose();
    _maxCompaniesController.dispose();
    super.dispose();
  }

  Future<void> _createOrganization() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<SuperAdminProvider>();
    final success = await provider.createOrganization(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      website: _websiteController.text.trim().isEmpty 
          ? null 
          : _websiteController.text.trim(),
      industry: _industryController.text.trim().isEmpty 
          ? null 
          : _industryController.text.trim(),
      size: _selectedSize,
      subscriptionPlan: _selectedPlan,
      maxUsers: int.parse(_maxUsersController.text),
      maxCompanies: int.parse(_maxCompaniesController.text),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organization created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to create organization'),
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
        title: const Text('Create Organization'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Organization Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter organization name';
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
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
                hintText: 'https://example.com',
              ),
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
                labelText: 'Organization Size *',
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPlan,
              decoration: const InputDecoration(
                labelText: 'Subscription Plan *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'free', child: Text('Free')),
                DropdownMenuItem(value: 'basic', child: Text('Basic')),
                DropdownMenuItem(value: 'professional', child: Text('Professional')),
                DropdownMenuItem(value: 'enterprise', child: Text('Enterprise')),
              ],
              onChanged: (value) {
                setState(() => _selectedPlan = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxUsersController,
              decoration: const InputDecoration(
                labelText: 'Maximum Users *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter maximum users';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxCompaniesController,
              decoration: const InputDecoration(
                labelText: 'Maximum Companies *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter maximum companies';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createOrganization,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Organization'),
            ),
          ],
        ),
      ),
    );
  }
}
