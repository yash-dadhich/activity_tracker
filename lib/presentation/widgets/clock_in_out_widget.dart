import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/time_tracking_provider.dart';

class ClockInOutWidget extends StatefulWidget {
  const ClockInOutWidget({Key? key}) : super(key: key);

  @override
  State<ClockInOutWidget> createState() => _ClockInOutWidgetState();
}

class _ClockInOutWidgetState extends State<ClockInOutWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update duration every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });

    // Load current session on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimeTrackingProvider>().loadCurrentSession();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleClockIn() async {
    final provider = context.read<TimeTrackingProvider>();
    final success = await provider.clockIn();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Clocked in successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${provider.error ?? "Failed to clock in"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleClockOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clock Out'),
        content: const Text('Are you sure you want to clock out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clock Out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final provider = context.read<TimeTrackingProvider>();
    final success = await provider.clockOut();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Clocked out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${provider.error ?? "Failed to clock out"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeTrackingProvider>(
      builder: (context, provider, child) {
        final isClockedIn = provider.isClockedIn;
        final currentSession = provider.currentSession;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 32,
                      color: isClockedIn ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Work Session',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (provider.isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (isClockedIn && currentSession != null) ...[
                  _buildStatusRow(
                    'Status',
                    'Clocked In',
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    'Started',
                    _formatTime(currentSession.clockInTime),
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    'Duration',
                    _formatDuration(provider.currentSessionDuration),
                    Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _handleClockOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Clock Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ] else ...[
                  _buildStatusRow(
                    'Status',
                    'Not Clocked In',
                    Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Click the button below to start your work session',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _handleClockIn,
                      icon: const Icon(Icons.login),
                      label: const Text('Clock In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
