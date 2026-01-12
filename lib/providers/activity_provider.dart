import 'package:flutter/foundation.dart';
import '../models/monitoring_config.dart';

class ActivityProvider extends ChangeNotifier {
  bool _isMonitoring = false;
  List<String> _screenshotPaths = [];
  MonitoringConfig _config = MonitoringConfig();

  bool get isMonitoring => _isMonitoring;
  List<String> get screenshotPaths => _screenshotPaths;
  MonitoringConfig get config => _config;
  int get screenshotCount => _screenshotPaths.length;

  void startMonitoring() {
    _isMonitoring = true;
    notifyListeners();
  }

  void stopMonitoring() {
    _isMonitoring = false;
    notifyListeners();
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
}
