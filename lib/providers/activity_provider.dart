import 'package:flutter/foundation.dart';
import '../models/activity_log.dart';
import '../models/monitoring_config.dart';

class ActivityProvider extends ChangeNotifier {
  bool _isMonitoring = false;
  List<ActivityLog> _activityLogs = [];
  MonitoringConfig _config = MonitoringConfig();
  String _currentApplication = 'Unknown';
  int _todayKeystrokes = 0;
  int _todayMouseClicks = 0;

  bool get isMonitoring => _isMonitoring;
  List<ActivityLog> get activityLogs => _activityLogs;
  MonitoringConfig get config => _config;
  String get currentApplication => _currentApplication;
  int get todayKeystrokes => _todayKeystrokes;
  int get todayMouseClicks => _todayMouseClicks;

  void startMonitoring() {
    _isMonitoring = true;
    notifyListeners();
  }

  void stopMonitoring() {
    _isMonitoring = false;
    notifyListeners();
  }

  void addActivityLog(ActivityLog log) {
    _activityLogs.insert(0, log);
    if (_activityLogs.length > 100) {
      _activityLogs = _activityLogs.sublist(0, 100);
    }
    notifyListeners();
  }

  void updateCurrentApplication(String appName) {
    _currentApplication = appName;
    notifyListeners();
  }

  void incrementKeystrokes(int count) {
    _todayKeystrokes += count;
    notifyListeners();
  }

  void incrementMouseClicks(int count) {
    _todayMouseClicks += count;
    notifyListeners();
  }

  void updateConfig(MonitoringConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void resetDailyStats() {
    _todayKeystrokes = 0;
    _todayMouseClicks = 0;
    notifyListeners();
  }
}
