import 'package:flutter/foundation.dart';
import '../models/monitoring_config.dart';
import '../services/comprehensive_monitoring_service.dart';

class ActivityProvider extends ChangeNotifier {
  bool _isMonitoring = false;
  List<String> _screenshotPaths = [];
  MonitoringConfig _config = MonitoringConfig();
  
  // Comprehensive monitoring service
  final ComprehensiveMonitoringService _comprehensiveService = ComprehensiveMonitoringService();

  // Mock data for demo (will be replaced with real data from monitoring)
  double _todayProductivityScore = 0.78;
  int _todayAppCount = 12;
  Duration _todayProductiveTime = const Duration(hours: 5, minutes: 30);
  Duration _todayActiveTime = const Duration(hours: 7, minutes: 45);
  Duration _todayNeutralTime = const Duration(hours: 1, minutes: 30);
  Duration _todayDistractingTime = const Duration(minutes: 45);

  // Real-time activity data
  int _keystrokeCount = 0;
  int _mouseClickCount = 0;
  int _applicationSwitches = 0;
  int _fileOperations = 0;
  int _websiteVisits = 0;
  int _screenshotsTaken = 0;

  bool get isMonitoring => _isMonitoring;
  List<String> get screenshotPaths => _screenshotPaths;
  MonitoringConfig get config => _config;
  int get screenshotCount => _screenshotPaths.length;

  // Demo getters (will be updated with real data)
  double get todayProductivityScore => _todayProductivityScore;
  int get todayAppCount => _todayAppCount;
  Duration get todayProductiveTime => _todayProductiveTime;
  Duration get todayActiveTime => _todayActiveTime;
  Duration get todayNeutralTime => _todayNeutralTime;
  Duration get todayDistractingTime => _todayDistractingTime;

  // Real-time activity getters
  int get keystrokeCount => _keystrokeCount;
  int get mouseClickCount => _mouseClickCount;
  int get applicationSwitches => _applicationSwitches;
  int get fileOperations => _fileOperations;
  int get websiteVisits => _websiteVisits;
  int get screenshotsTaken => _screenshotsTaken;

  // Comprehensive monitoring getters
  List<KeystrokeEvent> get keystrokes => _comprehensiveService.keystrokes;
  List<MouseEvent> get mouseEvents => _comprehensiveService.mouseEvents;
  List<ScreenEvent> get screenEvents => _comprehensiveService.screenEvents;
  List<ApplicationEvent> get applicationEvents => _comprehensiveService.applicationEvents;
  List<FileEvent> get fileEvents => _comprehensiveService.fileEvents;
  List<BrowserEvent> get browserEvents => _comprehensiveService.browserEvents;
  List<ScreenshotEvent> get screenshots => _comprehensiveService.screenshots;
  
  Map<String, Duration> get applicationTimeTracking => _comprehensiveService.applicationTimeTracking;
  Map<String, Duration> get websiteTimeTracking => _comprehensiveService.websiteTimeTracking;

  ActivityProvider() {
    // Listen to comprehensive monitoring service changes
    _comprehensiveService.addListener(_onComprehensiveServiceUpdate);
  }

  void _onComprehensiveServiceUpdate() {
    // Update real-time counters
    _keystrokeCount = _comprehensiveService.keystrokes.length;
    _mouseClickCount = _comprehensiveService.mouseEvents.where((e) => e.eventType == 'click').length;
    _applicationSwitches = _comprehensiveService.applicationEvents.length;
    _fileOperations = _comprehensiveService.fileEvents.length;
    _websiteVisits = _comprehensiveService.browserEvents.length;
    _screenshotsTaken = _comprehensiveService.screenshots.length;

    // Update productivity analytics
    final analytics = _comprehensiveService.getProductivityAnalytics();
    _todayProductivityScore = analytics['productivity_score'] ?? 0.0;
    _todayAppCount = _comprehensiveService.applicationTimeTracking.length;
    
    // Update time tracking
    final totalSeconds = analytics['total_time'] ?? 0;
    final productiveSeconds = analytics['productive_time'] ?? 0;
    final distractingSeconds = analytics['distracting_time'] ?? 0;
    final neutralSeconds = analytics['neutral_time'] ?? 0;
    
    _todayActiveTime = Duration(seconds: totalSeconds);
    _todayProductiveTime = Duration(seconds: productiveSeconds);
    _todayDistractingTime = Duration(seconds: distractingSeconds);
    _todayNeutralTime = Duration(seconds: neutralSeconds);

    notifyListeners();
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    try {
      // Start comprehensive monitoring
      await _comprehensiveService.startMonitoring();
      _isMonitoring = true;
      
      debugPrint('🔍 Activity monitoring started with comprehensive tracking');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to start activity monitoring: $e');
    }
  }

  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;
    
