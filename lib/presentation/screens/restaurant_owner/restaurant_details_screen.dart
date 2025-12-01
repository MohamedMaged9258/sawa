import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/restaurant_provider.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  const RestaurantDetailsScreen({super.key});

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
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
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await RestaurantProvider.deleteRestaurant(restaurant);
              if (mounted) _fetchRestaurants();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Restaurants'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[800]))
          : _restaurants.isEmpty
          ? Center(
              child: Text(
                "No restaurants found",
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              itemCount: _restaurants.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final r = _restaurants[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        image: r.photo.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(r.photo),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: r.photo.isEmpty
                          ? Icon(Icons.store, color: Colors.blue[300])
                          : null,
                    ),
                    title: Text(
                      r.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 14,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                r.cuisineType,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  r.location,
                                  style: TextStyle(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                      onPressed: () => _deleteRestaurant(r),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
