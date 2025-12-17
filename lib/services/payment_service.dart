import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'payments';

  // Create payment
  Future<String> createPayment(Payment payment) async {
    try {
      final docRef = await _firestore.collection(_collection).add(payment.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Get payments for patient
  Stream<List<Payment>> getPatientPayments(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList());
  }

  // Get pending payments for patient
  Stream<List<Payment>> getPendingPayments(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: PaymentStatus.pending.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList());
  }

  // Get all payments (for admin/receptionist)
  Stream<List<Payment>> getAllPayments() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList());
  }

  // Record payment
  Future<void> recordPayment({
    required String paymentId,
    required double amount,
    required PaymentMethod method,
    String? mpesaTransactionId,
  }) async {
    try {
      final paymentDoc = await _firestore.collection(_collection).doc(paymentId).get();
      final payment = Payment.fromFirestore(paymentDoc);
      
      final newAmountPaid = payment.amountPaid + amount;
      final newStatus = newAmountPaid >= payment.amount
          ? PaymentStatus.paid
          : PaymentStatus.partiallyPaid;

      await _firestore.collection(_collection).doc(paymentId).update({
        'amountPaid': newAmountPaid,
        'status': newStatus.toString().split('.').last,
        'method': method.toString().split('.').last,
        'mpesaTransactionId': mpesaTransactionId,
        if (newStatus == PaymentStatus.paid) 'paidAt': Timestamp.fromDate(DateTime.now()),
        if (newStatus == PaymentStatus.paid)
          'receiptNumber': 'RCP${DateTime.now().millisecondsSinceEpoch}',
      });
    } catch (e) {
      throw Exception('Failed to record payment: $e');
    }
  }

  // Initiate M-Pesa payment (stub - implement with actual M-Pesa API)
  Future<Map<String, dynamic>> initiateMpesaPayment({
    required String paymentId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      // TODO: Implement actual M-Pesa STK Push integration
      // This is a placeholder that simulates the API call
      
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate successful payment initiation
      return {
        'success': true,
        'message': 'Payment initiated successfully',
        'checkoutRequestId': 'ws_CO_${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      throw Exception('Failed to initiate M-Pesa payment: $e');
    }
  }

  // Generate receipt data
  Future<Map<String, dynamic>> getReceiptData(String paymentId) async {
    try {
      final paymentDoc = await _firestore.collection(_collection).doc(paymentId).get();
      final payment = Payment.fromFirestore(paymentDoc);

      return {
        'receiptNumber': payment.receiptNumber,
        'patientName': payment.patientName,
        'amount': payment.amount,
        'amountPaid': payment.amountPaid,
        'balance': payment.balance,
        'method': payment.method.toString().split('.').last,
        'paidAt': payment.paidAt,
        'description': payment.description,
      };
    } catch (e) {
      throw Exception('Failed to generate receipt: $e');
    }
  }

  // Get outstanding balance for patient
  Future<double> getOutstandingBalance(String patientId) async {
    try {
      final payments = await _firestore
          .collection(_collection)
          .where('patientId', isEqualTo: patientId)
          .where('status', whereIn: [
            PaymentStatus.pending.toString().split('.').last,
            PaymentStatus.partiallyPaid.toString().split('.').last,
          ])
          .get();

      double totalBalance = 0;
      for (var doc in payments.docs) {
        final payment = Payment.fromFirestore(doc);
        totalBalance += payment.balance;
      }

      return totalBalance;
    } catch (e) {
      throw Exception('Failed to get outstanding balance: $e');
    }
  }
}
