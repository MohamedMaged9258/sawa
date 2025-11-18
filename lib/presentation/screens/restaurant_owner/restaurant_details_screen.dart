// lib/presentation/screens/restaurant_owner/restaurant_details_screen.dart
import 'package:flutter/material.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final List<Restaurant> restaurants;
  final Function(Restaurant) onRestaurantUpdated;
  final Function(int) onRestaurantDeleted;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurants,
    required this.onRestaurantUpdated,
    required this.onRestaurantDeleted,
  });

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  void _editRestaurant(int index) {
    print('Editing restaurant: ${widget.restaurants[index].name}');
    // Implement edit functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit restaurant functionality will be implemented here'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteRestaurant(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: Text('Are you sure you want to delete ${widget.restaurants[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onRestaurantDeleted(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restaurant deleted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Restaurants'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: widget.restaurants.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No restaurants added yet'),
                  SizedBox(height: 8),
                  Text('Tap "Add Restaurant" to get started', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.restaurants.length,
              itemBuilder: (context, index) {
                return _buildRestaurantCard(widget.restaurants[index], index);
              },
            ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Photo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restaurant, size: 40, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.food_bank, color: Colors.orange[700], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.cuisineType,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red[500], size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurant.location,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green[700], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '\$${restaurant.priceRange.toStringAsFixed(2)} per person',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Added: ${_formatDate(restaurant.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () => _editRestaurant(index),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: () => _deleteRestaurant(index),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}