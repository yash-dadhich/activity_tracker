class DetailedActivity {
  final String applicationName;
  final String windowTitle;
  final ActivityType type;
  final Map<String, String> details;
  
  DetailedActivity({
    required this.applicationName,
    required this.windowTitle,
    required this.type,
    required this.details,
  });
  
  String get summary {
    switch (type) {
      case ActivityType.browser:
        return details['url'] ?? details['pageTitle'] ?? windowTitle;
      case ActivityType.development:
        return '${details['fileName'] ?? 'Unknown'} (${details['branch'] ?? 'no branch'})';
      case ActivityType.document:
        return details['documentName'] ?? windowTitle;
      case ActivityType.media:
        return details['mediaTitle'] ?? windowTitle;
      case ActivityType.communication:
        return details['chatWith'] ?? windowTitle;
      default:
        return windowTitle;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'applicationName': applicationName,
      'windowTitle': windowTitle,
      'type': type.toString(),
      'details': details,
      'summary': summary,
    };
  }
}

enum ActivityType {
  browser,
  development,
  document,
  media,
  communication,
  other,
}

class ActivityParser {
  static DetailedActivity parse(String applicationName, String windowTitle) {
    final appLower = applicationName.toLowerCase();
    final titleLower = windowTitle.toLowerCase();
    
    // Browser detection
    if (_isBrowser(appLower)) {
      return _parseBrowser(applicationName, windowTitle);
    }
    
    // Development tools
    if (_isDevelopmentTool(appLower)) {
      return _parseDevelopmentTool(applicationName, windowTitle);
    }
    
    // Document editors
    if (_isDocumentEditor(appLower)) {
      return _parseDocument(applicationName, windowTitle);
    }
    
    // Media players
    if (_isMediaPlayer(appLower)) {
      return _parseMedia(applicationName, windowTitle);
    }
    
    // Communication apps
    if (_isCommunicationApp(appLower)) {
      return _parseCommunication(applicationName, windowTitle);
    }
    
    // Default
    return DetailedActivity(
      applicationName: applicationName,
      windowTitle: windowTitle,
      type: ActivityType.other,
      details: {},
    );
  }
  
  // Browser parsing
  static bool _isBrowser(String app) {
    return app.contains('chrome') || 
           app.contains('firefox') || 
           app.contains('edge') || 
           app.contains('safari') ||
           app.contains('brave') ||
           app.contains('opera');
  }
  
  static DetailedActivity _parseBrowser(String app, String title) {
    final details = <String, String>{};
    
    // Extract URL from title (usually format: "Page Title - URL")
    if (title.contains(' - ')) {
      final parts = title.split(' - ');
      if (parts.length >= 2) {
        details['pageTitle'] = parts[0].trim();
        details['domain'] = parts.last.trim();
      }
    }
    
    // Detect specific sites
    if (title.toLowerCase().contains('youtube')) {
      details['site'] = 'YouTube';
      details['videoTitle'] = title.split(' - YouTube')[0].trim();
    } else if (title.toLowerCase().contains('github')) {
      details['site'] = 'GitHub';
      if (title.contains('/')) {
        details['repository'] = _extractGitHubRepo(title);
      }
    } else if (title.toLowerCase().contains('stackoverflow')) {
      details['site'] = 'Stack Overflow';
    } else if (title.toLowerCase().contains('gmail') || title.toLowerCase().contains('mail')) {
      details['site'] = 'Email';
    } else if (title.toLowerCase().contains('facebook')) {
      details['site'] = 'Facebook';
    } else if (title.toLowerCase().contains('twitter') || title.toLowerCase().contains('x.com')) {
      details['site'] = 'Twitter/X';
    } else if (title.toLowerCase().contains('linkedin')) {
      details['site'] = 'LinkedIn';
    } else if (title.toLowerCase().contains('slack')) {
      details['site'] = 'Slack Web';
    }
    
    return DetailedActivity(
      applicationName: app,
      windowTitle: title,
      type: ActivityType.browser,
      details: details,
    );
  }
  
  static String _extractGitHubRepo(String title) {
    final match = RegExp(r'([a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+)').firstMatch(title);
    return match?.group(0) ?? '';
  }
  
  // Development tools parsing
  static bool _isDevelopmentTool(String app) {
    return app.contains('code') || // VS Code
           app.contains('studio') || // Android Studio, Visual Studio
           app.contains('intellij') ||
           app.contains('pycharm') ||
           app.contains('webstorm') ||
           app.contains('eclipse') ||
           app.contains('atom') ||
           app.contains('sublime');
  }
  
