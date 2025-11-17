import 'package:flutter/material.dart';

class AddGymScreen extends StatelessWidget {
  const AddGymScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Gym'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Your Gym',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Gym registration form will be implemented here...'),
            // You'll implement the actual form here
          ],
        ),
      ),
    );
  }
}