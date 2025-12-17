import 'package:cloud_firestore/cloud_firestore.dart';

class ToothRecord {
  final int toothNumber; // 1-32 (adult teeth numbering)
  final List<TreatmentHistory> treatments;
  final String? currentCondition;
  final String? notes;

  ToothRecord({
    required this.toothNumber,
    this.treatments = const [],
    this.currentCondition,
    this.notes,
  });

  factory ToothRecord.fromMap(Map<String, dynamic> data) {
    return ToothRecord(
      toothNumber: data['toothNumber'] ?? 0,
      treatments: (data['treatments'] as List<dynamic>?)
              ?.map((t) => TreatmentHistory.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      currentCondition: data['currentCondition'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toothNumber': toothNumber,
      'treatments': treatments.map((t) => t.toMap()).toList(),
      'currentCondition': currentCondition,
      'notes': notes,
    };
  }
}

class TreatmentHistory {
  final String treatmentType;
  final DateTime date;
  final String dentistId;
  final String dentistName;
  final String? notes;
  final double? cost;

  TreatmentHistory({
    required this.treatmentType,
    required this.date,
    required this.dentistId,
    required this.dentistName,
    this.notes,
    this.cost,
  });

  factory TreatmentHistory.fromMap(Map<String, dynamic> data) {
    return TreatmentHistory(
      treatmentType: data['treatmentType'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      dentistId: data['dentistId'] ?? '',
      dentistName: data['dentistName'] ?? '',
      notes: data['notes'],
      cost: data['cost']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'treatmentType': treatmentType,
      'date': Timestamp.fromDate(date),
      'dentistId': dentistId,
      'dentistName': dentistName,
      'notes': notes,
      'cost': cost,
    };
  }
}

class DentalRecord {
  final String id;
  final String patientId;
  final List<ToothRecord> teeth;
  final DateTime lastUpdated;
  final String? xrayUrl;
  final List<String>? imageUrls;

  DentalRecord({
    required this.id,
    required this.patientId,
    this.teeth = const [],
    required this.lastUpdated,
    this.xrayUrl,
    this.imageUrls,
  });

  factory DentalRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DentalRecord(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      teeth: (data['teeth'] as List<dynamic>?)
              ?.map((t) => ToothRecord.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      xrayUrl: data['xrayUrl'],
      imageUrls: data['imageUrls'] != null
          ? List<String>.from(data['imageUrls'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'teeth': teeth.map((t) => t.toMap()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'xrayUrl': xrayUrl,
      'imageUrls': imageUrls,
    };
  }
}
