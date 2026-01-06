import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../domain/entities/user.dart';
import '../domain/entities/activity_session.dart';
import '../domain/entities/productivity_score.dart';

class TeamAlert {
  final String id;
  final String type;
  final String severity;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final bool isRead;

  TeamAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    this.userId,
    this.isRead = false,
  });
}

class TeamProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  TeamProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  // Team data
  List<User> _teamMembers = [];
  List<ActivitySession> _teamActivities = [];
  List<ProductivityScore> _teamScores = [];
  List<TeamAlert> _alerts = [];

  // Metrics
  int _activeToday = 0;
  double _averageProductivityScore = 0.0;
  Duration _totalHoursToday = Duration.zero;
  Duration _teamProductiveTime = Duration.zero;
  Duration _teamNeutralTime = Duration.zero;
  Duration _teamDistractingTime = Duration.zero;
  Duration _teamTotalTime = Duration.zero;
  User? _topPerformer;
  int _activeAlerts = 0;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<User> get teamMembers => _teamMembers;
  List<ActivitySession> get teamActivities => _teamActivities;
  List<ProductivityScore> get teamScores => _teamScores;
  List<TeamAlert> get alerts => _alerts;
  
  int get activeToday => _activeToday;
  double get averageProductivityScore => _averageProductivityScore;
  Duration get totalHoursToday => _totalHoursToday;
  Duration get teamProductiveTime => _teamProductiveTime;
  Duration get teamNeutralTime => _teamNeutralTime;
  Duration get teamDistractingTime => _teamDistractingTime;
  Duration get teamTotalTime => _teamTotalTime;
  User? get topPerformer => _topPerformer;
  int get activeAlerts => _activeAlerts;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTeamData() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _loadTeamMembers(),
        _loadTeamActivities(),
        _loadTeamScores(),
        _loadTeamAlerts(),
      ]);

      _calculateMetrics();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading team data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadTeamMembers() async {
    try {
      final response = await _apiClient.get('/users/team');
      
      if (response.data['success'] == true) {
        final List<dynamic> usersData = response.data['data']['users'];
        _teamMembers = usersData.map((userData) => User.fromJson(userData)).toList();
      }
    } catch (e) {
      debugPrint('Error loading team members: $e');
      rethrow;
    }
  }

  Future<void> _loadTeamActivities() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final response = await _apiClient.get('/activities', queryParameters: {
        'startDate': startOfDay.toIso8601String(),
        'endDate': today.toIso8601String(),
        'scope': 'team',
      });
      
      if (response.data['success'] == true) {
        final List<dynamic> activitiesData = response.data['data']['activities'];
        _teamActivities = activitiesData
            .map((activityData) => ActivitySession.fromJson(activityData))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading team activities: $e');
      rethrow;
    }
  }

  Future<void> _loadTeamScores() async {
    try {
      final response = await _apiClient.get('/analytics/productivity-score', queryParameters: {
        'scope': 'team',
        'granularity': 'daily',
        'period': '7d',
      });
      
      if (response.data['success'] == true) {
        final List<dynamic> scoresData = response.data['data']['scores'];
        _teamScores = scoresData
            .map((scoreData) => ProductivityScore.fromJson(scoreData))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading team scores: $e');
      rethrow;
    }
  }

  Future<void> _loadTeamAlerts() async {
    try {
      final response = await _apiClient.get('/notifications/alerts', queryParameters: {
        'scope': 'team',
        'status': 'active',
      });
      
      if (response.data['success'] == true) {
        final List<dynamic> alertsData = response.data['data']['alerts'];
        _alerts = alertsData.map((alertData) => TeamAlert(
          id: alertData['id'],
          type: alertData['type'],
          severity: alertData['severity'],
          title: alertData['title'],
          description: alertData['description'],
          timestamp: DateTime.parse(alertData['timestamp']),
          userId: alertData['userId'],
          isRead: alertData['isRead'] ?? false,
        )).toList();
      }
    } catch (e) {
      debugPrint('Error loading team alerts: $e');
      rethrow;
    }
  }

  void _calculateMetrics() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Calculate active users today
    final activeUserIds = _teamActivities
        .where((activity) => activity.startTime.isAfter(startOfDay))
        .map((activity) => activity.userId)
        .toSet();
    _activeToday = activeUserIds.length;

    // Calculate total hours today
    final todayActivities = _teamActivities
        .where((activity) => activity.startTime.isAfter(startOfDay))
        .toList();

    _teamTotalTime = todayActivities.fold<Duration>(
      Duration.zero,
      (sum, activity) => sum + activity.duration,
    );

    // Calculate time by category
    _teamProductiveTime = todayActivities
        .where((activity) => activity.category == ProductivityCategory.productive)
        .fold<Duration>(Duration.zero, (sum, activity) => sum + activity.duration);

    _teamNeutralTime = todayActivities
        .where((activity) => activity.category == ProductivityCategory.neutral)
        .fold<Duration>(Duration.zero, (sum, activity) => sum + activity.duration);

    _teamDistractingTime = todayActivities
        .where((activity) => activity.category == ProductivityCategory.distracting)
        .fold<Duration>(Duration.zero, (sum, activity) => sum + activity.duration);

    _totalHoursToday = _teamTotalTime;

    // Calculate average productivity score
    if (_teamScores.isNotEmpty) {
      final todayScores = _teamScores
          .where((score) => _isSameDay(score.date, today))
          .toList();
      
      if (todayScores.isNotEmpty) {
        _averageProductivityScore = todayScores
            .map((score) => score.overallScore)
            .reduce((a, b) => a + b) / todayScores.length;
      }
    }

    // Find top performer
    if (_teamScores.isNotEmpty) {
      final weekScores = _teamScores
          .where((score) => today.difference(score.date).inDays <= 7)
          .toList();
      
      if (weekScores.isNotEmpty) {
        final topScore = weekScores.reduce((a, b) => 
          a.overallScore > b.overallScore ? a : b);
        _topPerformer = _teamMembers
            .where((member) => member.id == topScore.userId)
            .firstOrNull;
      }
    }

    // Count active alerts
    _activeAlerts = _alerts.where((alert) => !alert.isRead).length;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Future<void> refreshTeamData() async {
    await loadTeamData();
  }

  Future<void> markAlertAsRead(String alertId) async {
    try {
      await _apiClient.put('/notifications/alerts/$alertId', data: {
        'isRead': true,
      });

      final alertIndex = _alerts.indexWhere((alert) => alert.id == alertId);
      if (alertIndex != -1) {
        _alerts[alertIndex] = TeamAlert(
          id: _alerts[alertIndex].id,
          type: _alerts[alertIndex].type,
          severity: _alerts[alertIndex].severity,
          title: _alerts[alertIndex].title,
          description: _alerts[alertIndex].description,
          timestamp: _alerts[alertIndex].timestamp,
          userId: _alerts[alertIndex].userId,
          isRead: true,
        );
        
        _activeAlerts = _alerts.where((alert) => !alert.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking alert as read: $e');
    }
  }

  Future<void> dismissAlert(String alertId) async {
    try {
      await _apiClient.delete('/notifications/alerts/$alertId');
      
      _alerts.removeWhere((alert) => alert.id == alertId);
      _activeAlerts = _alerts.where((alert) => !alert.isRead).length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error dismissing alert: $e');
    }
  }

  Future<List<User>> getTeamMemberDetails(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/team-details');
      
      if (response.data['success'] == true) {
        final List<dynamic> membersData = response.data['data']['members'];
        return membersData.map((memberData) => User.fromJson(memberData)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error getting team member details: $e');
      return [];
    }
  }

  Future<void> updateTeamMemberRole(String userId, UserRole newRole) async {
    try {
      await _apiClient.put('/users/$userId/role', data: {
        'role': newRole.toString().split('.').last,
      });

      final memberIndex = _teamMembers.indexWhere((member) => member.id == userId);
      if (memberIndex != -1) {
        _teamMembers[memberIndex] = _teamMembers[memberIndex].copyWith(role: newRole);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating team member role: $e');
      rethrow;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void dispose() {
    super.dispose();
  }
}

// Extension to add firstOrNull method
extension FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}