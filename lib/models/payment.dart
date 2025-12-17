import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  pending,
  paid,
  partiallyPaid,
  cancelled,
}

enum PaymentMethod {
  cash,
  mpesa,
  card,
  insurance,
}

class Payment {
  final String id;
  final String patientId;
  final String patientName;
  final String? appointmentId;
  final double amount;
  final double amountPaid;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? mpesaTransactionId;
  final String? mpesaPhoneNumber;
  final String description;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? receiptNumber;

  Payment({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.appointmentId,
    required this.amount,
    this.amountPaid = 0,
    required this.status,
    required this.method,
    this.mpesaTransactionId,
    this.mpesaPhoneNumber,
    required this.description,
    required this.createdAt,
    this.paidAt,
    this.receiptNumber,
  });

  double get balance => amount - amountPaid;

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      appointmentId: data['appointmentId'],
      amount: (data['amount'] ?? 0).toDouble(),
      amountPaid: (data['amountPaid'] ?? 0).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${data['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${data['method']}',
        orElse: () => PaymentMethod.cash,
      ),
      mpesaTransactionId: data['mpesaTransactionId'],
      mpesaPhoneNumber: data['mpesaPhoneNumber'],
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      receiptNumber: data['receiptNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'appointmentId': appointmentId,
      'amount': amount,
      'amountPaid': amountPaid,
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'mpesaTransactionId': mpesaTransactionId,
      'mpesaPhoneNumber': mpesaPhoneNumber,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'receiptNumber': receiptNumber,
    };
  }
}
