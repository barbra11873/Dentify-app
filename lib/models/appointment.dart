import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }
}

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String dentistId;
  final String dentistName;
  final DateTime dateTime;
  final int durationMinutes;
  final String serviceType;
  final AppointmentStatus status;
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? completedAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.dentistId,
    required this.dentistName,
    required this.dateTime,
    this.durationMinutes = 30,
    required this.serviceType,
    required this.status,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    this.completedAt,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      dentistId: data['dentistId'] ?? '',
      dentistName: data['dentistName'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 30,
      serviceType: data['serviceType'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.${data['status']}',
        orElse: () => AppointmentStatus.scheduled,
      ),
      notes: data['notes'],
      cancellationReason: data['cancellationReason'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'dentistId': dentistId,
      'dentistName': dentistName,
      'dateTime': Timestamp.fromDate(dateTime),
      'durationMinutes': durationMinutes,
      'serviceType': serviceType,
      'status': status.toString().split('.').last,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
