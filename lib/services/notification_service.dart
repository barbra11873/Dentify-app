import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final String _collection = 'notifications';

  // Initialize notifications
  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/logo');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      message.notification?.title ?? 'Dentify',
      message.notification?.body ?? '',
    );
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'dentify_channel',
      'Dentify Notifications',
      channelDescription: 'Notifications from Dentify app',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  // Create notification in Firestore
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore.collection(_collection).add(notification.toFirestore());
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Get user notifications
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final unreadNotifications = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Send appointment reminder
  Future<void> sendAppointmentReminder({
    required String userId,
    required String patientName,
    required DateTime appointmentTime,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: 'Appointment Reminder',
      message: 'You have an appointment scheduled for ${_formatDateTime(appointmentTime)}',
      type: NotificationType.appointment,
      createdAt: DateTime.now(),
    );

    await createNotification(notification);
  }

  // Send payment reminder
  Future<void> sendPaymentReminder({
    required String userId,
    required double amount,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: 'Payment Due',
      message: 'You have an outstanding balance of KES ${amount.toStringAsFixed(2)}',
      type: NotificationType.payment,
      createdAt: DateTime.now(),
    );

    await createNotification(notification);
  }

  // Send follow-up reminder
  Future<void> sendFollowUpReminder({
    required String userId,
    required String message,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: 'Follow-up Required',
      message: message,
      type: NotificationType.followUp,
      createdAt: DateTime.now(),
    );

    await createNotification(notification);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final unread = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return unread.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
