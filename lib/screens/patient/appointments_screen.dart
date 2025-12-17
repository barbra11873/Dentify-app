import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data!.docs;

          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments found'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index].data() as Map<String, dynamic>;
              final date = (appointment['date'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Appointment on ${date.toString()}'),
                  subtitle: Text('Status: ${appointment['status'] ?? 'Pending'}'),
                  trailing: Text(appointment['time'] ?? ''),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to book appointment screen
          _showBookAppointmentDialog(context, userId);
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBookAppointmentDialog(BuildContext context, String userId) {
    final _dateController = TextEditingController();
    final _timeController = TextEditingController();
    final _notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Book Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('appointments').add({
                    'patientId': userId,
                    'date': DateTime.parse(_dateController.text),
                    'time': _timeController.text,
                    'notes': _notesController.text,
                    'status': 'pending',
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment booked successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error booking appointment: $e')),
                  );
                }
              },
              child: const Text('Book'),
            ),
          ],
        );
      },
    );
  }
}