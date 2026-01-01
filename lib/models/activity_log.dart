class ActivityLog {
  final String id;
  final DateTime timestamp;
  final String activeWindow;
  final String applicationName;
  final String? screenshotPath;
  final int keystrokes;
  final int mouseClicks;
  final bool isIdle;

  ActivityLog({
    required this.id,
    required this.timestamp,
    required this.activeWindow,
    required this.applicationName,
    this.screenshotPath,
    this.keystrokes = 0,
    this.mouseClicks = 0,
    this.isIdle = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'activeWindow': activeWindow,
      'applicationName': applicationName,
      'screenshotPath': screenshotPath,
      'keystrokes': keystrokes,
      'mouseClicks': mouseClicks,
      'isIdle': isIdle,
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      activeWindow: json['activeWindow'],
      applicationName: json['applicationName'],
      screenshotPath: json['screenshotPath'],
      keystrokes: json['keystrokes'] ?? 0,
      mouseClicks: json['mouseClicks'] ?? 0,
      isIdle: json['isIdle'] ?? false,
    );
  }
}
