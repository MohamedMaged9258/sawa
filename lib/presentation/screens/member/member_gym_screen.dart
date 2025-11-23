// lib/presentation/screens/member/member_gym_screen.dart
import 'package:flutter/material.dart';

class MemberGymScreen extends StatefulWidget {
  const MemberGymScreen({super.key});

  @override
  State<MemberGymScreen> createState() => _MemberGymScreenState();
}

class _MemberGymScreenState extends State<MemberGymScreen> {
  final List<Gym> _gyms = [
    Gym(
      id: '1',
      name: 'Premium Fitness Center',
      location: '123 Main Street, City Center',
      price: 49.99,
      rating: 4.8,
      image: '',
      facilities: ['Pool', 'Sauna', 'Parking', 'Personal Trainers'],
      distance: '1.2 km',
    ),
    Gym(
      id: '2',
      name: 'Elite Strength Gym',
      location: '456 Fitness Avenue, Downtown',
      price: 69.99,
      rating: 4.9,
      image: '',
      facilities: ['Heavy Weights', 'CrossFit Area', 'Supplements Shop'],
      distance: '2.5 km',
    ),
    Gym(
      id: '3',
      name: 'Community Workout Space',
      location: '789 Health Road, Uptown',
      price: 39.99,
      rating: 4.5,
      image: '',
      facilities: ['Yoga Studio', 'Cardio Zone', 'Group Classes'],
      distance: '0.8 km',
    ),
  ];

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search gyms...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'All'),
                      _buildFilterChip('Nearby', 'Nearby'),
                      _buildFilterChip('Premium', 'Premium'),
                      _buildFilterChip('Budget', 'Budget'),
                      _buildFilterChip('24/7', '24/7'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _gyms.length,
              itemBuilder: (context, index) {
                return _buildGymCard(_gyms[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
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
                  ),
                  child: const Icon(Icons.fitness_center, size: 40, color: Colors.green),
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
                          Icon(Icons.location_on, color: Colors.red[500], size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              gym.location,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.directions_walk, color: Colors.blue[500], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            gym.distance,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[600], size: 16),
                              const SizedBox(width: 4),
                              Text(
                                gym.rating.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Facilities
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: gym.facilities.take(3).map((facility) {
                return Chip(
                  label: Text(facility),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(fontSize: 12),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Price and Book Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${gym.price.toStringAsFixed(2)}/month',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showBookingDialog(gym);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Book Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(Gym gym) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${gym.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select booking details:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Membership Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'basic', child: Text('Basic - 1 Month')),
                DropdownMenuItem(value: 'premium', child: Text('Premium - 3 Months')),
                DropdownMenuItem(value: 'vip', child: Text('VIP - 6 Months')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully booked ${gym.name}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}

class Gym {
  String id;
  String name;
  String location;
  double price;
  double rating;
  String image;
  List<String> facilities;
  String distance;

  Gym({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.image,
    required this.facilities,
    required this.distance,
  });
}