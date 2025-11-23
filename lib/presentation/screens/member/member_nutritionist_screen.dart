// lib/presentation/screens/member/member_nutritionist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/member_provider.dart';

class MemberNutritionistScreen extends StatefulWidget {
  const MemberNutritionistScreen({super.key});

  @override
  State<MemberNutritionistScreen> createState() =>
      _MemberNutritionistScreenState();
}

class _MemberNutritionistScreenState extends State<MemberNutritionistScreen> {
  // List of Map<String, dynamic> because we haven't made a specific Nutritionist Profile model yet
  List<Map<String, dynamic>> _nutritionists = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNutritionists();
  }

  Future<void> _fetchNutritionists() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await MemberProvider.fetchAllNutritionists();
      if (!mounted) return;
      setState(() {
        _nutritionists = data;
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

  void _showBookingDialog(Map<String, dynamic> nutritionist) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Book with ${nutritionist['name']}'),
        content: const Text('Select a date for your consultation:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _processBooking(nutritionist);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text(
              'Pick Date',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processBooking(Map<String, dynamic> nutritionist) async {
    // 1. Pick Date
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (date == null) return;

    // 2. Pick Time
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (time == null) return;

    final DateTime fullDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // 3. Call Provider
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      await MemberProvider.bookConsultation(
        memberId: auth.uid!,
        memberName: auth.name ?? 'Member',
        nutritionistId: nutritionist['id'],
        date: fullDateTime,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation requested!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _nutritionists.isEmpty
          ? const Center(child: Text('No nutritionists available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _nutritionists.length,
              itemBuilder: (context, index) {
                return _buildNutritionistCard(_nutritionists[index]);
              },
            ),
    );
  }

  Widget _buildNutritionistCard(Map<String, dynamic> nutritionist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nutritionist['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Nutritionist',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showBookingDialog(nutritionist),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text(
                  'Book Consultation',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
