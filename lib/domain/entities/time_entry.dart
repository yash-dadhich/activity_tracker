class TimeEntry {
  final String id;
  final String userId;
  final DateTime clockInTime;
  final DateTime? clockOutTime;
  final Duration? duration;
  final TimeEntryStatus status;
  final String? location;
  final String? deviceId;
  final String? ipAddress;
  final Map<String, dynamic> metadata;

  TimeEntry({
    required this.id,
    required this.userId,
    required this.clockInTime,
    this.clockOutTime,
    this.duration,
    required this.status,
    this.location,
    this.deviceId,
    this.ipAddress,
    this.metadata = const {},
  });

  bool get isActive => status == TimeEntryStatus.active;
  bool get isCompleted => status == TimeEntryStatus.completed;

  Duration get currentDuration {
    if (clockOutTime != null) {
      return duration ?? Duration.zero;
    }
    return DateTime.now().difference(clockInTime);
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      userId: json['userId'],
      clockInTime: DateTime.parse(json['clockInTime']),
      clockOutTime: json['clockOutTime'] != null
          ? DateTime.parse(json['clockOutTime'])
          : null,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : null,
      status: TimeEntryStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TimeEntryStatus.active,
      ),
      location: json['location'],
      deviceId: json['deviceId'],
      ipAddress: json['ipAddress'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'clockInTime': clockInTime.toIso8601String(),
      'clockOutTime': clockOutTime?.toIso8601String(),
      'duration': duration?.inSeconds,
      'status': status.toString().split('.').last,
      'location': location,
      'deviceId': deviceId,
      'ipAddress': ipAddress,
      'metadata': metadata,
    };
  }

  TimeEntry copyWith({
    String? id,
    String? userId,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    Duration? duration,
    TimeEntryStatus? status,
    String? location,
    String? deviceId,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      location: location ?? this.location,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum TimeEntryStatus {
  active,
  completed,
  cancelled,
}
