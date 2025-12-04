enum UserType {
  admin,
  merchandiser,
  customer;

  static UserType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'admin':
        return UserType.admin;
      case 'merchandiser':
        return UserType.merchandiser;
      case 'customer':
        return UserType.customer;
      default:
        throw ArgumentError('Unknown user type: $type');
    }
  }

  String get displayName {
    switch (this) {
      case UserType.admin:
        return 'Admin';
      case UserType.merchandiser:
        return 'Merchandiser';
      case UserType.customer:
        return 'Customer';
    }
  }
}

class User {
  final String id;
  final String? email;
  final String? fullName;
  final UserType userType;
  final String? token;
  final bool mustChangePassword;
  final bool isActive;

  const User({
    required this.id,
    this.email,
    this.fullName,
    required this.userType,
    this.token,
    this.mustChangePassword = false,
    this.isActive = true,
  });
}
