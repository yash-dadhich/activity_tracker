import 'package:equatable/equatable.dart';

class Organization extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? website;
  final String? industry;
  final String size; // small, medium, large, enterprise
  final String subscriptionPlan; // free, basic, professional, enterprise
  final String subscriptionStatus; // active, suspended, cancelled
  final DateTime? subscriptionExpiresAt;
  final int maxUsers;
  final int maxCompanies;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Organization({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.website,
    this.industry,
    required this.size,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
    this.subscriptionExpiresAt,
    required this.maxUsers,
    required this.maxCompanies,
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  Organization copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? website,
    String? industry,
    String? size,
    String? subscriptionPlan,
    String? subscriptionStatus,
    DateTime? subscriptionExpiresAt,
    int? maxUsers,
    int? maxCompanies,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      industry: industry ?? this.industry,
      size: size ?? this.size,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      maxUsers: maxUsers ?? this.maxUsers,
      maxCompanies: maxCompanies ?? this.maxCompanies,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      website: json['website'],
      industry: json['industry'],
      size: json['size'] ?? 'small',
      subscriptionPlan: json['subscriptionPlan'] ?? 'free',
      subscriptionStatus: json['subscriptionStatus'] ?? 'active',
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'])
          : null,
      maxUsers: json['maxUsers'] ?? 10,
      maxCompanies: json['maxCompanies'] ?? 1,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'website': website,
      'industry': industry,
      'size': size,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'maxUsers': maxUsers,
      'maxCompanies': maxCompanies,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        website,
        industry,
        size,
        subscriptionPlan,
        subscriptionStatus,
        subscriptionExpiresAt,
        maxUsers,
        maxCompanies,
        settings,
        createdAt,
        updatedAt,
        isActive,
      ];
}
