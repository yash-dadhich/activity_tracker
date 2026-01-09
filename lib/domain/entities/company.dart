import 'package:equatable/equatable.dart';

class Company extends Equatable {
  final String id;
  final String organizationId;
  final String name;
  final String? description;
  final String? location;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? phone;
  final String? email;
  final String? industry;
  final String? size;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Company({
    required this.id,
    required this.organizationId,
    required this.name,
    this.description,
    this.location,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.phone,
    this.email,
    this.industry,
    this.size,
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  Company copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? description,
    String? location,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? phone,
    String? email,
    String? industry,
    String? size,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Company(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      industry: industry ?? this.industry,
      size: size ?? this.size,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      organizationId: json['organizationId'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      phone: json['phone'],
      email: json['email'],
      industry: json['industry'],
      size: json['size'],
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'description': description,
      'location': location,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'phone': phone,
      'email': email,
      'industry': industry,
      'size': size,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        organizationId,
        name,
        description,
        location,
        address,
        city,
        state,
        country,
        postalCode,
        phone,
        email,
        industry,
        size,
        settings,
        createdAt,
        updatedAt,
        isActive,
      ];
}
