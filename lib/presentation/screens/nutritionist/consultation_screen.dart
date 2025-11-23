// lib/presentation/screens/nutritionist/consultation_screen.dart

// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/nutritionist_provider.dart';
import 'package:sawa/presentation/models/nutritionist_models.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  // State for data management
  List<Consultation> _consultations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchConsultations();
  }

  // --- DATA FETCHING ---
  Future<void> _fetchConsultations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final nutritionistId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).uid;
      if (nutritionistId == null || nutritionistId.isEmpty) {
        throw Exception("User not logged in.");
      }

      // NOTE: Using fetchConsultationsByNutritionist, assuming the provider maps to the correct database column.
      final fetchedConsultations =
          await NutritionistProvider.fetchConsultationsByNutritionist(
            nutritionistId,
          );

      if (!mounted) return;
      setState(() {
        _consultations = fetchedConsultations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // --- STATUS & ACTION LOGIC ---

  Future<void> _updateConsultationStatus(String id, String status) async {
    try {
      await NutritionistProvider.updateConsultationStatus(id, status);

      if (!mounted) return;
      _fetchConsultations();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consultation marked as $status!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startConsultation(Consultation consultation) async {
    try {
      // Set status to 'In Progress' immediately
      await NutritionistProvider.updateConsultationStatus(
        consultation.cid,
        'In Progress',
      );

      if (!mounted) return;
      _fetchConsultations();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation started (Status: In Progress)!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start consultation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConsultationDialog(Consultation consultation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Consultation'),
        content: Text(
          'Are you sure you want to delete the consultation with ${consultation.clientName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              try {
                // Assuming provider method uses CID for ID
                await NutritionistProvider.deleteConsultation(consultation.cid);

                if (!mounted) return;
                _fetchConsultations();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Consultation deleted.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddConsultationDialog() async {
    final bool? consultationAdded = await showDialog<bool>(
      context: context,
      builder: (context) => const ScheduleConsultationDialog(),
    );

    if (consultationAdded == true) {
      _fetchConsultations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddConsultationDialog,
        backgroundColor: Colors.purple[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              // REMOVED right-side button
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Consultations',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text('Error loading consultations: $_error'));
    }
    if (_consultations.isEmpty) {
      return const Center(child: Text('No consultations scheduled.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _consultations.length,
      itemBuilder: (context, index) {
        return _buildConsultationCard(_consultations[index]);
      },
    );
  }

  Widget _buildConsultationCard(Consultation consultation) {
    // Determine the main action button based on status
    Widget primaryActionButton;
    Widget separator = const SizedBox(width: 8);

    final bool showPrimaryAction =
        consultation.status == 'Scheduled' ||
        consultation.status == 'In Progress';

    if (consultation.status == 'Scheduled') {
      primaryActionButton = Expanded(
        child: ElevatedButton(
          onPressed: () => _startConsultation(consultation), // Start Now
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
          child: const Text('Start Now', style: TextStyle(color: Colors.white)),
        ),
      );
    } else if (consultation.status == 'In Progress') {
      primaryActionButton = Expanded(
        child: ElevatedButton(
          onPressed: () =>
              _updateConsultationStatus(consultation.cid, 'Completed'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
          child: const Text(
            'Mark Complete',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      // If status is Completed or Cancelled
      primaryActionButton = const SizedBox.shrink();
      separator = const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  consultation.clientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      consultation.status,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(consultation.status),
                    ),
                  ),
                  child: Text(
                    consultation.status,
                    style: TextStyle(
                      color: _getStatusColor(consultation.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Type: ${consultation.type}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(consultation.date)}'),
            const SizedBox(height: 8),
            Text('Time: ${_formatTime(consultation.date)}'),
            const SizedBox(height: 12),

            // --- ACTION BUTTONS ROW ---
            Row(
              children: [
                // 1. PRIMARY ACTION (Shown only for Scheduled/In Progress)
                if (showPrimaryAction) primaryActionButton,
                if (showPrimaryAction) separator,

                // 2. ALWAYS AVAILABLE DELETE BUTTON (Fixed width and position)
                SizedBox(
                  width: 100,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: const Text('Delete'),
                    onPressed: () =>
                        _showDeleteConsultationDialog(consultation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// --- ScheduleConsultationDialog Class ---
class ScheduleConsultationDialog extends StatefulWidget {
  const ScheduleConsultationDialog({super.key});

  @override
  State<ScheduleConsultationDialog> createState() =>
      _ScheduleConsultationDialogState();
}

class _ScheduleConsultationDialogState
    extends State<ScheduleConsultationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _typeController = TextEditingController();

  List<Client> _availableClients = [];
  bool _isLoadingClients = true;
  String? _selectedClientId;
  String? _selectedClientName;

  DateTime? _selectedDateTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    try {
      final nutritionistId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).uid;
      if (nutritionistId != null) {
        final clients = await NutritionistProvider.fetchClientsByNutritionId(
          nutritionistId,
        );
        if (mounted) {
          setState(() {
            _availableClients = clients;
            _isLoadingClients = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingClients = false;
        });
        print('Error fetching clients for consultation: $e');
      }
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitConsultation() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedDateTime == null
                ? 'Please select a date and time.'
                : 'Please fill all fields.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final nutritionistId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).uid!;

      final newConsultation = Consultation(
        cid: DateTime.now().millisecondsSinceEpoch.toString(),
        nutritionistId: nutritionistId,
        clientId: _selectedClientId!,
        clientName: _selectedClientName!,
        date: _selectedDateTime!,
        status: 'Scheduled',
        type: _typeController.text,
      );

      await NutritionistProvider.addConsultation(newConsultation);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation scheduled successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Pop with 'true' to indicate success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to schedule: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule New Consultation'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Client Selection Dropdown
              _isLoadingClients
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Client',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableClients.map((client) {
                        return DropdownMenuItem<String>(
                          value: client.cid,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (String? newId) {
                        setState(() {
                          _selectedClientId = newId;
                          _selectedClientName = _availableClients
                              .firstWhere((c) => c.cid == newId)
                              .name;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select a client' : null,
                    ),
              const SizedBox(height: 16),

              // Consultation Type
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Consultation Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Enter type (e.g., Follow-up)' : null,
              ),
              const SizedBox(height: 16),

              // Date & Time Picker Button
              ElevatedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _selectedDateTime == null
                      ? 'Select Date & Time'
                      : 'Scheduled: ${_formatDateTime(_selectedDateTime!)}',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitConsultation,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Schedule', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
