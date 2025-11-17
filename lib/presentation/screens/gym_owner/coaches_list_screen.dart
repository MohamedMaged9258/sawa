import 'package:flutter/material.dart';

class CoachesListScreen extends StatelessWidget {
  const CoachesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaches List'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add coach screen
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCoachCard('John Smith', 'Fitness Trainer', 'assets/coach1.jpg'),
          _buildCoachCard('Sarah Johnson', 'Yoga Expert', 'assets/coach2.jpg'),
          _buildCoachCard('Mike Davis', 'Strength Coach', 'assets/coach3.jpg'),
        ],
      ),
    );
  }

  Widget _buildCoachCard(String name, String specialization, String imagePath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: const Icon(Icons.person, color: Colors.green),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(specialization),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to coach profile
        },
      ),
    );
  }
}