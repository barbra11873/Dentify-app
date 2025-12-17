enum UserRole {
  patient,
  dentist,
  receptionist,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.dentist:
        return 'Dentist';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'patient':
        return UserRole.patient;
      case 'dentist':
        return UserRole.dentist;
      case 'receptionist':
        return UserRole.receptionist;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.patient;
    }
  }
}
