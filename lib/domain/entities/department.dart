import 'package:equatable/equatable.dart';

class Department extends Equatable {
  final String id;
  final String companyId;
  final String organizationId;
  final String name;
  final String? description;
  final String? managerId;
  final String? parentDepartmentId;
  final String? costCenter;
  final double? budget;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Department({
    required this.id,
    required this.companyId,
    required this.organizationId,
    required this.name,
    this.description,
    this.managerId,
    this.parentDepartmentId,
    this.costCenter,
    this.budget,
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  Department copyWith({
    String? id,
    String? companyId,
    String? organizationId,
    String? name,
    String? description,
    String? managerId,
    String? parentDepartmentId,
    String? costCenter,
    double? budget,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Department(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      description: description ?? this.description,
      managerId: managerId ?? this.managerId,
      parentDepartmentId: parentDepartmentId ?? this.parentDepartmentId,
      costCenter: costCenter ?? this.costCenter,
      budget: budget ?? this.budget,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      companyId: json['companyId'],
      organizationId: json['organizationId'],
      name: json['name'],
      description: json['description'],
      managerId: json['managerId'],
      parentDepartmentId: json['parentDepartmentId'],
      costCenter: json['costCenter'],
      budget: json['budget']?.toDouble(),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'organizationId': organizationId,
      'name': name,
      'description': description,
      'managerId': managerId,
      'parentDepartmentId': parentDepartmentId,
      'costCenter': costCenter,
      'budget': budget,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        organizationId,
        name,
        description,
        managerId,
        parentDepartmentId,
        costCenter,
        budget,
        settings,
        createdAt,
        updatedAt,
        isActive,
      ];
}
