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

  Future<void> _showMenuAndOrder(Restaurant restaurant) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: RestaurantMenuSheet(restaurant: restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.blue[800],
                ), // Blue Icon
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue[800]!,
                  ), // Blue Border
                ),
              ),
              onChanged: _filterRestaurants,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Colors.blue[800]),
                  )
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
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showMenuAndOrder(restaurant),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 160,
                width: double.infinity,
                color: Colors.blue[50], // Blue tint placeholder
                child: restaurant.photo.isNotEmpty
                    ? Image.network(
                        restaurant.photo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 50,
                              color: Colors.blue[200],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 50,
                          color: Colors.blue[200],
                        ),
                      ),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.cuisineType,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showMenuAndOrder(restaurant),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[800], // Blue Text
                        side: BorderSide(
                          color: Colors.blue[800]!,
                        ), // Blue Border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View Menu & Order'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ordered ${meal.name} successfully!'),
          backgroundColor: Colors.blue[800],
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.restaurant.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Colors.blue[800]),
                  )
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
                              : Icon(
                                  Icons.fastfood,
                                  color: Colors.blue[300], // Blue Icon
                                ),
                          title: Text(meal.name),
                          subtitle: Text('\$${meal.price}'),
                          trailing: ElevatedButton(
                            onPressed: meal.isAvailable
                                ? () => _orderMeal(meal)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800], // Blue Button
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
