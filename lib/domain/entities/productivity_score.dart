import 'package:equatable/equatable.dart';

class ProductivityScore extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final double overallScore;
  final Map<String, double> categoryScores;
  final Map<String, Duration> timeDistribution;
  final List<ProductivityInsight> insights;
  final ProductivityTrend trend;
  final Map<String, dynamic> metadata;

  const ProductivityScore({
    required this.id,
    required this.userId,
    required this.date,
    required this.overallScore,
    required this.categoryScores,
    required this.timeDistribution,
    required this.insights,
    required this.trend,
    this.metadata = const {},
  });

  double get productivePercentage {
    final productiveTime = timeDistribution['productive'] ?? Duration.zero;
    final totalTime = timeDistribution.values.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );
    
    if (totalTime.inMilliseconds == 0) return 0.0;
    return (productiveTime.inMilliseconds / totalTime.inMilliseconds) * 100;
  }

  double get distractingPercentage {
    final distractingTime = timeDistribution['distracting'] ?? Duration.zero;
    final totalTime = timeDistribution.values.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );
    
    if (totalTime.inMilliseconds == 0) return 0.0;
    return (distractingTime.inMilliseconds / totalTime.inMilliseconds) * 100;
  }

  ProductivityLevel get level {
    if (overallScore >= 0.8) return ProductivityLevel.excellent;
    if (overallScore >= 0.6) return ProductivityLevel.good;
    if (overallScore >= 0.4) return ProductivityLevel.average;
    if (overallScore >= 0.2) return ProductivityLevel.poor;
    return ProductivityLevel.veryPoor;
  }

  factory ProductivityScore.fromJson(Map<String, dynamic> json) {
    return ProductivityScore(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      overallScore: json['overallScore'].toDouble(),
      categoryScores: Map<String, double>.from(
        json['categoryScores']?.map((k, v) => MapEntry(k, v.toDouble())) ?? {},
      ),
      timeDistribution: Map<String, Duration>.from(
        json['timeDistribution']?.map((k, v) => MapEntry(k, Duration(seconds: v))) ?? {},
      ),
      insights: [], // Simplified for now
      trend: ProductivityTrend.fromJson(json['trend'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        overallScore,
        categoryScores,
        timeDistribution,
        insights,
        trend,
        metadata,
      ];
}

enum ProductivityLevel {
  excellent,
  good,
  average,
  poor,
  veryPoor
}

class ProductivityInsight extends Equatable {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final double impact; // -1.0 to 1.0
  final List<String> recommendations;
  final Map<String, dynamic> data;
  final DateTime generatedAt;

  const ProductivityInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.impact,
    required this.recommendations,
    this.data = const {},
    required this.generatedAt,
  });

  bool get isPositive => impact > 0;
  bool get isNegative => impact < 0;
  bool get isNeutral => impact == 0;

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        impact,
        recommendations,
        data,
        generatedAt,
      ];
}

enum InsightType {
  timeManagement,
  focusPattern,
  distractionAlert,
  productivityTip,
  behaviorChange,
  goalProgress,
  teamComparison,
  anomalyDetection
}

class ProductivityTrend extends Equatable {
  final TrendDirection direction;
  final double changePercentage;
  final Duration period;
  final List<TrendDataPoint> dataPoints;
  final String? description;

  const ProductivityTrend({
    required this.direction,
    required this.changePercentage,
    required this.period,
    required this.dataPoints,
    this.description,
  });

  bool get isImproving => direction == TrendDirection.up;
  bool get isDeclining => direction == TrendDirection.down;
  bool get isStable => direction == TrendDirection.stable;

  factory ProductivityTrend.fromJson(Map<String, dynamic> json) {
    return ProductivityTrend(
      direction: TrendDirection.values.firstWhere(
        (e) => e.toString().split('.').last == json['direction'],
        orElse: () => TrendDirection.stable,
      ),
      changePercentage: json['changePercentage']?.toDouble() ?? 0.0,
      period: Duration(days: json['period'] ?? 7),
      dataPoints: [], // Simplified for now
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [
        direction,
        changePercentage,
        period,
        dataPoints,
        description,
      ];
}

enum TrendDirection {
  up,
  down,
  stable
}

class TrendDataPoint extends Equatable {
  final DateTime date;
  final double value;
  final Map<String, dynamic> metadata;

  const TrendDataPoint({
    required this.date,
    required this.value,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [date, value, metadata];
}

class ProductivityGoal extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalType type;
  final double targetValue;
  final double currentValue;
  final DateTime startDate;
  final DateTime endDate;
  final GoalStatus status;
  final List<String> milestones;
  final Map<String, dynamic> metadata;

  const ProductivityGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.milestones = const [],
    this.metadata = const {},
  });

  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0) * 100;
  }

  bool get isCompleted => status == GoalStatus.completed;
  bool get isActive => status == GoalStatus.active;
  bool get isOverdue => DateTime.now().isAfter(endDate) && !isCompleted;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        type,
        targetValue,
        currentValue,
        startDate,
        endDate,
        status,
        milestones,
        metadata,
      ];
}

enum GoalType {
  productivityScore,
  focusTime,
  distractionReduction,
  taskCompletion,
  timeManagement,
  custom
}

enum GoalStatus {
  draft,
  active,
  paused,
  completed,
  cancelled
}