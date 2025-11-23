// lib/presentation/screens/restaurant_owner/restaurant_statistics_screen.dart
import 'package:flutter/material.dart';

class RestaurantStatisticsScreen extends StatelessWidget {
  const RestaurantStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Statistics'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('Total Revenue: \$2,850.00'),
                    Text('This Week: \$850.00'),
                    Text('This Month: \$2,850.00'),
                    Text('Average Order Value: \$25.50'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('Total Orders: 112'),
                    Text('Completed Orders: 98'),
                    Text('Pending Orders: 8'),
                    Text('Cancelled Orders: 6'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('Total Customers: 85'),
                    Text('Repeat Customers: 45'),
                    Text('New Customers This Month: 12'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}