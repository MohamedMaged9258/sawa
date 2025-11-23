// lib/presentation/screens/member/member_gym_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/member_provider.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart'; // Using the Gym model

class MemberGymScreen extends StatefulWidget {
  const MemberGymScreen({super.key});

  @override
  State<MemberGymScreen> createState() => _MemberGymScreenState();
}

class _MemberGymScreenState extends State<MemberGymScreen> {
  List<Gym> _gyms = [];
  List<Gym> _filteredGyms = []; // For search
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGyms();
  }

  Future<void> _fetchGyms() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final gyms = await MemberProvider.fetchAllGyms();
      if (!mounted) return;
      setState(() {
        _gyms = gyms;
        _filteredGyms = gyms;
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

  void _filterGyms(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredGyms = _gyms;
      } else {
        _filteredGyms = _gyms
            .where(
              (gym) =>
                  gym.name.toLowerCase().contains(query.toLowerCase()) ||
                  gym.location.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _bookGym(Gym gym) async {
    try {
      final memberId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (memberId == null) throw Exception("User not logged in");

      // For simplicity, booking for "Today"
      await MemberProvider.bookGym(
        memberId: memberId,
        gym: gym,
        date: DateTime.now(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booked session at ${gym.name}!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Close dialog
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
      body: Column(
        children: [
          // Search Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search gyms...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterGyms,
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : _filteredGyms.isEmpty
                ? const Center(child: Text('No gyms found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredGyms.length,
                    itemBuilder: (context, index) {
                      return _buildGymCard(_filteredGyms[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymCard(Gym gym) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gym Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    image: gym.photo.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(gym.photo),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: gym.photo.isEmpty
                      ? const Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: Colors.green,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.red[500],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              gym.location,
                              style: TextStyle(color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Price
                      Text(
                        '\$${gym.pricePerMonth.toStringAsFixed(2)}/month',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showBookingDialog(gym),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(Gym gym) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Book ${gym.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Confirm booking for today?'),
            const SizedBox(height: 16),
            // In a real app, you would add a date picker here
            Text('Date: ${_formatDate(DateTime.now())}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _bookGym(gym), // Call the actual booking method
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }
}
