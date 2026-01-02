class AppUsage {
  final String applicationName;
  final DateTime startTime;
  DateTime? endTime;
  int totalSeconds;
  int keystrokeCount;
  int mouseClickCount;
  List<String> windowTitles;
  
  AppUsage({
    required this.applicationName,
    required this.startTime,
    this.endTime,
    this.totalSeconds = 0,
    this.keystrokeCount = 0,
    this.mouseClickCount = 0,
    List<String>? windowTitles,
  }) : windowTitles = windowTitles ?? [];
  
  void addTime(int seconds) {
    totalSeconds += seconds;
  }
  
  void addKeystrokes(int count) {
    keystrokeCount += count;
  }
  
  void addMouseClicks(int count) {
    mouseClickCount += count;
  }
  
  void addWindowTitle(String title) {
    if (!windowTitles.contains(title)) {
      windowTitles.add(title);
    }
  }
  
  String get formattedDuration {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  double get productivityScore {
    // Simple productivity score based on activity
    // More keystrokes/clicks = more productive
    final activityScore = (keystrokeCount + mouseClickCount) / (totalSeconds / 60);
    return activityScore.clamp(0, 100);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'applicationName': applicationName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalSeconds': totalSeconds,
      'keystrokeCount': keystrokeCount,
      'mouseClickCount': mouseClickCount,
      'windowTitles': windowTitles,
      'formattedDuration': formattedDuration,
      'productivityScore': productivityScore,
    };
  }
  
  factory AppUsage.fromJson(Map<String, dynamic> json) {
    return AppUsage(
      applicationName: json['applicationName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      totalSeconds: json['totalSeconds'] ?? 0,
      keystrokeCount: json['keystrokeCount'] ?? 0,
      mouseClickCount: json['mouseClickCount'] ?? 0,
      windowTitles: List<String>.from(json['windowTitles'] ?? []),
    );
  }
}

class DailyReport {
  final DateTime date;
  final Map<String, AppUsage> appUsages;
  final int totalActiveSeconds;
  final int totalIdleSeconds;
  final int totalKeystrokes;
  final int totalMouseClicks;
  final int screenshotCount;
  
  DailyReport({
    required this.date,
    Map<String, AppUsage>? appUsages,
    this.totalActiveSeconds = 0,
    this.totalIdleSeconds = 0,
    this.totalKeystrokes = 0,
    this.totalMouseClicks = 0,
    this.screenshotCount = 0,
  }) : appUsages = appUsages ?? {};
  
  String get formattedActiveTime {
    final hours = totalActiveSeconds ~/ 3600;
    final minutes = (totalActiveSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }
  
  String get formattedIdleTime {
    final hours = totalIdleSeconds ~/ 3600;
    final minutes = (totalIdleSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }
  
  double get productivityPercentage {
    final total = totalActiveSeconds + totalIdleSeconds;
    if (total == 0) return 0;
    return (totalActiveSeconds / total) * 100;
  }
  
  List<AppUsage> get topApps {
    final apps = appUsages.values.toList();
    apps.sort((a, b) => b.totalSeconds.compareTo(a.totalSeconds));
    return apps.take(10).toList();
  }
  
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'appUsages': appUsages.map((key, value) => MapEntry(key, value.toJson())),
      'totalActiveSeconds': totalActiveSeconds,
      'totalIdleSeconds': totalIdleSeconds,
      'totalKeystrokes': totalKeystrokes,
      'totalMouseClicks': totalMouseClicks,
      'screenshotCount': screenshotCount,
      'formattedActiveTime': formattedActiveTime,
      'formattedIdleTime': formattedIdleTime,
      'productivityPercentage': productivityPercentage,
    };
  }
}