  static DetailedActivity _parseDevelopmentTool(String app, String title) {
    final details = <String, String>{};
    
    // VS Code format: "filename - folder - Visual Studio Code"
    if (title.contains(' - ')) {
      final parts = title.split(' - ');
      if (parts.isNotEmpty) {
        details['fileName'] = parts[0].trim();
      }
      if (parts.length > 1) {
        details['projectFolder'] = parts[1].trim();
      }
    }
    
    // Extract file extension
    if (details['fileName'] != null) {
      final fileName = details['fileName']!;
      if (fileName.contains('.')) {
        final ext = fileName.split('.').last;
        details['fileType'] = ext;
        details['language'] = _getLanguageFromExtension(ext);
      }
    }
    
    // Try to extract Git branch (if visible in title)
    if (title.contains('(') && title.contains(')')) {
      final branchMatch = RegExp(r'\(([^)]+)\)').firstMatch(title);
      if (branchMatch != null) {
        details['branch'] = branchMatch.group(1) ?? '';
      }
    }
    
    // Android Studio specific
    if (app.toLowerCase().contains('android')) {
      details['ide'] = 'Android Studio';
      if (title.contains('[')) {
        final projectMatch = RegExp(r'\[([^\]]+)\]').firstMatch(title);
        if (projectMatch != null) {
          details['projectName'] = projectMatch.group(1) ?? '';
        }
      }
    }
    
    return DetailedActivity(
      applicationName: app,
      windowTitle: title,
      type: ActivityType.development,
      details: details,
    );
  }
  
  static String _getLanguageFromExtension(String ext) {
    const languageMap = {
      'dart': 'Dart',
      'js': 'JavaScript',
      'ts': 'TypeScript',
      'py': 'Python',
      'java': 'Java',
      'kt': 'Kotlin',
      'swift': 'Swift',
      'cpp': 'C++',
      'c': 'C',
      'cs': 'C#',
      'go': 'Go',
      'rs': 'Rust',
      'php': 'PHP',
      'rb': 'Ruby',
      'html': 'HTML',
      'css': 'CSS',
      'json': 'JSON',
      'xml': 'XML',
      'md': 'Markdown',
    };
    return languageMap[ext.toLowerCase()] ?? ext.toUpperCase();
  }
  
  // Document editors
  static bool _isDocumentEditor(String app) {
    return app.contains('word') ||
           app.contains('excel') ||
           app.contains('powerpoint') ||
           app.contains('notepad') ||
           app.contains('libreoffice') ||
           app.contains('pages') ||
           app.contains('numbers') ||
           app.contains('keynote');
  }
  
  static DetailedActivity _parseDocument(String app, String title) {
    final details = <String, String>{};
    
    // Extract document name (usually before " - " or ".docx")
    if (title.contains(' - ')) {
      details['documentName'] = title.split(' - ')[0].trim();
    } else {
      details['documentName'] = title;
    }
    
    // Detect document type
    if (app.toLowerCase().contains('word') || title.toLowerCase().contains('.doc')) {
      details['documentType'] = 'Word Document';
    } else if (app.toLowerCase().contains('excel') || title.toLowerCase().contains('.xls')) {
      details['documentType'] = 'Excel Spreadsheet';
    } else if (app.toLowerCase().contains('powerpoint') || title.toLowerCase().contains('.ppt')) {
      details['documentType'] = 'PowerPoint Presentation';
    }
    
    return DetailedActivity(
      applicationName: app,
      windowTitle: title,
      type: ActivityType.document,
      details: details,
    );
  }
  
  // Media players
  static bool _isMediaPlayer(String app) {
    return app.contains('vlc') ||
           app.contains('media player') ||
           app.contains('spotify') ||
           app.contains('itunes') ||
           app.contains('music');
  }
  
  static DetailedActivity _parseMedia(String app, String title) {
    final details = <String, String>{};
    
    // VLC format: "filename - VLC media player"
    if (title.contains(' - ')) {
      details['mediaTitle'] = title.split(' - ')[0].trim();
    } else {
      details['mediaTitle'] = title;
    }
    
    // Detect media type
    if (title.toLowerCase().contains('.mp4') || 
        title.toLowerCase().contains('.avi') ||
        title.toLowerCase().contains('.mkv')) {
      details['mediaType'] = 'Video';
    } else if (title.toLowerCase().contains('.mp3') || 
               title.toLowerCase().contains('.wav')) {
      details['mediaType'] = 'Audio';
    }
    
    // Spotify specific
    if (app.toLowerCase().contains('spotify')) {
      details['service'] = 'Spotify';
      if (title.contains(' - ')) {
        final parts = title.split(' - ');
        if (parts.length >= 2) {
          details['artist'] = parts[0].trim();
          details['song'] = parts[1].trim();
        }
      }
    }
    
    return DetailedActivity(
      applicationName: app,
      windowTitle: title,
      type: ActivityType.media,
      details: details,
    );
  }
  
  // Communication apps
  static bool _isCommunicationApp(String app) {
    return app.contains('slack') ||
           app.contains('teams') ||
           app.contains('zoom') ||
           app.contains('discord') ||
           app.contains('skype') ||
           app.contains('telegram') ||
           app.contains('whatsapp');
  }
  
  static DetailedActivity _parseCommunication(String app, String title) {
    final details = <String, String>{};
    
    // Extract chat/meeting info
    if (title.contains('|')) {
      final parts = title.split('|');
      details['chatWith'] = parts[0].trim();
    } else if (title.contains(' - ')) {
      details['chatWith'] = title.split(' - ')[0].trim();
    }
    
    // Detect meeting
    if (title.toLowerCase().contains('meeting') || 
        title.toLowerCase().contains('call')) {
      details['activityType'] = 'Meeting/Call';
    } else {
      details['activityType'] = 'Chat';
    }
    
    return DetailedActivity(
      applicationName: app,
      windowTitle: title,
      type: ActivityType.communication,
      details: details,
    );
  }
}
