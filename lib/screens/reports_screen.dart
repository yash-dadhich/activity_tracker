import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Reports'),
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          final report = provider.todayReport;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(report),
                const SizedBox(height: 16),
                _buildProductivityCard(report),
                const SizedBox(height: 16),
                _buildTopAppsCard(provider),
                const SizedBox(height: 16),
                _buildTimelineCard(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  Icons.access_time,
                  'Active Time',
                  report.formattedActiveTime,
                  Colors.green,
                ),
                _buildSummaryItem(
                  Icons.bedtime,
                  'Idle Time',
                  report.formattedIdleTime,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  Icons.keyboard,
                  'Keystrokes',
                  report.totalKeystrokes.toString(),
                  Colors.blue,
                ),
                _buildSummaryItem(
                  Icons.mouse,
                  'Clicks',
                  report.totalMouseClicks.toString(),
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildProductivityCard(report) {
    final percentage = report.productivityPercentage;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productivity Score',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 70 ? Colors.green : 
                percentage > 40 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}% Active',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppsCard(ActivityProvider provider) {
    final topApps = provider.topApps;
    
    if (topApps.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              Icon(Icons.apps, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No application data yet'),
              Text('Start monitoring to see app usage', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Applications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...topApps.take(5).map((app) => _buildAppUsageItem(app, provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppUsageItem(app, ActivityProvider provider) {
    final totalSeconds = provider.totalActiveSeconds + provider.totalIdleSeconds;
    final percentage = totalSeconds > 0 ? (app.totalSeconds / totalSeconds) * 100 : 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  app.applicationName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                app.formattedDuration,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}% of time',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                '${app.keystrokeCount} keys, ${app.mouseClickCount} clicks',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(ActivityProvider provider) {
    final logs = provider.activityLogs.take(20).toList();
    
    if (logs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              Icon(Icons.timeline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No activity timeline yet'),
            ],
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity Timeline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...logs.map((log) => _buildTimelineItem(log)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: log.isIdle ? Colors.grey : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.applicationName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  log.activeWindow,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
