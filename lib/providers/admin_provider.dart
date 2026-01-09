import 'package:flutter/foundation.dart';

class AdminProvider extends ChangeNotifier {
  // System Overview
  int _totalUsers = 156;
  int _activeUsers = 142;
  int _totalDepartments = 8;
  String _storageUsed = '2.4 TB';
  String _storageLimit = '5.0 TB';
  int _systemHealthScore = 94;
  String _systemStatus = 'Healthy';

  // Organization Metrics
  int _dailyActiveUsers = 128;
  double _dauGrowth = 3.2;
  double _avgProductivity = 0.78;
  double _productivityTrend = 2.1;
  String _dataProcessedToday = '847 GB';
  int _apiRequestsToday = 45672;
  double _apiGrowth = 1.8;

  // Security Status
  int _securityScore = 92;
  int _failedLogins = 3;
  int _activeSessions = 89;
  int _securityAlerts = 1;
  String _lastSecurityScan = '2 hours ago';

  // Compliance Status
  int _complianceScore = 96;
  bool _gdprCompliance = true;
  bool _soc2Compliance = true;
  bool _iso27001Compliance = true;
  bool _dataRetentionCompliance = true;

  // System Health
  double _cpuUsage = 45.2;
  double _memoryUsage = 67.8;
  double _diskUsage = 34.1;
  double _networkIO = 23.5;
  String _systemUptime = '15 days, 4 hours';
  String _lastRestart = 'Dec 22, 2024';

  bool _isLoading = false;

  // Getters
  int get totalUsers => _totalUsers;
  int get activeUsers => _activeUsers;
  int get totalDepartments => _totalDepartments;
  String get storageUsed => _storageUsed;
  String get storageLimit => _storageLimit;
  int get systemHealthScore => _systemHealthScore;
  String get systemStatus => _systemStatus;

  int get dailyActiveUsers => _dailyActiveUsers;
  double get dauGrowth => _dauGrowth;
  double get avgProductivity => _avgProductivity;
  double get productivityTrend => _productivityTrend;
  String get dataProcessedToday => _dataProcessedToday;
  int get apiRequestsToday => _apiRequestsToday;
  double get apiGrowth => _apiGrowth;

  int get securityScore => _securityScore;
  int get failedLogins => _failedLogins;
  int get activeSessions => _activeSessions;
  int get securityAlerts => _securityAlerts;
  String get lastSecurityScan => _lastSecurityScan;

  int get complianceScore => _complianceScore;
  bool get gdprCompliance => _gdprCompliance;
  bool get soc2Compliance => _soc2Compliance;
  bool get iso27001Compliance => _iso27001Compliance;
  bool get dataRetentionCompliance => _dataRetentionCompliance;

  double get cpuUsage => _cpuUsage;
  double get memoryUsage => _memoryUsage;
  double get diskUsage => _diskUsage;
  double get networkIO => _networkIO;
  String get systemUptime => _systemUptime;
  String get lastRestart => _lastRestart;

  bool get isLoading => _isLoading;

  Future<void> loadSystemOverview() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would fetch from API
    // For demo, we'll just use the mock data above

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await loadSystemOverview();
  }
}