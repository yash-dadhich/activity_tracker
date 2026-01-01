class MonitoringConfig {
  final bool screenshotEnabled;
  final int screenshotInterval; // in seconds
  final bool keystrokeTracking;
  final bool mouseTracking;
  final bool applicationTracking;
  final int idleThreshold; // in seconds
  final String serverUrl;
  final String apiKey;

  MonitoringConfig({
    this.screenshotEnabled = true,
    this.screenshotInterval = 300, // 5 minutes default
    this.keystrokeTracking = true,
    this.mouseTracking = true,
    this.applicationTracking = true,
    this.idleThreshold = 300,
    this.serverUrl = '',
    this.apiKey = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'screenshotEnabled': screenshotEnabled,
      'screenshotInterval': screenshotInterval,
      'keystrokeTracking': keystrokeTracking,
      'mouseTracking': mouseTracking,
      'applicationTracking': applicationTracking,
      'idleThreshold': idleThreshold,
      'serverUrl': serverUrl,
      'apiKey': apiKey,
    };
  }

  factory MonitoringConfig.fromJson(Map<String, dynamic> json) {
    return MonitoringConfig(
      screenshotEnabled: json['screenshotEnabled'] ?? true,
      screenshotInterval: json['screenshotInterval'] ?? 300,
      keystrokeTracking: json['keystrokeTracking'] ?? true,
      mouseTracking: json['mouseTracking'] ?? true,
      applicationTracking: json['applicationTracking'] ?? true,
      idleThreshold: json['idleThreshold'] ?? 300,
      serverUrl: json['serverUrl'] ?? '',
      apiKey: json['apiKey'] ?? '',
    );
  }

  MonitoringConfig copyWith({
    bool? screenshotEnabled,
    int? screenshotInterval,
    bool? keystrokeTracking,
    bool? mouseTracking,
    bool? applicationTracking,
    int? idleThreshold,
    String? serverUrl,
    String? apiKey,
  }) {
    return MonitoringConfig(
      screenshotEnabled: screenshotEnabled ?? this.screenshotEnabled,
      screenshotInterval: screenshotInterval ?? this.screenshotInterval,
      keystrokeTracking: keystrokeTracking ?? this.keystrokeTracking,
      mouseTracking: mouseTracking ?? this.mouseTracking,
      applicationTracking: applicationTracking ?? this.applicationTracking,
      idleThreshold: idleThreshold ?? this.idleThreshold,
      serverUrl: serverUrl ?? this.serverUrl,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
