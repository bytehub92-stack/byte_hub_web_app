// lib/features/auth/data/models/user_model.dart
import 'package:admin_panel/features/shared/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    required super.userType,
    super.token,
    super.mustChangePassword,
    super.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        fullName: json['full_name'],
        userType: UserType.fromString(json['user_type'] ?? ''),
        token: json['token'],
        mustChangePassword: json['must_change_password'] ?? false,
        isActive: json['is_active'] ?? true,
      );
    } catch (e) {
      throw FormatException('Invalid user data format: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'user_type': userType.name,
      'token': token,
    };
  }
}
