// lib/presentation/screens/member/member_restaurant_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/member_provider.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';

class MemberRestaurantScreen extends StatefulWidget {
  const MemberRestaurantScreen({super.key});

  @override
  State<MemberRestaurantScreen> createState() => _MemberRestaurantScreenState();
}

class _MemberRestaurantScreenState extends State<MemberRestaurantScreen> {
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final restaurants = await MemberProvider.fetchAllRestaurants();
      if (!mounted) return;
      setState(() {
        _restaurants = restaurants;
        _filteredRestaurants = restaurants;
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

  void _filterRestaurants(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRestaurants = _restaurants;
      } else {
        _filteredRestaurants = _restaurants
            .where(
              (r) =>
                  r.name.toLowerCase().contains(query.toLowerCase()) ||
                  r.cuisineType.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  // --- Menu & Ordering Logic ---

  Future<void> _showMenuAndOrder(Restaurant restaurant) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RestaurantMenuSheet(restaurant: restaurant),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterRestaurants,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : _filteredRestaurants.isEmpty
                ? const Center(child: Text('No restaurants found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      return _buildRestaurantCard(_filteredRestaurants[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showMenuAndOrder(restaurant),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                      image: restaurant.photo.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(restaurant.photo),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: restaurant.photo.isEmpty
                        ? const Icon(Icons.restaurant, color: Colors.orange)
                        : null,
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
                        Text(
                          restaurant.cuisineType,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.red[400],
                            ),
                            Expanded(
                              child: Text(
                                restaurant.location,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showMenuAndOrder(restaurant),
                  child: const Text('View Menu & Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Separate Widget for Menu Bottom Sheet ---
class RestaurantMenuSheet extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantMenuSheet({super.key, required this.restaurant});

  @override
  State<RestaurantMenuSheet> createState() => _RestaurantMenuSheetState();
}

class _RestaurantMenuSheetState extends State<RestaurantMenuSheet> {
  List<Meal> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    try {
      final meals = await MemberProvider.fetchMealsForRestaurant(
        widget.restaurant.rid,
      );
      if (mounted) {
        setState(() {
          _meals = meals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _orderMeal(Meal meal) async {
    try {
      final memberId = Provider.of<AuthProvider>(context, listen: false).uid!;

      await MemberProvider.orderFood(
        memberId: memberId,
        restaurant: widget.restaurant,
        meal: meal,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ordered ${meal.name} successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to order.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            widget.restaurant.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _meals.isEmpty
                ? const Center(child: Text("No meals available."))
                : ListView.builder(
                    itemCount: _meals.length,
                    itemBuilder: (context, index) {
                      final meal = _meals[index];
                      return Card(
                        child: ListTile(
                          leading: meal.photo.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(meal.photo),
                                )
                              : const Icon(
                                  Icons.fastfood,
                                  color: Colors.orange,
                                ),
                          title: Text(meal.name),
                          subtitle: Text('\$${meal.price}'),
                          trailing: ElevatedButton(
                            onPressed: meal.isAvailable
                                ? () => _orderMeal(meal)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                            ),
                            child: const Text(
                              'Order',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
