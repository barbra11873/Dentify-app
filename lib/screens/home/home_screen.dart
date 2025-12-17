import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_role.dart';
import '../../widgets/app_logo.dart';
import '../patient/appointments_screen.dart';
import '../chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _patientScreens = <Widget>[
    const _PatientHomeContent(),
    const AppointmentsScreen(),
    const ChatbotScreen(),
    const Center(child: Text('Profile')),
  ];

  static const List<String> _patientTitles = [
    'Home',
    'Appointments',
    'Chatbot',
    'Profile',
  ];

  void _onPatientItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.role == UserRole.patient) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_patientTitles[_selectedIndex]),
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authProvider.signOut(),
            ),
          ],
        ),
        body: _patientScreens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chatbot',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.teal,
          onTap: _onPatientItemTapped,
        ),
      );
    } else if (authProvider.role == UserRole.dentist) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dentify - Dentist'),
          backgroundColor: Colors.teal,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: Text(
                  'Dentist Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Appointments'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to appointments
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Patients'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to patients
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Analytics'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to analytics
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  authProvider.signOut();
                },
              ),
            ],
          ),
        ),
        body: const Center(
          child: Text('Dentist Dashboard'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dentify'),
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authProvider.signOut(),
            ),
          ],
        ),
        body: const Center(
          child: Text('Unknown Role'),
        ),
      );
    }
  }
}

class _PatientHomeContent extends StatelessWidget {
  const _PatientHomeContent();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // App Logo
            const AppLogo(
              size: 150,
              showText: true,
            ),
            const SizedBox(height: 40),
            // Welcome message
            Text(
              'Welcome, ${authProvider.user?.displayName ?? "Patient"}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your dental health journey starts here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Quick actions
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.calendar_today,
                label: 'Book Appointment',
                color: Colors.teal,
                onTap: () {
                  // Navigate to appointments
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.chat_bubble_outline,
                label: 'Chat with AI',
                color: Colors.blue,
                onTap: () {
                  // Navigate to chatbot
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.camera_alt,
                label: 'Scan Teeth',
                color: Colors.orange,
                onTap: () {
                  // Navigate to scan
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.history,
                label: 'View History',
                color: Colors.purple,
                onTap: () {
                  // Navigate to history
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}