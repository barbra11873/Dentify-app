import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get AI response based on user input
  Future<String> getResponse(String userMessage) async {
    final lowerMessage = userMessage.toLowerCase();

    // Appointment booking
    if (lowerMessage.contains('book') || lowerMessage.contains('appointment')) {
      return 'I can help you book an appointment! Would you like to:\n1. Book a new appointment\n2. View your upcoming appointments\n3. Reschedule an existing appointment';
    }

    // Service inquiries
    if (lowerMessage.contains('service') || lowerMessage.contains('treatment')) {
      return 'We offer various dental services including:\n• Teeth Cleaning\n• Cavity Filling\n• Root Canal\n• Teeth Whitening\n• Dental Crowns\n• Tooth Extraction\n• Orthodontics\n\nWhich service would you like to know more about?';
    }

    // Pricing
    if (lowerMessage.contains('price') || lowerMessage.contains('cost') || lowerMessage.contains('charge')) {
      return 'Our pricing varies by service:\n• Consultation: KES 1,000\n• Cleaning: KES 2,500\n• Filling: KES 3,500-5,000\n• Root Canal: KES 15,000-25,000\n• Whitening: KES 10,000\n\nFor exact pricing, please book a consultation.';
    }

    // Symptoms and emergencies
    if (lowerMessage.contains('pain') || lowerMessage.contains('hurt') || lowerMessage.contains('emergency')) {
      return 'I\'m sorry you\'re experiencing pain. For dental emergencies:\n• Severe tooth pain - rinse with warm salt water\n• Broken tooth - save any pieces, rinse mouth\n• Knocked out tooth - keep it moist, see dentist immediately\n\nWould you like to book an emergency appointment?';
    }

    // Tooth pain
    if (lowerMessage.contains('toothache')) {
      return 'For toothache relief:\n1. Rinse with warm salt water\n2. Use dental floss to remove trapped food\n3. Apply cold compress outside cheek\n4. Take OTC pain reliever\n\nIf pain persists, please book an appointment for proper diagnosis.';
    }

    // Aftercare
    if (lowerMessage.contains('after') || lowerMessage.contains('care')) {
      return 'Post-treatment care tips:\n• Avoid hot foods for 24 hours\n• Don\'t brush extraction site for 24 hours\n• Take prescribed medications\n• Avoid smoking and alcohol\n• Rest and elevate head while sleeping\n\nWhat specific treatment would you like aftercare info for?';
    }

    // Hours and location
    if (lowerMessage.contains('hour') || lowerMessage.contains('open') || lowerMessage.contains('location')) {
      return 'Our clinic hours:\nMonday-Friday: 8:00 AM - 6:00 PM\nSaturday: 9:00 AM - 2:00 PM\nSunday: Closed\n\nWe are a mobile dental clinic serving various locations. Please book an appointment to confirm availability in your area.';
    }

    // Insurance
    if (lowerMessage.contains('insurance')) {
      return 'We accept:\n• NHIF\n• Private insurance (AAR, Britam, CIC, etc.)\n• Corporate medical covers\n• Cash payments\n• M-Pesa payments\n\nPlease bring your insurance card during your visit.';
    }

    // Teeth whitening
    if (lowerMessage.contains('whitening') || lowerMessage.contains('white teeth')) {
      return 'Teeth Whitening Service:\n• Professional in-office whitening\n• Results in one visit\n• Safe and effective\n• Cost: KES 10,000\n• Duration: 60-90 minutes\n\nWould you like to book a whitening session?';
    }

    // Cleaning
    if (lowerMessage.contains('clean')) {
      return 'Professional teeth cleaning includes:\n• Plaque and tartar removal\n• Polishing\n• Fluoride treatment\n• Oral hygiene guidance\n\nRecommended every 6 months\nCost: KES 2,500\n\nShall I help you schedule a cleaning appointment?';
    }

    // Root canal
    if (lowerMessage.contains('root canal')) {
      return 'Root Canal Treatment:\n• Saves severely infected/damaged teeth\n• Usually requires 2-3 visits\n• Cost: KES 15,000-25,000\n• Modern pain-free techniques\n\nWould you like to consult with our dentist?';
    }

    // Greeting
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
      return 'Hello! 👋 Welcome to Dentify, your mobile dental clinic assistant. How can I help you today?\n\nI can assist with:\n• Booking appointments\n• Service information\n• Pricing inquiries\n• Dental advice\n• Emergency guidance';
    }

    // Thank you
    if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help you with today? 😊';
    }

    // Default response
    return 'I\'m here to help! I can assist you with:\n• Booking appointments\n• Information about our dental services\n• Pricing and insurance\n• Dental care tips\n• Emergency guidance\n\nWhat would you like to know?';
  }

  // Save chat history
  Future<void> saveChatHistory({
    required String userId,
    required List<ChatMessage> messages,
  }) async {
    try {
      final chatData = {
        'userId': userId,
        'messages': messages.map((msg) => {
          'text': msg.text,
          'isUser': msg.isUser,
          'timestamp': Timestamp.fromDate(msg.timestamp),
        }).toList(),
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore.collection('chatHistory').doc(userId).set(chatData);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  // Load chat history
  Future<List<ChatMessage>> loadChatHistory(String userId) async {
    try {
      final doc = await _firestore.collection('chatHistory').doc(userId).get();
      if (!doc.exists) return [];

      final data = doc.data()!;
      final messagesData = data['messages'] as List<dynamic>;

      return messagesData.map((msg) => ChatMessage(
        text: msg['text'],
        isUser: msg['isUser'],
        timestamp: (msg['timestamp'] as Timestamp).toDate(),
      )).toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }
}
