import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class UserModel {
  final String id;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isActive;
  
  // Role-specific fields
  final String? specialization; // For dentist
  final String? licenseNumber; // For dentist
  final List<String>? workingDays; // For dentist/receptionist
  final Map<String, dynamic>? workingHours; // For dentist/receptionist
  final String? emergencyContact; // For patient
  final DateTime? dateOfBirth; // For patient
  final String? address; // For patient
  final String? bloodGroup; // For patient
  final List<String>? allergies; // For patient
  final List<String>? medicalConditions; // For patient

  UserModel({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    this.isActive = true,
    this.specialization,
    this.licenseNumber,
    this.workingDays,
    this.workingHours,
    this.emergencyContact,
    this.dateOfBirth,
    this.address,
    this.bloodGroup,
    this.allergies,
    this.medicalConditions,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      fullName: data['fullName'] ?? '',
      role: UserRoleExtension.fromString(data['role'] ?? 'patient'),
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      specialization: data['specialization'],
      licenseNumber: data['licenseNumber'],
      workingDays: data['workingDays'] != null 
          ? List<String>.from(data['workingDays']) 
          : null,
      workingHours: data['workingHours'],
      emergencyContact: data['emergencyContact'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      address: data['address'],
      bloodGroup: data['bloodGroup'],
      allergies: data['allergies'] != null 
          ? List<String>.from(data['allergies']) 
          : null,
      medicalConditions: data['medicalConditions'] != null 
          ? List<String>.from(data['medicalConditions']) 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'role': role.value,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'emergencyContact': emergencyContact,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'address': address,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
    };
  }

  UserModel copyWith({
    String? email,
    String? phoneNumber,
    String? fullName,
    UserRole? role,
    String? profileImageUrl,
    bool? isActive,
    String? specialization,
    String? licenseNumber,
    List<String>? workingDays,
    Map<String, dynamic>? workingHours,
    String? emergencyContact,
    DateTime? dateOfBirth,
    String? address,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? medicalConditions,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
    );
  }
}