    try {
      // Stop comprehensive monitoring
      await _comprehensiveService.stopMonitoring();
      _isMonitoring = false;
      
      debugPrint('🛑 Activity monitoring stopped');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to stop activity monitoring: $e');
    }
  }

  void addScreenshot(String path) {
    _screenshotPaths.insert(0, path);
    // Keep only last 50 screenshots in memory
    if (_screenshotPaths.length > 50) {
      _screenshotPaths = _screenshotPaths.sublist(0, 50);
    }
    notifyListeners();
  }

  void updateConfig(MonitoringConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void clearScreenshots() {
    _screenshotPaths.clear();
    notifyListeners();
  }

  Future<void> loadTodayStats() async {
    // Simulate loading data
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Update with real analytics if monitoring is active
    if (_isMonitoring) {
      _onComprehensiveServiceUpdate();
    }
    
    notifyListeners();
  }

  // Get detailed activity log for reports
  List<Map<String, dynamic>> getDetailedActivityLog() {
    return _comprehensiveService.getDetailedActivityLog();
  }

  // Get productivity analytics
  Map<String, dynamic> getProductivityAnalytics() {
    return _comprehensiveService.getProductivityAnalytics();
  }

  // Get activity summary for a specific time period
  Map<String, dynamic> getActivitySummary({
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final now = DateTime.now();
    final start = startTime ?? DateTime(now.year, now.month, now.day);
    final end = endTime ?? now;

    // Filter events by time period
    final filteredKeystrokes = keystrokes.where((e) => 
      e.timestamp.isAfter(start) && e.timestamp.isBefore(end)
    ).toList();
    
    final filteredMouseEvents = mouseEvents.where((e) => 
      e.timestamp.isAfter(start) && e.timestamp.isBefore(end)
    ).toList();
    
    final filteredApplicationEvents = applicationEvents.where((e) => 
      e.timestamp.isAfter(start) && e.timestamp.isBefore(end)
    ).toList();

    return {
      'period': {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'duration': end.difference(start).inSeconds,
      },
      'activity_counts': {
        'keystrokes': filteredKeystrokes.length,
        'mouse_events': filteredMouseEvents.length,
        'application_switches': filteredApplicationEvents.length,
        'screenshots': screenshots.where((e) => 
          e.timestamp.isAfter(start) && e.timestamp.isBefore(end)
        ).length,
      },
      'productivity_score': _todayProductivityScore,
      'time_distribution': {
        'productive': _todayProductiveTime.inSeconds,
        'neutral': _todayNeutralTime.inSeconds,
        'distracting': _todayDistractingTime.inSeconds,
      },
      'top_applications': _getTopApplications(start, end),
      'top_websites': _getTopWebsites(start, end),
    };
  }

  List<Map<String, dynamic>> _getTopApplications(DateTime start, DateTime end) {
    return applicationTimeTracking.entries
        .map((entry) => {
          'name': entry.key,
          'duration': entry.value.inSeconds,
          'percentage': _todayActiveTime.inSeconds > 0 
              ? (entry.value.inSeconds / _todayActiveTime.inSeconds * 100).round()
              : 0,
        })
        .toList()
      ..sort((a, b) => (b['duration'] as int).compareTo(a['duration'] as int));
  }

  List<Map<String, dynamic>> _getTopWebsites(DateTime start, DateTime end) {
    return websiteTimeTracking.entries
        .map((entry) => {
          'domain': entry.key,
          'duration': entry.value.inSeconds,
          'percentage': _todayActiveTime.inSeconds > 0 
              ? (entry.value.inSeconds / _todayActiveTime.inSeconds * 100).round()
              : 0,
        })
        .toList()
      ..sort((a, b) => (b['duration'] as int).compareTo(a['duration'] as int));
  }

  @override
  void dispose() {
    _comprehensiveService.removeListener(_onComprehensiveServiceUpdate);
    _comprehensiveService.dispose();
    super.dispose();
  }
}
