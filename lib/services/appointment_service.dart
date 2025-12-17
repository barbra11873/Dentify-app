import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  // Create appointment
  Future<String> createAppointment(Appointment appointment) async {
    try {
      final docRef = await _firestore.collection(_collection).add(appointment.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Get appointments for patient
  Stream<List<Appointment>> getPatientAppointments(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
  }

  // Get appointments for dentist
  Stream<List<Appointment>> getDentistAppointments(String dentistId) {
    return _firestore
        .collection(_collection)
        .where('dentistId', isEqualTo: dentistId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
  }

  // Get today's appointments for dentist
  Stream<List<Appointment>> getTodayAppointments(String dentistId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection(_collection)
        .where('dentistId', isEqualTo: dentistId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
  }

  // Get all appointments (for receptionist/admin)
  Stream<List<Appointment>> getAllAppointments() {
    return _firestore
        .collection(_collection)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(
      String appointmentId, AppointmentStatus status) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).update({
        'status': status.toString().split('.').last,
        if (status == AppointmentStatus.completed)
          'completedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(
      String appointmentId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).update({
        'status': AppointmentStatus.cancelled.toString().split('.').last,
        'cancellationReason': reason,
      });
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  // Reschedule appointment
  Future<void> rescheduleAppointment(
      String appointmentId, DateTime newDateTime) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).update({
        'dateTime': Timestamp.fromDate(newDateTime),
        'status': AppointmentStatus.scheduled.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to reschedule appointment: $e');
    }
  }

  // Check availability
  Future<List<DateTime>> getAvailableSlots(
      String dentistId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 8, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 18, 0);

    final bookedAppointments = await _firestore
        .collection(_collection)
        .where('dentistId', isEqualTo: dentistId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('status', whereIn: [
          AppointmentStatus.scheduled.toString().split('.').last,
          AppointmentStatus.confirmed.toString().split('.').last,
        ])
        .get();

    final bookedTimes = bookedAppointments.docs
        .map((doc) => (doc.data()['dateTime'] as Timestamp).toDate())
        .toList();

    final availableSlots = <DateTime>[];
    var currentTime = startOfDay;

    while (currentTime.isBefore(endOfDay)) {
      final isBooked = bookedTimes.any((bookedTime) =>
          bookedTime.hour == currentTime.hour &&
          bookedTime.minute == currentTime.minute);

      if (!isBooked && currentTime.isAfter(DateTime.now())) {
        availableSlots.add(currentTime);
      }

      currentTime = currentTime.add(const Duration(minutes: 30));
    }

    return availableSlots;
  }

  // Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }
}
