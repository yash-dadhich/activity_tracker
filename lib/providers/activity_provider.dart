import 'package:flutter/foundation.dart';
import '../models/activity_log.dart';
import '../models/monitoring_config.dart';
import '../models/app_usage.dart';

class ActivityProvider extends ChangeNotifier {
  bool _isMonitoring = false;
  List<ActivityLog> _activityLogs = [];
  MonitoringConfig _config = MonitoringConfig();
  String _currentApplication = 'Unknown';
  int _todayKeystrokes = 0;
  int _todayMouseClicks = 0;
  
  // App usage tracking
  Map<String, AppUsage> _appUsages = {};
  String? _lastTrackedApp;
  DateTime _lastTrackTime = DateTime.now();
  int _totalActiveSeconds = 0;
  int _totalIdleSeconds = 0;
  int _screenshotCount = 0;

  bool get isMonitoring => _isMonitoring;
  List<ActivityLog> get activityLogs => _activityLogs;
  MonitoringConfig get config => _config;
  String get currentApplication => _currentApplication;
  int get todayKeystrokes => _todayKeystrokes;
  int get todayMouseClicks => _todayMouseClicks;
  Map<String, AppUsage> get appUsages => _appUsages;
  int get totalActiveSeconds => _totalActiveSeconds;
  int get totalIdleSeconds => _totalIdleSeconds;
  int get screenshotCount => _screenshotCount;
  
  List<AppUsage> get topApps {
    final apps = _appUsages.values.toList();
    apps.sort((a, b) => b.totalSeconds.compareTo(a.totalSeconds));
    return apps;
  }
  
  DailyReport get todayReport {
    return DailyReport(
      date: DateTime.now(),
      appUsages: _appUsages,
      totalActiveSeconds: _totalActiveSeconds,
      totalIdleSeconds: _totalIdleSeconds,
      totalKeystrokes: _todayKeystrokes,
      totalMouseClicks: _todayMouseClicks,
      screenshotCount: _screenshotCount,
    );
  }

  void startMonitoring() {
    _isMonitoring = true;
    _lastTrackTime = DateTime.now();
    notifyListeners();
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _updateAppUsageTime();
    notifyListeners();
  }

  void addActivityLog(ActivityLog log) {
    _activityLogs.insert(0, log);
    if (_activityLogs.length > 100) {
      _activityLogs = _activityLogs.sublist(0, 100);
    }
    
    // Count screenshots
    if (log.screenshotPath != null) {
      _screenshotCount++;
    }
    
    // Update app usage tracking
    _trackAppUsage(log);
    
    notifyListeners();
  }
  
  void _trackAppUsage(ActivityLog log) {
    final now = DateTime.now();
    final elapsedSeconds = now.difference(_lastTrackTime).inSeconds;
    
    // Update time for previous app
    if (_lastTrackedApp != null && _lastTrackedApp != log.applicationName) {
      _updateAppUsageTime();
    }
    
    // Get or create app usage entry
    if (!_appUsages.containsKey(log.applicationName)) {
      _appUsages[log.applicationName] = AppUsage(
        applicationName: log.applicationName,
        startTime: now,
      );
    }
    
    final appUsage = _appUsages[log.applicationName]!;
    
    // Add time (5 seconds since last check)
    if (!log.isIdle) {
      appUsage.addTime(5);
      _totalActiveSeconds += 5;
    } else {
      _totalIdleSeconds += 5;
    }
    
    // Add activity
    appUsage.addKeystrokes(log.keystrokes);
    appUsage.addMouseClicks(log.mouseClicks);
    appUsage.addWindowTitle(log.activeWindow);
    
    _lastTrackedApp = log.applicationName;
    _lastTrackTime = now;
  }
  
  void _updateAppUsageTime() {
    if (_lastTrackedApp != null && _appUsages.containsKey(_lastTrackedApp)) {
      final appUsage = _appUsages[_lastTrackedApp]!;
      appUsage.endTime = DateTime.now();
    }
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
  
  void incrementScreenshotCount() {
    _screenshotCount++;
    notifyListeners();
  }

  void updateConfig(MonitoringConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void resetDailyStats() {
    _todayKeystrokes = 0;
    _todayMouseClicks = 0;
    _appUsages.clear();
    _totalActiveSeconds = 0;
    _totalIdleSeconds = 0;
    _screenshotCount = 0;
    _lastTrackedApp = null;
    notifyListeners();
  }
  
  String getFormattedActiveTime() {
    final hours = _totalActiveSeconds ~/ 3600;
    final minutes = (_totalActiveSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }
  
  double getProductivityPercentage() {
    final total = _totalActiveSeconds + _totalIdleSeconds;
    if (total == 0) return 0;
    return (_totalActiveSeconds / total) * 100;
  }
}
