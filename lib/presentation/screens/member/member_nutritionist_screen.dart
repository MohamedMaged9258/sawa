// lib/presentation/screens/member/member_nutritionist_screen.dart
import 'package:flutter/material.dart';

class Nutritionist {
  final String id;
  final String name;
  final String specialization;
  final double rating;
  final String experience;
  final double price;
  final String image;
  final List<String> availability;
  final String bio;

  const Nutritionist({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.experience,
    required this.price,
    required this.image,
    required this.availability,
    required this.bio,
  });
}

class MemberNutritionistScreen extends StatefulWidget {
  const MemberNutritionistScreen({super.key});

  @override
  State<MemberNutritionistScreen> createState() => _MemberNutritionistScreenState();
}

class _MemberNutritionistScreenState extends State<MemberNutritionistScreen> {
  final List<Nutritionist> _nutritionists = [
    Nutritionist(
      id: '1',
      name: 'Dr. Sarah Johnson',
      specialization: 'Sports Nutrition',
      rating: 4.9,
      experience: '8 years',
      price: 75.00,
      image: '',
      availability: ['Mon, Wed, Fri', '9:00 AM - 5:00 PM'],
      bio: 'Specialized in sports nutrition and athletic performance optimization.',
    ),
    Nutritionist(
      id: '2',
      name: 'Dr. Mike Chen',
      specialization: 'Weight Management',
      rating: 4.7,
      experience: '6 years',
      price: 65.00,
      image: '',
      availability: ['Tue, Thu, Sat', '10:00 AM - 6:00 PM'],
      bio: 'Expert in weight loss strategies and sustainable eating habits.',
    ),
    Nutritionist(
      id: '3',
      name: 'Dr. Emily Davis',
      specialization: 'Clinical Nutrition',
      rating: 4.8,
      experience: '10 years',
      price: 85.00,
      image: '',
      availability: ['Mon-Fri', '8:00 AM - 4:00 PM'],
      bio: 'Focused on medical nutrition therapy and chronic disease management.',
    ),
  ];

  String _selectedSpecialization = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutritionists'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find a Nutritionist',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Book consultations with certified nutrition experts',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search nutritionists...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                // Specialization Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSpecializationChip('All'),
                      _buildSpecializationChip('Sports Nutrition'),
                      _buildSpecializationChip('Weight Management'),
                      _buildSpecializationChip('Clinical Nutrition'),
                      _buildSpecializationChip('Pediatric Nutrition'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _nutritionists.length,
              itemBuilder: (context, index) {
                return _buildNutritionistCard(_nutritionists[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationChip(String specialization) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(specialization),
        selected: _selectedSpecialization == specialization,
        selectedColor: Colors.purple[100],
        checkmarkColor: Colors.purple,
        onSelected: (selected) {
          setState(() {
            _selectedSpecialization = specialization;
          });
        },
      ),
    );
  }

  Widget _buildNutritionistCard(Nutritionist nutritionist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nutritionist Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 40, color: Colors.purple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nutritionist.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nutritionist.specialization,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.purple[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text(nutritionist.rating.toString()),
                          const SizedBox(width: 16),
                          Icon(Icons.work, color: Colors.blue[500], size: 16),
                          const SizedBox(width: 4),
                          Text(nutritionist.experience),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Availability: ${nutritionist.availability.join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bio
            Text(
              nutritionist.bio,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            // Price and Book Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${nutritionist.price.toStringAsFixed(2)}/session',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showBookingDialog(nutritionist);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Book Consultation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(Nutritionist nutritionist) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book with ${nutritionist.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specialization: ${nutritionist.specialization}'),
              Text('Price: \$${nutritionist.price.toStringAsFixed(2)} per session'),
              Text('Experience: ${nutritionist.experience}'),
              const SizedBox(height: 16),
              const Text(
                'This will open a booking screen where you can select available time slots.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to booking screen
                _navigateToBookingScreen(nutritionist);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToBookingScreen(Nutritionist nutritionist) {
    // TODO: Implement navigation to booking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking functionality for ${nutritionist.name} would be implemented here'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}