// lib/presentation/screens/nutritionist/consultation_screen.dart
import 'package:flutter/material.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final List<Consultation> _consultations = [
    Consultation(
      id: '1',
      clientName: 'John Doe',
      date: DateTime.now().add(const Duration(days: 1)),
      status: 'Scheduled',
      type: 'Initial Assessment',
    ),
    Consultation(
      id: '2',
      clientName: 'Sarah Smith',
      date: DateTime.now().add(const Duration(days: 2)),
      status: 'Scheduled',
      type: 'Follow-up',
    ),
    Consultation(
      id: '3',
      clientName: 'Mike Johnson',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Completed',
      type: 'Progress Review',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Consultations',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'New Consultation',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _showAddConsultationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _consultations.length,
              itemBuilder: (context, index) {
                return _buildConsultationCard(_consultations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(Consultation consultation) {
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
            if (consultation.status == 'Scheduled')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _updateConsultationStatus(consultation.id, 'Completed');
                      },
                      child: const Text('Mark Complete'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Start consultation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                      ),
                      child: const Text(
                        'Start Now',
                        style: TextStyle(color: Colors.white),
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

  void _updateConsultationStatus(String id, String status) {
    setState(() {
      final consultation = _consultations.firstWhere((c) => c.id == id);
      consultation.status = status;
    });
  }

  void _showAddConsultationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule New Consultation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Client Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Consultation Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Date picker implementation
              },
              child: const Text('Select Date & Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Consultation scheduled successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
            ),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}

class Consultation {
  String id;
  String clientName;
  DateTime date;
  String status;
  String type;

  Consultation({
    required this.id,
    required this.clientName,
    required this.date,
    required this.status,
    required this.type,
  });
}
