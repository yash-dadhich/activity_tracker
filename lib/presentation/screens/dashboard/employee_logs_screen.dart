import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/user.dart';

class EmployeeLogsScreen extends StatefulWidget {
  final User employee;

  const EmployeeLogsScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeLogsScreen> createState() => _EmployeeLogsScreenState();
}

class _EmployeeLogsScreenState extends State<EmployeeLogsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> _screenshots = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEmployeeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployeeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = context.read<ApiClient>();
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Load detailed activities
      final activitiesResponse = await apiClient.get('/activities/detailed', queryParameters: {
        'userId': widget.employee.id,
        'startDate': startOfDay.toIso8601String(),
        'endDate': today.toIso8601String(),
      });

      if (activitiesResponse.data['success'] == true) {
        _activities = List<Map<String, dynamic>>.from(
          activitiesResponse.data['data']['activities']
        );
      }

      // Load screenshots
      final screenshotsResponse = await apiClient.get('/screenshots', queryParameters: {
        'userId': widget.employee.id,
        'startDate': startOfDay.toIso8601String(),
        'endDate': today.toIso8601String(),
      });

      if (screenshotsResponse.data['success'] == true) {
        _screenshots = List<Map<String, dynamic>>.from(
          screenshotsResponse.data['data']['screenshots']
        );
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading employee data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.employee.firstName} ${widget.employee.lastName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timeline), text: 'Activities'),
            Tab(icon: Icon(Icons.photo_camera), text: 'Screenshots'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployeeData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEmployeeData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActivitiesTab(),
                    _buildScreenshotsTab(),
                  ],
                ),
    );
  }

  Widget _buildActivitiesTab() {
    if (_activities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No activities found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Activities will appear here when the employee is active',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployeeData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return _buildActivityCard(activity);
        },
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final startTime = DateTime.parse(activity['startTime']);
    final endTime = activity['endTime'] != null 
        ? DateTime.parse(activity['endTime']) 
        : DateTime.now();
    final duration = endTime.difference(startTime);

    final category = activity['category'] ?? 'neutral';
    final productivityScore = (activity['productivityScore'] ?? 0.0) as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getCategoryIcon(category),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['title'] ?? 'Unknown Activity',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        activity['applicationName'] ?? 'Unknown App',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(productivityScore * 100).toInt()}%',
                    style: TextStyle(
                      color: _getCategoryColor(category),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activity['windowTitle'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.window, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity['windowTitle'],
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(duration),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (activity['keystrokes'] != null) ...[
                  Icon(Icons.keyboard, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${activity['keystrokes']} keys',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],
                if (activity['mouseClicks'] != null) ...[
                  Icon(Icons.mouse, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${activity['mouseClicks']} clicks',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],
                if (activity['screenshots'] != null && 
                    (activity['screenshots'] as List).isNotEmpty) ...[
                  Icon(Icons.photo_camera, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${(activity['screenshots'] as List).length} screenshots',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            if (activity['metadata'] != null && 
                (activity['metadata'] as Map).isNotEmpty)
              ExpansionTile(
                title: const Text('Details'),
                tilePadding: EdgeInsets.zero,
                children: [
                  _buildMetadataView(activity['metadata']),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataView(Map<String, dynamic> metadata) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: metadata.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    '${entry.key}:',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScreenshotsTab() {
    if (_screenshots.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No screenshots found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Screenshots will appear here when captured',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployeeData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: _screenshots.length,
        itemBuilder: (context, index) {
          final screenshot = _screenshots[index];
          return _buildScreenshotCard(screenshot);
        },
      ),
    );
  }

  Widget _buildScreenshotCard(Map<String, dynamic> screenshot) {
    final timestamp = DateTime.parse(screenshot['timestamp']);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  screenshot['applicationName'] ?? 'Unknown App',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'productive':
        return const Icon(Icons.trending_up, color: Colors.green, size: 20);
      case 'neutral':
        return const Icon(Icons.remove, color: Colors.orange, size: 20);
      case 'distracting':
        return const Icon(Icons.trending_down, color: Colors.red, size: 20);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey, size: 20);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'productive':
        return Colors.green;
      case 'neutral':
        return Colors.orange;
      case 'distracting':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}