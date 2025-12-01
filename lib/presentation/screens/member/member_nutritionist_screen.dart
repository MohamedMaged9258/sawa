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
        title: Text('Book with ${nutritionist['name'] ?? 'Nutritionist'}'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
            ), // Blue Button
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
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (date == null) return;

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

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      await MemberProvider.bookConsultation(
        memberId: auth.uid!,
        memberName: auth.name ?? 'Member',
        nutritionistId: nutritionist['id'],
        nutritionistName:
            nutritionist['name'] ?? 'N',
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
      // ... (Error handling)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[800]))
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
    final String name = nutritionist['name'] ?? 'No Name';
    final String? photoUrl = nutritionist['photo'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blue[50], // Blue BG
              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : null,
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.blue[300],
                    ) // Blue Icon
                  : null,
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Forced Black Text
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Certified Nutritionist',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () => _showBookingDialog(nutritionist),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800], // Blue Button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Book', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
