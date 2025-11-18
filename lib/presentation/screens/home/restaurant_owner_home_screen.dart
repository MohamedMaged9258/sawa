// lib/presentation/screens/restaurant_owner/restaurant_owner_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';
import 'package:sawa/presentation/screens/restaurant_owner/add_restaurant_screen.dart'; 
import 'package:sawa/presentation/screens/restaurant_owner/meals_list_screen.dart';
import 'package:sawa/presentation/screens/restaurant_owner/orders_screen.dart';
import 'package:sawa/presentation/screens/restaurant_owner/restaurant_details_screen.dart';
import 'package:sawa/presentation/screens/restaurant_owner/restaurant_statistics_screen.dart';

class RestaurantOwnerHomeScreen extends StatefulWidget {
  const RestaurantOwnerHomeScreen({super.key});

  @override
  State<RestaurantOwnerHomeScreen> createState() => _RestaurantOwnerHomeScreenState();
}

class _RestaurantOwnerHomeScreenState extends State<RestaurantOwnerHomeScreen> {
  final List<Restaurant> _restaurants = [];
  final List<Meal> _meals = [];
  final List<Order> _orders = [];

  void addRestaurant(Restaurant restaurant) {
    setState(() {
      _restaurants.add(restaurant);
    });
  }

  void updateRestaurant(Restaurant updatedRestaurant) {
    setState(() {
      final index = _restaurants.indexWhere((restaurant) => restaurant.id == updatedRestaurant.id);
      if (index != -1) {
        _restaurants[index] = updatedRestaurant;
      }
    });
  }

  void deleteRestaurant(int index) {
    setState(() {
      _restaurants.removeAt(index);
    });
  }

  void addMeal(Meal meal) {
    setState(() {
      _meals.add(meal);
    });
  }

  void deleteMeal(int index) {
    setState(() {
      _meals.removeAt(index);
    });
  }

  void addOrder(Order order) {
    setState(() {
      _orders.add(order);
    });
  }

  void updateOrderStatus(int index, String status) {
    setState(() {
      _orders[index].status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Owner Dashboard'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RestaurantOwnerDashboard(
        restaurants: _restaurants,
        meals: _meals,
        orders: _orders,
        onRestaurantAdded: addRestaurant,
        onRestaurantUpdated: updateRestaurant,
        onRestaurantDeleted: deleteRestaurant,
        onMealAdded: addMeal,
        onMealDeleted: deleteMeal,
        onOrderAdded: addOrder,
        onOrderStatusUpdated: updateOrderStatus,
      ),
    );
  }
}

class RestaurantOwnerDashboard extends StatelessWidget {
  final List<Restaurant> restaurants;
  final List<Meal> meals;
  final List<Order> orders;
  final Function(Restaurant) onRestaurantAdded;
  final Function(Restaurant) onRestaurantUpdated;
  final Function(int) onRestaurantDeleted;
  final Function(Meal) onMealAdded;
  final Function(int) onMealDeleted;
  final Function(Order) onOrderAdded;
  final Function(int, String) onOrderStatusUpdated;

  const RestaurantOwnerDashboard({
    super.key,
    required this.restaurants,
    required this.meals,
    required this.orders,
    required this.onRestaurantAdded,
    required this.onRestaurantUpdated,
    required this.onRestaurantDeleted,
    required this.onMealAdded,
    required this.onMealDeleted,
    required this.onOrderAdded,
    required this.onOrderStatusUpdated,
  });

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatisticsOverview(),
          const SizedBox(height: 24),
          Expanded(
            child: _buildDashboardGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant,
                    size: 32,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back, ${authProvider.name ?? "Restaurant Owner"}!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage ${restaurants.length} restaurants and ${meals.length} meals',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsOverview() {
    final pendingOrders = orders.where((order) => order.status == 'pending').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Restaurants', restaurants.length.toString(), Icons.restaurant, Colors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Meals', meals.length.toString(), Icons.fastfood, Colors.red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Orders', pendingOrders.toString(), Icons.receipt, Colors.green),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    final List<DashboardItem> items = [
      DashboardItem(
        title: 'Add Restaurant',
        icon: Icons.add_business,
        color: Colors.orange,
        onTap: () => _navigateToScreen(
          context,
          AddRestaurantScreen(onRestaurantAdded: onRestaurantAdded),
        ),
      ),
      DashboardItem(
        title: 'Meals List',
        icon: Icons.fastfood,
        color: Colors.red,
        onTap: () => _navigateToScreen(
          context,
          MealsListScreen(
            meals: meals,
            onMealAdded: onMealAdded,
            onMealDeleted: onMealDeleted,
          ),
        ),
      ),
      DashboardItem(
        title: 'Restaurant Details',
        icon: Icons.business,
        color: Colors.blue,
        onTap: () => _navigateToScreen(
          context,
          RestaurantDetailsScreen(
            restaurants: restaurants,
            onRestaurantUpdated: onRestaurantUpdated,
            onRestaurantDeleted: onRestaurantDeleted,
          ),
        ),
      ),
      DashboardItem(
        title: 'Orders',
        icon: Icons.receipt,
        color: Colors.green,
        onTap: () => _navigateToScreen(
          context,
          OrdersScreen(
            orders: orders,
            onOrderStatusUpdated: onOrderStatusUpdated,
          ),
        ),
      ),
      DashboardItem(
        title: 'Statistics',
        icon: Icons.analytics,
        color: Colors.purple,
        onTap: () => _navigateToScreen(context, const RestaurantStatisticsScreen()),
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildDashboardItem(items[index]);
      },
    );
  }

  Widget _buildDashboardItem(DashboardItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}