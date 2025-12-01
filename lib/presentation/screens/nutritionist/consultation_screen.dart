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
  List<Consultation> _consultations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchConsultations();
  }

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
      if (nutritionistId == null || nutritionistId.isEmpty)
        throw Exception("User not logged in.");

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

  Future<void> _updateConsultationStatus(String id, String status) async {
    try {
      await NutritionistProvider.updateConsultationStatus(id, status);
      if (!mounted) return;
      _fetchConsultations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked as $status'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showDeleteConsultationDialog(Consultation consultation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Consultation'),
        content: Text('Delete session with ${consultation.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await NutritionistProvider.deleteConsultation(consultation.cid);
                if (!mounted) return;
                _fetchConsultations();
              } catch (e) {
                // handle error
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddConsultationDialog() async {
    final bool? added = await showDialog<bool>(
      context: context,
      builder: (context) => const ScheduleConsultationDialog(),
    );
    if (added == true) _fetchConsultations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddConsultationDialog,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: const [
                Text(
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
    if (_isLoading)
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    if (_error != null) return Center(child: Text('Error: $_error'));
    if (_consultations.isEmpty)
      return Center(
        child: Text(
          'No consultations.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _consultations.length,
      itemBuilder: (context, index) {
        return _buildConsultationCard(_consultations[index]);
      },
    );
  }

  Widget _buildConsultationCard(Consultation consultation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      consultation.status,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    consultation.status,
                    style: TextStyle(
                      color: _getStatusColor(consultation.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.blue[800]),
                const SizedBox(width: 6),
                Text(
                  '${_formatDate(consultation.date)} at ${_formatTime(consultation.date)}',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  consultation.type,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                if (consultation.status == 'Scheduled')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateConsultationStatus(
                        consultation.cid,
                        'In Progress',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (consultation.status == 'In Progress')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateConsultationStatus(
                        consultation.cid,
                        'Completed',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (consultation.status == 'Scheduled' ||
                    consultation.status == 'In Progress')
                  const SizedBox(width: 8),

                SizedBox(
                  width: 80,
                  child: OutlinedButton(
                    onPressed: () =>
                        _showDeleteConsultationDialog(consultation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(color: Colors.red[200]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.delete, size: 18),
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
      default:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  String _formatTime(DateTime date) =>
      '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

class ScheduleConsultationDialog extends StatefulWidget {
  const ScheduleConsultationDialog({super.key});

  @override
  State<ScheduleConsultationDialog> createState() =>
      _ScheduleConsultationDialogState();
}

class _ScheduleConsultationDialogState
    extends State<ScheduleConsultationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  List<Client> _clients = [];
  String? _selectedClientId;
  String? _selectedClientName;
  DateTime? _selectedDateTime;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    final uid = Provider.of<AuthProvider>(context, listen: false).uid;
    if (uid != null) {
      final data = await NutritionistProvider.fetchClientsByNutritionId(uid);
      if (mounted)
        setState(() {
          _clients = data;
          _loading = false;
        });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) return;

    try {
      final uid = Provider.of<AuthProvider>(context, listen: false).uid!;
      final consultation = Consultation(
        cid: DateTime.now().millisecondsSinceEpoch.toString(),
        nutritionistId: uid,
        clientId: _selectedClientId!,
        clientName: _selectedClientName!,
        date: _selectedDateTime!,
        status: 'Scheduled',
        type: _typeController.text,
      );
      await NutritionistProvider.addConsultation(consultation);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _loading
                ? const CircularProgressIndicator()
                : DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: 'Client',
                      border: OutlineInputBorder(),
                    ),
                    items: _clients
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.cid,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedClientId = v as String;
                        _selectedClientName = _clients
                            .firstWhere((c) => c.cid == v)
                            .name;
                      });
                    },
                  ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                _selectedDateTime == null
                    ? 'Select Date'
                    : '${_selectedDateTime!.day}/${_selectedDateTime!.month} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute}',
              ),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null)
                    setState(
                      () => _selectedDateTime = DateTime(
                        d.year,
                        d.month,
                        d.day,
                        t.hour,
                        t.minute,
                      ),
                    );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
          child: const Text('Schedule', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
