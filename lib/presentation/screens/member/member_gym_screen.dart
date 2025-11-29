// lib/presentation/screens/member/member_gym_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/member_provider.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';

class MemberGymScreen extends StatefulWidget {
  const MemberGymScreen({super.key});

  @override
  State<MemberGymScreen> createState() => _MemberGymScreenState();
}

class _MemberGymScreenState extends State<MemberGymScreen> {
  List<Gym> _gyms = [];
  List<Gym> _filteredGyms = []; 
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

      await MemberProvider.bookGym(
        memberId: memberId,
        gym: gym,
        date: DateTime.now(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booked session at ${gym.name}!'),
          backgroundColor: Colors.blue[800], // Blue Toast
        ),
      );
      Navigator.pop(context); 
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
            Text('Date: ${_formatDate(DateTime.now())}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _bookGym(gym),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]), // Blue Button
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Find your gym...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.blue[800]), // Blue Icon
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: _filterGyms,
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.blue[800]))
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showBookingDialog(gym),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.blue[50]),
                      child: gym.photo.isNotEmpty
                          ? Image.network(
                              gym.photo,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => Icon(Icons.fitness_center, size: 50, color: Colors.blue[200]),
                            )
                          : Icon(Icons.fitness_center, size: 50, color: Colors.blue[200]),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                        ],
                      ),
                      child: Text(
                        '\$${gym.pricePerMonth.toStringAsFixed(0)}/mo',
                        style: TextStyle(
                          color: Colors.blue[800], // Blue Text
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            gym.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text("4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            gym.location,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showBookingDialog(gym),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800], // Blue Button
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Book Session',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}