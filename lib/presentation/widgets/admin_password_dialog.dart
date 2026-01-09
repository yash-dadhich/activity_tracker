import 'package:flutter/material.dart';
import '../../services/admin_password_service.dart';

class AdminPasswordDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onSuccess;

  const AdminPasswordDialog({
    Key? key,
    this.title = 'Admin Password Required',
    this.message = 'Enter admin password to continue:',
    this.onSuccess,
  }) : super(key: key);

  @override
  State<AdminPasswordDialog> createState() => _AdminPasswordDialogState();

  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdminPasswordDialog(
        title: title ?? 'Admin Password Required',
        message: message ?? 'Enter admin password to continue:',
      ),
    );
    return result ?? false;
  }
}

class _AdminPasswordDialogState extends State<AdminPasswordDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isValidating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    // Simulate validation delay
    await Future.delayed(const Duration(milliseconds: 300));

    final isValid = AdminPasswordService.validatePassword(
      _passwordController.text,
    );

    if (isValid) {
      widget.onSuccess?.call();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
        _isValidating = false;
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock, color: Colors.orange),
          const SizedBox(width: 12),
          Text(widget.title),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofocus: true,
              enabled: !_isValidating,
              decoration: InputDecoration(
                labelText: 'Admin Password',
                hintText: 'Enter password',
                prefixIcon: const Icon(Icons.password),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
              onFieldSubmitted: (_) => _validatePassword(),
            ),
            if (_isValidating) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isValidating
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isValidating ? null : _validatePassword,
          child: _isValidating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }
}
