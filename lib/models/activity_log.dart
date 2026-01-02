class ActivityLog {
  final String id;
  final DateTime timestamp;
  final String activeWindow;
  final String applicationName;
  final String? screenshotPath;
  final int keystrokes;
  final int mouseClicks;
  final bool isIdle;
  final Map<String, String>? detailedInfo; // NEW: Detailed activity info

  ActivityLog({
    required this.id,
    required this.timestamp,
    required this.activeWindow,
    required this.applicationName,
    this.screenshotPath,
    this.keystrokes = 0,
    this.mouseClicks = 0,
    this.isIdle = false,
    this.detailedInfo,
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
      'detailedInfo': detailedInfo,
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
      detailedInfo: json['detailedInfo'] != null 
          ? Map<String, String>.from(json['detailedInfo'])
          : null,
    );
  }
  
  String get detailedSummary {
    if (detailedInfo == null || detailedInfo!.isEmpty) {
      return activeWindow;
    }
    
    // Browser
    if (detailedInfo!.containsKey('site')) {
      final site = detailedInfo!['site'];
      if (site == 'YouTube' && detailedInfo!.containsKey('videoTitle')) {
        return '🎥 YouTube: ${detailedInfo!['videoTitle']}';
      } else if (site == 'GitHub' && detailedInfo!.containsKey('repository')) {
        return '💻 GitHub: ${detailedInfo!['repository']}';
      } else {
        return '🌐 $site';
      }
    }
    
    // Development
    if (detailedInfo!.containsKey('fileName')) {
      final file = detailedInfo!['fileName'];
      final branch = detailedInfo!['branch'];
      final lang = detailedInfo!['language'];
      return '💻 $file${lang != null ? " ($lang)" : ""}${branch != null ? " [$branch]" : ""}';
    }
    
    // Document
    if (detailedInfo!.containsKey('documentName')) {
      final doc = detailedInfo!['documentName'];
      final type = detailedInfo!['documentType'];
      return '📄 $doc${type != null ? " ($type)" : ""}';
    }
    
    // Media
    if (detailedInfo!.containsKey('song') && detailedInfo!.containsKey('artist')) {
      return '🎵 ${detailedInfo!['artist']} - ${detailedInfo!['song']}';
    }
    
    // Communication
    if (detailedInfo!.containsKey('chatWith')) {
      return '💬 ${detailedInfo!['chatWith']}';
    }
    
    return activeWindow;
  }
}
