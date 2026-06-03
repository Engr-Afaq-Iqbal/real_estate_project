import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String? cnic;
  final String? avatarUrl;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool isCnicVerified;
  final String? companyName;
  final String? pecNumber;
  final String city;
  final int projectCount;
  final int updatesCount;
  final double rating;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.cnic,
    this.avatarUrl,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.isCnicVerified = false,
    this.companyName,
    this.pecNumber,
    this.city = 'Lahore',
    this.projectCount = 0,
    this.updatesCount = 0,
    this.rating = 0.0,
    required this.createdAt,
  });

  bool get isHomeowner => role == 'homeowner';
  bool get isDeveloper => role == 'developer';
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        role: json['role'] as String,
        cnic: json['cnic'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isPhoneVerified: json['phone_verified'] as bool? ?? false,
        isEmailVerified: json['email_verified'] as bool? ?? false,
        isCnicVerified: json['cnic_verified'] as bool? ?? false,
        companyName: json['company_name'] as String?,
        pecNumber: json['pec_number'] as String?,
        city: json['city'] as String? ?? 'Lahore',
        projectCount: json['project_count'] as int? ?? 0,
        updatesCount: json['updates_count'] as int? ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'cnic': cnic,
        'avatar_url': avatarUrl,
        'phone_verified': isPhoneVerified,
        'email_verified': isEmailVerified,
        'cnic_verified': isCnicVerified,
        'company_name': companyName,
        'pec_number': pecNumber,
        'city': city,
        'project_count': projectCount,
        'updates_count': updatesCount,
        'rating': rating,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? cnic,
    String? avatarUrl,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    bool? isCnicVerified,
    String? companyName,
    String? pecNumber,
    String? city,
    int? projectCount,
    int? updatesCount,
    double? rating,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        role: role ?? this.role,
        cnic: cnic ?? this.cnic,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isCnicVerified: isCnicVerified ?? this.isCnicVerified,
        companyName: companyName ?? this.companyName,
        pecNumber: pecNumber ?? this.pecNumber,
        city: city ?? this.city,
        projectCount: projectCount ?? this.projectCount,
        updatesCount: updatesCount ?? this.updatesCount,
        rating: rating ?? this.rating,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, phone, role];
}
