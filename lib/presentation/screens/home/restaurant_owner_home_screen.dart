import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/restaurant_provider.dart';
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
  bool _isLoading = true;
  int _restaurantCount = 0;
  int _mealCount = 0;
  int _pendingOrders = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty) throw Exception("User not logged in.");

      final stats = await RestaurantProvider.getStatistics(ownerId);
      
      if (!mounted) return;
      setState(() {
        _restaurantCount = stats['restaurantCount'] ?? 0;
        _mealCount = stats['mealCount'] ?? 0;
        _pendingOrders = stats['pendingOrderCount'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    if (mounted) _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Owner Dashboard'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null 
          ? Center(child: Text('Error: $_error'))
          : RestaurantOwnerDashboard(
              restaurantCount: _restaurantCount,
              mealCount: _mealCount,
              pendingOrders: _pendingOrders,
              onNavigate: _navigateAndRefresh,
            ),
    );
  }
}

class RestaurantOwnerDashboard extends StatelessWidget {
  final int restaurantCount;
  final int mealCount;
  final int pendingOrders;
  final Function(Widget) onNavigate;

  const RestaurantOwnerDashboard({
    super.key,
    required this.restaurantCount,
    required this.mealCount,
    required this.pendingOrders,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          const SizedBox(height: 24),
          _buildStatisticsOverview(),
          const SizedBox(height: 24),
          Expanded(child: _buildDashboardGrid()),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: Colors.orange[100], shape: BoxShape.circle),
              child: Icon(Icons.restaurant, size: 32, color: Colors.orange[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome Back, ${authProvider.name ?? "Owner"}!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Manage $restaurantCount restaurants and $mealCount meals', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsOverview() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Restaurants', '$restaurantCount', Icons.restaurant, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Meals', '$mealCount', Icons.fastfood, Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Orders', '$pendingOrders', Icons.receipt, Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid() {
    final items = [
      DashboardItem('Add Restaurant', Icons.add_business, Colors.orange, () => onNavigate(const AddRestaurantScreen())),
      DashboardItem('Meals List', Icons.fastfood, Colors.red, () => onNavigate(const MealsListScreen())),
      DashboardItem('My Restaurants', Icons.business, Colors.blue, () => onNavigate(const RestaurantDetailsScreen())),
      DashboardItem('Orders', Icons.receipt, Colors.green, () => onNavigate(const OrdersScreen())),
      DashboardItem('Statistics', Icons.analytics, Colors.purple, () => onNavigate(const RestaurantStatisticsScreen())),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.2),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildDashboardItem(items[index]),
    );
  }

  Widget _buildDashboardItem(DashboardItem item) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: item.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 30),
            const SizedBox(height: 10),
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
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
  DashboardItem(this.title, this.icon, this.color, this.onTap);
}