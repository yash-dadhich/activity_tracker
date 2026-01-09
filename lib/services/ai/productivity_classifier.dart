import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../../domain/entities/activity_session.dart';

class ProductivityClassifier {
  static const String _modelPath = 'assets/models/productivity_classifier.tflite';
  static const MethodChannel _channel = MethodChannel('com.enterprise.productivity/ai');
  
  bool _isInitialized = false;
  Map<String, ProductivityCategory> _appCategoryCache = {};
  Map<String, ProductivityCategory> _websiteCategoryCache = {};
  
  // Predefined categories for common applications and websites
  static const Map<String, ProductivityCategory> _predefinedApps = {
    // Productive applications
    'code': ProductivityCategory.productive,
    'visual studio': ProductivityCategory.productive,
    'intellij': ProductivityCategory.productive,
    'eclipse': ProductivityCategory.productive,
    'sublime': ProductivityCategory.productive,
    'atom': ProductivityCategory.productive,
    'vim': ProductivityCategory.productive,
    'emacs': ProductivityCategory.productive,
    'word': ProductivityCategory.productive,
    'excel': ProductivityCategory.productive,
    'powerpoint': ProductivityCategory.productive,
    'outlook': ProductivityCategory.productive,
    'slack': ProductivityCategory.productive,
    'teams': ProductivityCategory.productive,
    'zoom': ProductivityCategory.productive,
    'jira': ProductivityCategory.productive,
    'confluence': ProductivityCategory.productive,
    'notion': ProductivityCategory.productive,
    'trello': ProductivityCategory.productive,
    'asana': ProductivityCategory.productive,
    
    // Neutral applications
    'finder': ProductivityCategory.neutral,
    'explorer': ProductivityCategory.neutral,
    'terminal': ProductivityCategory.neutral,
    'command prompt': ProductivityCategory.neutral,
    'calculator': ProductivityCategory.neutral,
    'calendar': ProductivityCategory.neutral,
    'notes': ProductivityCategory.neutral,
    
    // Distracting applications
    'spotify': ProductivityCategory.distracting,
    'itunes': ProductivityCategory.distracting,
    'vlc': ProductivityCategory.distracting,
    'steam': ProductivityCategory.distracting,
    'discord': ProductivityCategory.distracting,
    'whatsapp': ProductivityCategory.distracting,
    'telegram': ProductivityCategory.distracting,
    
    // Personal applications
    'photos': ProductivityCategory.personal,
    'gallery': ProductivityCategory.personal,
    'music': ProductivityCategory.personal,
    'games': ProductivityCategory.personal,
  };

