import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/restaurant_provider.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  const RestaurantDetailsScreen({super.key});

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    setState(() => _isLoading = true);
    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId != null) {
        final data = await RestaurantProvider.fetchRestaurantsByOwner(ownerId);
        setState(() => _restaurants = data);
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deleteRestaurant(Restaurant restaurant) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: Text('Delete ${restaurant.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await RestaurantProvider.deleteRestaurant(restaurant);
              if (mounted) _fetchRestaurants();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Restaurants'), backgroundColor: Colors.orange[700], foregroundColor: Colors.white),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _restaurants.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final r = _restaurants[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: r.photo.isNotEmpty ? CircleAvatar(backgroundImage: NetworkImage(r.photo)) : const Icon(Icons.restaurant),
                  title: Text(r.name),
                  subtitle: Text('${r.cuisineType} • ${r.location}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteRestaurant(r),
                  ),
                ),
              );
            },
          ),
    );
  }
}