import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_manager.dart';
import '../../../domain/entities/user.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _allowScreenshots = false;
  bool _allowLocationTracking = false;
  bool _allowAppTracking = false;
  bool _allowWebsiteTracking = false;
  bool _allowIdleTracking = false;
  bool _shareDataWithManager = false;
  bool _shareDataWithHR = false;
  bool _consentGiven = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Consent'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: Colors.blue, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Privacy & Data Collection Consent',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Before you can use the Enterprise Productivity Monitor, we need your explicit consent for data collection activities. You have full control over what data is collected.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Data Collection Options
            Text(
              'Data Collection Permissions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildConsentItem(
              title: 'Screenshot Capture',
              description: 'Periodic screenshots of your screen for productivity analysis',
              value: _allowScreenshots,
              onChanged: (value) => setState(() => _allowScreenshots = value),
              icon: Icons.camera_alt,
              color: Colors.purple,
            ),

            _buildConsentItem(
              title: 'Application Tracking',
              description: 'Monitor which applications you use and for how long',
              value: _allowAppTracking,
              onChanged: (value) => setState(() => _allowAppTracking = value),
              icon: Icons.apps,
              color: Colors.blue,
            ),

            _buildConsentItem(
              title: 'Website Tracking',
              description: 'Track websites visited during work hours',
              value: _allowWebsiteTracking,
              onChanged: (value) => setState(() => _allowWebsiteTracking = value),
              icon: Icons.web,
              color: Colors.green,
            ),

            _buildConsentItem(
              title: 'Idle Time Detection',
              description: 'Detect when you are away from your computer',
              value: _allowIdleTracking,
              onChanged: (value) => setState(() => _allowIdleTracking = value),
              icon: Icons.schedule,
              color: Colors.orange,
            ),

            _buildConsentItem(
              title: 'Location Tracking',
              description: 'Track your location during work hours (if supported)',
              value: _allowLocationTracking,
              onChanged: (value) => setState(() => _allowLocationTracking = value),
              icon: Icons.location_on,
              color: Colors.red,
            ),

            const SizedBox(height: 24),

            // Data Sharing Options
            Text(
              'Data Sharing Permissions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildConsentItem(
              title: 'Share with Manager',
              description: 'Allow your direct manager to view your productivity data',
              value: _shareDataWithManager,
              onChanged: (value) => setState(() => _shareDataWithManager = value),
              icon: Icons.supervisor_account,
              color: Colors.indigo,
            ),

            _buildConsentItem(
              title: 'Share with HR',
              description: 'Allow HR department to access your data for compliance',
              value: _shareDataWithHR,
              onChanged: (value) => setState(() => _shareDataWithHR = value),
              icon: Icons.business_center,
              color: Colors.teal,
            ),

            const SizedBox(height: 24),

            // Privacy Information
            Card(
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Your Privacy Rights',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• You can change these settings at any time\n'
                      '• All data is encrypted and stored securely\n'
                      '• You have the right to access, modify, or delete your data\n'
                      '• Data is only used for productivity analysis\n'
                      '• We comply with GDPR and other privacy regulations',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Final Consent
            CheckboxListTile(
              title: Text(
                'I understand and consent to data collection',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'I have read and understood the privacy policy and consent to the collection and processing of my data as specified above.',
              ),
              value: _consentGiven,
              onChanged: (value) => setState(() => _consentGiven = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Logout and return to login
                      context.read<AuthManager>().logout();
                    },
                    child: const Text('Decline & Logout'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _consentGiven ? _saveConsent : null,
                    child: const Text('Accept & Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        subtitle: Text(description),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _saveConsent() async {
    final authManager = context.read<AuthManager>();
    
    final privacySettings = PrivacySettings(
      consentGiven: true,
      consentDate: DateTime.now(),
      allowScreenshots: _allowScreenshots,
      allowLocationTracking: _allowLocationTracking,
      allowAppTracking: _allowAppTracking,
      allowWebsiteTracking: _allowWebsiteTracking,
      allowIdleTracking: _allowIdleTracking,
      shareDataWithManager: _shareDataWithManager,
      shareDataWithHR: _shareDataWithHR,
      dataProcessingPurposes: [
        'productivity_monitoring',
        'performance_analysis',
        'compliance_reporting',
      ],
    );

    await authManager.updatePrivacySettings(privacySettings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Privacy settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}