  static const Map<String, ProductivityCategory> _predefinedWebsites = {
    // Productive websites
    'github.com': ProductivityCategory.productive,
    'stackoverflow.com': ProductivityCategory.productive,
    'docs.google.com': ProductivityCategory.productive,
    'office.com': ProductivityCategory.productive,
    'atlassian.com': ProductivityCategory.productive,
    'aws.amazon.com': ProductivityCategory.productive,
    'azure.microsoft.com': ProductivityCategory.productive,
    'cloud.google.com': ProductivityCategory.productive,
    'developer.mozilla.org': ProductivityCategory.productive,
    'w3schools.com': ProductivityCategory.productive,
    'coursera.org': ProductivityCategory.productive,
    'udemy.com': ProductivityCategory.productive,
    'linkedin.com/learning': ProductivityCategory.productive,
    
    // Neutral websites
    'google.com': ProductivityCategory.neutral,
    'bing.com': ProductivityCategory.neutral,
    'duckduckgo.com': ProductivityCategory.neutral,
    'wikipedia.org': ProductivityCategory.neutral,
    'news.google.com': ProductivityCategory.neutral,
    'bbc.com/news': ProductivityCategory.neutral,
    'reuters.com': ProductivityCategory.neutral,
    
    // Distracting websites
    'youtube.com': ProductivityCategory.distracting,
    'netflix.com': ProductivityCategory.distracting,
    'twitch.tv': ProductivityCategory.distracting,
    'reddit.com': ProductivityCategory.distracting,
    'twitter.com': ProductivityCategory.distracting,
    'x.com': ProductivityCategory.distracting,
    'instagram.com': ProductivityCategory.distracting,
    'tiktok.com': ProductivityCategory.distracting,
    'facebook.com': ProductivityCategory.distracting,
    'pinterest.com': ProductivityCategory.distracting,
    'buzzfeed.com': ProductivityCategory.distracting,
    '9gag.com': ProductivityCategory.distracting,
    
    // Personal websites
    'amazon.com': ProductivityCategory.personal,
    'ebay.com': ProductivityCategory.personal,
    'booking.com': ProductivityCategory.personal,
    'airbnb.com': ProductivityCategory.personal,
    'gmail.com': ProductivityCategory.personal,
    'yahoo.com': ProductivityCategory.personal,
    'hotmail.com': ProductivityCategory.personal,
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize TensorFlow Lite model
      await _channel.invokeMethod('initializeModel', {'modelPath': _modelPath});
      _isInitialized = true;
      print('✅ Productivity classifier initialized');
    } catch (e) {
      print('❌ Failed to initialize productivity classifier: $e');
      // Continue without ML model - use rule-based classification
      _isInitialized = true;
    }
  }

  Future<ProductivityCategory> classifyActivity({
    required String applicationName,
    required String windowTitle,
    required bool isIdle,
    String? websiteUrl,
    Map<String, dynamic>? metadata,
  }) async {
    if (isIdle) return ProductivityCategory.neutral;

    // Check cache first
    final cacheKey = '${applicationName.toLowerCase()}_${windowTitle.toLowerCase()}';
    if (_appCategoryCache.containsKey(cacheKey)) {
      return _appCategoryCache[cacheKey]!;
    }

    ProductivityCategory category;

    try {
      // Try ML classification first
      if (_isInitialized) {
        category = await _classifyWithML(
          applicationName: applicationName,
          windowTitle: windowTitle,
          websiteUrl: websiteUrl,
          metadata: metadata,
        );
      } else {
        // Fallback to rule-based classification
        category = _classifyWithRules(
          applicationName: applicationName,
          windowTitle: windowTitle,
          websiteUrl: websiteUrl,
        );
      }
    } catch (e) {
      print('❌ ML classification failed, using rules: $e');
      category = _classifyWithRules(
        applicationName: applicationName,
        windowTitle: windowTitle,
        websiteUrl: websiteUrl,
      );
    }

    // Cache the result
    _appCategoryCache[cacheKey] = category;
    return category;
  }

  Future<ProductivityCategory> _classifyWithML({
    required String applicationName,
    required String windowTitle,
    String? websiteUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final features = _extractFeatures(
        applicationName: applicationName,
        windowTitle: windowTitle,
        websiteUrl: websiteUrl,
        metadata: metadata,
      );

      final result = await _channel.invokeMethod('classify', {
        'features': features,
      });

      final categoryIndex = result['category'] as int;
      final confidence = result['confidence'] as double;

      // Only use ML result if confidence is high enough
      if (confidence > 0.7) {
        return ProductivityCategory.values[categoryIndex];
      } else {
        // Fall back to rule-based classification
        return _classifyWithRules(
          applicationName: applicationName,
          windowTitle: windowTitle,
          websiteUrl: websiteUrl,
        );
      }
    } catch (e) {
      print('❌ ML classification error: $e');
      rethrow;
    }
  }

  ProductivityCategory _classifyWithRules({
    required String applicationName,
    required String windowTitle,
    String? websiteUrl,
  }) {
    final appLower = applicationName.toLowerCase();
    final titleLower = windowTitle.toLowerCase();

    // Check predefined applications first
    for (final entry in _predefinedApps.entries) {
      if (appLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Check website URL if available
    if (websiteUrl != null) {
      final urlLower = websiteUrl.toLowerCase();
      for (final entry in _predefinedWebsites.entries) {
        if (urlLower.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    // Check window title for website patterns
    if (_isBrowserApp(appLower)) {
      return _classifyWebsiteFromTitle(titleLower);
    }

    // Check for development-related keywords
    if (_isDevelopmentActivity(appLower, titleLower)) {
      return ProductivityCategory.productive;
    }

    // Check for communication/collaboration
    if (_isCommunicationActivity(appLower, titleLower)) {
      return ProductivityCategory.productive;
    }

    // Check for entertainment/social media
    if (_isEntertainmentActivity(appLower, titleLower)) {
      return ProductivityCategory.distracting;
    }

    // Check for system/utility applications
    if (_isSystemActivity(appLower)) {
      return ProductivityCategory.neutral;
    }

    // Default to neutral if uncertain
    return ProductivityCategory.neutral;
  }

  bool _isBrowserApp(String appName) {
    return appName.contains('chrome') ||
           appName.contains('firefox') ||
           appName.contains('safari') ||
           appName.contains('edge') ||
           appName.contains('opera') ||
           appName.contains('brave');
  }

  ProductivityCategory _classifyWebsiteFromTitle(String title) {
    // Extract domain from title (usually at the end)
    final parts = title.split(' - ');
    if (parts.isNotEmpty) {
      final lastPart = parts.last.toLowerCase();
      
      for (final entry in _predefinedWebsites.entries) {
        if (lastPart.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    // Check for common patterns in title
    if (title.contains('youtube') || title.contains('video')) {
      return ProductivityCategory.distracting;
    }
    
    if (title.contains('github') || title.contains('documentation') || title.contains('docs')) {
      return ProductivityCategory.productive;
    }
    
    if (title.contains('social') || title.contains('chat') || title.contains('message')) {
      return ProductivityCategory.distracting;
    }

    return ProductivityCategory.neutral;
  }

  bool _isDevelopmentActivity(String appName, String title) {
    final devKeywords = [
      'code', 'ide', 'editor', 'terminal', 'console', 'git', 'docker',
      'kubernetes', 'aws', 'azure', 'gcp', 'database', 'sql', 'api',
      'development', 'programming', 'coding', 'debug', 'compile'
    ];

    return devKeywords.any((keyword) => 
      appName.contains(keyword) || title.contains(keyword));
  }

  bool _isCommunicationActivity(String appName, String title) {
    final commKeywords = [
      'slack', 'teams', 'zoom', 'meet', 'skype', 'discord', 'email',
      'mail', 'outlook', 'gmail', 'calendar', 'meeting', 'conference'
    ];

    return commKeywords.any((keyword) => 
      appName.contains(keyword) || title.contains(keyword));
  }

  bool _isEntertainmentActivity(String appName, String title) {
    final entertainmentKeywords = [
      'game', 'gaming', 'steam', 'spotify', 'music', 'video', 'movie',
      'netflix', 'youtube', 'twitch', 'social', 'facebook', 'twitter',
      'instagram', 'tiktok', 'reddit', 'entertainment'
    ];

    return entertainmentKeywords.any((keyword) => 
      appName.contains(keyword) || title.contains(keyword));
  }

  bool _isSystemActivity(String appName) {
    final systemKeywords = [
      'system', 'settings', 'control', 'panel', 'preferences', 'finder',
      'explorer', 'file manager', 'task manager', 'activity monitor'
    ];

    return systemKeywords.any((keyword) => appName.contains(keyword));
  }

  Map<String, dynamic> _extractFeatures({
    required String applicationName,
    required String windowTitle,
    String? websiteUrl,
    Map<String, dynamic>? metadata,
  }) {
    return {
      'app_name': applicationName,
      'window_title': windowTitle,
      'website_url': websiteUrl ?? '',
      'app_name_length': applicationName.length,
      'title_length': windowTitle.length,
      'has_url': websiteUrl != null,
      'is_browser': _isBrowserApp(applicationName.toLowerCase()),
      'hour_of_day': DateTime.now().hour,
      'day_of_week': DateTime.now().weekday,
      'metadata': metadata ?? {},
    };
  }

  Future<double> calculateProductivityScore({
    required List<ActivitySession> sessions,
    required Duration timeWindow,
  }) async {
    if (sessions.isEmpty) return 0.0;

    double totalScore = 0.0;
    Duration totalTime = Duration.zero;

    for (final session in sessions) {
      final sessionScore = _getSessionScore(session);
      final sessionWeight = session.duration.inMinutes / timeWindow.inMinutes;
      
      totalScore += sessionScore * sessionWeight;
      totalTime += session.duration;
    }

    // Normalize score
    if (totalTime.inMinutes == 0) return 0.0;
    
    return (totalScore / sessions.length).clamp(0.0, 1.0);
  }

  double _getSessionScore(ActivitySession session) {
    switch (session.category) {
      case ProductivityCategory.productive:
        return 1.0;
      case ProductivityCategory.neutral:
        return 0.5;
      case ProductivityCategory.distracting:
        return 0.1;
      case ProductivityCategory.personal:
        return 0.3;
      case ProductivityCategory.unknown:
        return 0.5;
    }
  }

  Future<List<String>> generateProductivityInsights({
    required List<ActivitySession> sessions,
    required Duration timeWindow,
  }) async {
    final insights = <String>[];
    
    if (sessions.isEmpty) {
      insights.add('No activity data available for analysis.');
      return insights;
    }

    // Calculate category distribution
    final categoryTime = <ProductivityCategory, Duration>{};
    for (final session in sessions) {
      categoryTime[session.category] = 
          (categoryTime[session.category] ?? Duration.zero) + session.duration;
    }

    final totalTime = categoryTime.values.fold<Duration>(
      Duration.zero, (sum, duration) => sum + duration);

    if (totalTime.inMinutes > 0) {
      final productiveTime = categoryTime[ProductivityCategory.productive] ?? Duration.zero;
      final distractingTime = categoryTime[ProductivityCategory.distracting] ?? Duration.zero;
      
      final productivePercentage = (productiveTime.inMinutes / totalTime.inMinutes) * 100;
      final distractingPercentage = (distractingTime.inMinutes / totalTime.inMinutes) * 100;

      if (productivePercentage > 70) {
        insights.add('Excellent focus! You spent ${productivePercentage.toStringAsFixed(1)}% of your time on productive activities.');
      } else if (productivePercentage > 50) {
        insights.add('Good productivity with ${productivePercentage.toStringAsFixed(1)}% productive time. Consider reducing distractions.');
      } else {
        insights.add('Focus opportunity: Only ${productivePercentage.toStringAsFixed(1)}% productive time. Try time-blocking techniques.');
      }

      if (distractingPercentage > 30) {
        insights.add('High distraction time (${distractingPercentage.toStringAsFixed(1)}%). Consider using website blockers during work hours.');
      }
    }

    // Analyze patterns
    final appUsage = <String, Duration>{};
    for (final session in sessions) {
      if (session.applicationName != null) {
        appUsage[session.applicationName!] = 
            (appUsage[session.applicationName!] ?? Duration.zero) + session.duration;
      }
    }

    if (appUsage.isNotEmpty) {
      final topApp = appUsage.entries.reduce((a, b) => a.value > b.value ? a : b);
      final topAppPercentage = (topApp.value.inMinutes / totalTime.inMinutes) * 100;
      
      if (topAppPercentage > 40) {
        insights.add('You spent ${topAppPercentage.toStringAsFixed(1)}% of your time in ${topApp.key}. Consider diversifying your workflow.');
      }
    }

    return insights;
  }

  void clearCache() {
    _appCategoryCache.clear();
    _websiteCategoryCache.clear();
  }

  void dispose() {
    clearCache();
  }
}