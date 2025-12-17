import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment.dart';
import '../../models/user_model.dart';
import '../../models/user_role.dart';
import '../../models/dental_service.dart';
import '../../services/appointment_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _currentStep = 0;
  DentalService? _selectedService;
  UserModel? _selectedDentist;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  
  bool _isLoading = false;
  List<DentalService> _services = [];
  List<UserModel> _dentists = [];
  List<DateTime> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadDentists();
  }

  Future<void> _loadServices() async {
    try {
      final servicesSnapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();
      
      setState(() {
        _services = servicesSnapshot.docs
            .map((doc) => DentalService.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      // Use default services if none in database
      setState(() {
        _services = [
          DentalService(
            id: '1',
            name: 'Teeth Cleaning',
            description: 'Professional cleaning and plaque removal',
            price: 2500,
            durationMinutes: 30,
            category: 'Preventive',
          ),
          DentalService(
            id: '2',
            name: 'Cavity Filling',
            description: 'Tooth filling for cavities',
            price: 3500,
            durationMinutes: 45,
            category: 'Restorative',
          ),
          DentalService(
            id: '3',
            name: 'Teeth Whitening',
            description: 'Professional teeth whitening',
            price: 10000,
            durationMinutes: 60,
            category: 'Cosmetic',
          ),
          DentalService(
            id: '4',
            name: 'Root Canal',
            description: 'Root canal treatment',
            price: 15000,
            durationMinutes: 90,
            category: 'Endodontic',
          ),
          DentalService(
            id: '5',
            name: 'Tooth Extraction',
            description: 'Tooth removal',
            price: 5000,
            durationMinutes: 30,
            category: 'Surgical',
          ),
          DentalService(
            id: '6',
            name: 'Dental Consultation',
            description: 'General consultation and examination',
            price: 1000,
            durationMinutes: 30,
            category: 'Consultation',
          ),
        ];
      });
    }
  }

  Future<void> _loadDentists() async {
    try {
      final dentistsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'dentist')
          .where('isActive', isEqualTo: true)
          .get();
      
      setState(() {
        _dentists = dentistsSnapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error loading dentists: $e');
    }
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedDentist == null || _selectedDate == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final slots = await _appointmentService.getAvailableSlots(
        _selectedDentist!.id,
        _selectedDate!,
      );
      
      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading slots: $e')),
        );
      }
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedService == null ||
        _selectedDentist == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final appointment = Appointment(
        id: '',
        patientId: auth.user!.uid,
        patientName: auth.userModel!.fullName,
        dentistId: _selectedDentist!.id,
        dentistName: _selectedDentist!.fullName,
        dateTime: appointmentDateTime,
        durationMinutes: _selectedService!.durationMinutes,
        serviceType: _selectedService!.name,
        status: AppointmentStatus.scheduled,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _appointmentService.createAppointment(appointment);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking appointment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _services.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0 && _selectedService == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a service')),
                  );
                  return;
                }
                if (_currentStep == 1 && _selectedDentist == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a dentist')),
                  );
                  return;
                }
                if (_currentStep == 2 && _selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a date')),
                  );
                  return;
                }
                if (_currentStep == 2 && _selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a time')),
                  );
                  return;
                }
                
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                  if (_currentStep == 2) {
                    _loadAvailableSlots();
                  }
                } else {
                  _bookAppointment();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_currentStep == 3 ? 'Book' : 'Continue'),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Select Service'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                  content: _buildServiceSelection(),
                ),
                Step(
                  title: const Text('Choose Dentist'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                  content: _buildDentistSelection(),
                ),
                Step(
                  title: const Text('Pick Date & Time'),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                  content: _buildDateTimeSelection(),
                ),
                Step(
                  title: const Text('Confirm'),
                  isActive: _currentStep >= 3,
                  content: _buildConfirmation(),
                ),
              ],
            ),
    );
  }

  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _services.map((service) {
        final isSelected = _selectedService?.id == service.id;
        return Card(
          color: isSelected ? Colors.teal[50] : null,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.medical_services,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(
              service.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.description),
                const SizedBox(height: 4),
                Text(
                  'KES ${service.price.toStringAsFixed(0)} • ${service.durationMinutes} mins',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.teal)
                : null,
            onTap: () {
              setState(() => _selectedService = service);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDentistSelection() {
    if (_dentists.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('No dentists available at the moment'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDentist = UserModel(
                      id: 'default',
                      email: 'dentist@dentify.com',
                      fullName: 'Available Dentist',
                      role: UserRole.dentist,
                      createdAt: DateTime.now(),
                    );
                  });
                },
                child: const Text('Select Any Available Dentist'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _dentists.map((dentist) {
        final isSelected = _selectedDentist?.id == dentist.id;
        return Card(
          color: isSelected ? Colors.teal[50] : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.teal : Colors.grey[300],
              child: Icon(
                Icons.person,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(
              'Dr. ${dentist.fullName}',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(dentist.specialization ?? 'General Dentist'),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.teal)
                : null,
            onTap: () {
              setState(() {
                _selectedDentist = dentist;
                _selectedDate = null;
                _selectedTime = null;
                _availableSlots = [];
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selection
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.teal),
            title: const Text('Select Date'),
            subtitle: Text(
              _selectedDate == null
                  ? 'Tap to choose date'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _selectedTime = null;
                });
                _loadAvailableSlots();
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Time Selection
        if (_selectedDate != null) ...[
          const Text(
            'Available Time Slots',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_availableSlots.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No available slots for this date'),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSlots.map((slot) {
                final time = TimeOfDay.fromDateTime(slot);
                final isSelected = _selectedTime?.hour == time.hour &&
                    _selectedTime?.minute == time.minute;
                return ChoiceChip(
                  label: Text(time.format(context)),
                  selected: isSelected,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (selected) {
                    setState(() => _selectedTime = time);
                  },
                );
              }).toList(),
            ),
        ],
      ],
    );
  }

  Widget _buildConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Service', _selectedService?.name ?? ''),
                const Divider(),
                _buildInfoRow(
                  'Dentist',
                  'Dr. ${_selectedDentist?.fullName ?? ''}',
                ),
                const Divider(),
                _buildInfoRow(
                  'Date',
                  _selectedDate == null
                      ? ''
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
                const Divider(),
                _buildInfoRow(
                  'Time',
                  _selectedTime?.format(context) ?? '',
                ),
                const Divider(),
                _buildInfoRow(
                  'Duration',
                  '${_selectedService?.durationMinutes ?? 0} minutes',
                ),
                const Divider(),
                _buildInfoRow(
                  'Cost',
                  'KES ${_selectedService?.price.toStringAsFixed(0) ?? '0'}',
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Additional Notes (Optional)',
            hintText: 'Any special requirements or concerns...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
