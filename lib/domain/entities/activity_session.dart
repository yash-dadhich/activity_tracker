import 'package:equatable/equatable.dart';

enum ActivityType {
  application,
  website,
  file,
  idle,
  meeting,
  break_,
  system
}

enum ProductivityCategory {
  productive,
  neutral,
  distracting,
  personal,
  unknown
}

class ActivitySession extends Equatable {
  final String id;
  final String userId;
  final String deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final ActivityType type;
  final ProductivityCategory category;
  final String title;
  final String? description;
  final String? applicationName;
  final String? websiteUrl;
  final String? filePath;
  final Map<String, dynamic> metadata;
  final List<ActivityEvent> events;
  final bool isIdle;
  final Location? location;
  final double? productivityScore;

  const ActivitySession({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.type,
    required this.category,
    required this.title,
    this.description,
    this.applicationName,
    this.websiteUrl,
    this.filePath,
    this.metadata = const {},
    this.events = const [],
    this.isIdle = false,
    this.location,
    this.productivityScore,
  });

  bool get isActive => endTime == null;
  
  Duration get actualDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  ActivitySession copyWith({
    String? id,
    String? userId,
    String? deviceId,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    ActivityType? type,
    ProductivityCategory? category,
    String? title,
    String? description,
    String? applicationName,
    String? websiteUrl,
    String? filePath,
    Map<String, dynamic>? metadata,
    List<ActivityEvent>? events,
    bool? isIdle,
    Location? location,
    double? productivityScore,
  }) {
    return ActivitySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      applicationName: applicationName ?? this.applicationName,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      filePath: filePath ?? this.filePath,
      metadata: metadata ?? this.metadata,
      events: events ?? this.events,
      isIdle: isIdle ?? this.isIdle,
      location: location ?? this.location,
      productivityScore: productivityScore ?? this.productivityScore,
    );
  }

  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      id: json['id'],
      userId: json['userId'],
      deviceId: json['deviceId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: Duration(seconds: json['duration'] ?? 0),
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ActivityType.application,
      ),
      category: ProductivityCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => ProductivityCategory.unknown,
      ),
      title: json['title'] ?? '',
      description: json['description'],
      applicationName: json['applicationName'],
      websiteUrl: json['websiteUrl'],
      filePath: json['filePath'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      events: [], // Simplified for now
      isIdle: json['isIdle'] ?? false,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      productivityScore: json['productivityScore']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        deviceId,
        startTime,
        endTime,
        duration,
        type,
        category,
        title,
        description,
        applicationName,
        websiteUrl,
        filePath,
        metadata,
        events,
        isIdle,
        location,
        productivityScore,
      ];
}

class ActivityEvent extends Equatable {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final String eventType; // 'keystroke', 'mouse_click', 'scroll', 'focus_change'
  final Map<String, dynamic> data;

  const ActivityEvent({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.eventType,
    this.data = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'timestamp': timestamp.toIso8601String(),
    'eventType': eventType,
    'data': data,
  };

  @override
  List<Object?> get props => [id, sessionId, timestamp, eventType, data];
}

class Screenshot extends Equatable {
  final String id;
  final String sessionId;
  final String userId;
  final DateTime timestamp;
  final String filePath;
  final String? thumbnailPath;
  final int fileSize;
  final Map<String, dynamic> metadata;
  final bool isEncrypted;
  final String? encryptionKey;
  final PrivacyLevel privacyLevel;

  const Screenshot({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.timestamp,
    required this.filePath,
    this.thumbnailPath,
    required this.fileSize,
    this.metadata = const {},
    this.isEncrypted = true,
    this.encryptionKey,
    this.privacyLevel = PrivacyLevel.standard,
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        userId,
        timestamp,
        filePath,
        thumbnailPath,
        fileSize,
        metadata,
        isEncrypted,
        encryptionKey,
        privacyLevel,
      ];
}

enum PrivacyLevel {
  public,
  standard,
  sensitive,
  confidential
}

class Location extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? address;
  final String? city;
  final String? country;
  final DateTime timestamp;

  const Location({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.address,
    this.city,
    this.country,
    required this.timestamp,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      address: json['address'],
      city: json['city'],
      country: json['country'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracy,
        address,
        city,
        country,
        timestamp,
      ];
}