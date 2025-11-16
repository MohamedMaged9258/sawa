import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
class RestaurantOwnerHomeScreen extends StatelessWidget {
  const RestaurantOwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Welcome Restaurant Owner!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Manage meals, view orders, update menu'),
          ],
        ),
      ),
    );
  }
}