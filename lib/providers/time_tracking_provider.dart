import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../domain/entities/time_entry.dart';

class TimeTrackingProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  TimeTrackingProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  TimeEntry? _currentSession;
  List<TimeEntry> _timeEntries = [];
  bool _isLoading = false;
  String? _error;
  bool _isMonitoring = false;

  // Getters
  TimeEntry? get currentSession => _currentSession;
  List<TimeEntry> get timeEntries => _timeEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isClockedIn => _currentSession != null && _currentSession!.isActive;
  bool get isMonitoring => _isMonitoring;

  Duration get currentSessionDuration {
    if (_currentSession == null) return Duration.zero;
    return _currentSession!.currentDuration;
  }

  Future<void> loadCurrentSession() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.get('/time-tracking/current-session');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data['session'] != null) {
          _currentSession = TimeEntry.fromJson(data['session']);
          _isMonitoring = data['isMonitoring'] ?? false;
        } else {
          _currentSession = null;
          _isMonitoring = false;
        }
      } else {
        _error = response.data['error'] ?? 'Failed to load current session';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Load current session error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> clockIn({String? location}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.post('/time-tracking/clock-in', data: {
        'location': location,
        'deviceInfo': _getDeviceInfo(),
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _currentSession = TimeEntry.fromJson(data['session']);
        _isMonitoring = true;
        notifyListeners();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to clock in';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Clock in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> clockOut() async {
    if (_currentSession == null) return false;

    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.post('/time-tracking/clock-out', data: {
        'sessionId': _currentSession!.id,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _currentSession = TimeEntry.fromJson(data['session']);
        _isMonitoring = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to clock out';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Clock out error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTimeEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final queryParams = <String>[];
      if (startDate != null) {
        queryParams.add('startDate=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        queryParams.add('endDate=${endDate.toIso8601String()}');
      }
      if (userId != null) {
        queryParams.add('userId=$userId');
      }

      final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await _apiClient.get('/time-tracking/sessions$query');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _timeEntries = (data['sessions'] as List)
            .map((json) => TimeEntry.fromJson(json))
            .toList();
      } else {
        _error = response.data['error'] ?? 'Failed to load time entries';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Load time entries error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getWorkSummary({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  }) async {
    try {
      final queryParams = <String>[];
      if (startDate != null) {
        queryParams.add('startDate=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        queryParams.add('endDate=${endDate.toIso8601String()}');
      }
      if (userId != null) {
        queryParams.add('userId=$userId');
      }

      final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await _apiClient.get('/time-tracking/summary$query');

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Get work summary error: $e');
      return null;
    }
  }

  void startMonitoring() {
    _isMonitoring = true;
    notifyListeners();
  }

  void stopMonitoring() {
    _isMonitoring = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Map<String, dynamic> _getDeviceInfo() {
    return {
      'platform': defaultTargetPlatform.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
