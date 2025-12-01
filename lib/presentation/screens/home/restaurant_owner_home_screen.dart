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
  State<RestaurantOwnerHomeScreen> createState() =>
      _RestaurantOwnerHomeScreenState();
}

class _RestaurantOwnerHomeScreenState extends State<RestaurantOwnerHomeScreen> {
  int _currentIndex = 0;
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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty) {
        throw Exception("User not logged in.");
      }

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
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // --- Navigation Handlers ---

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // If returning to Dashboard (index 0), refresh data
    if (index == 0) {
      _fetchDashboardData();
    }
  }

  Future<void> _navigateToAddRestaurant() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRestaurantScreen()),
    );
    if (!mounted) return;
    _fetchDashboardData();
  }

  Future<void> _navigateToMyRestaurants() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RestaurantDetailsScreen()),
    );
    if (!mounted) return;
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    // Define the screens for each tab
    final List<Widget> screens = [
      // Tab 0: Dashboard
      _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[800]))
          : _error != null
          ? Center(
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            )
          : RestaurantOwnerDashboard(
              restaurantCount: _restaurantCount,
              mealCount: _mealCount,
              pendingOrders: _pendingOrders,
              onNavigateToAddRestaurant: _navigateToAddRestaurant,
              onNavigateToMyRestaurants: _navigateToMyRestaurants,
              onNavigateToMeals: () => _onTabTapped(1),
              onNavigateToOrders: () => _onTabTapped(2),
              onNavigateToStats: () => _onTabTapped(3),
            ),
      // Tab 1: Meals
      const MealsListScreen(),
      // Tab 2: Orders
      const OrdersScreen(),
      // Tab 3: Stats
      const RestaurantStatisticsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // IndexedStack preserves the state of each tab
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue[800], // Unified Blue Theme
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Meals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }
}

// --- Dashboard Widget ---

class RestaurantOwnerDashboard extends StatelessWidget {
  final int restaurantCount;
  final int mealCount;
  final int pendingOrders;
  final VoidCallback onNavigateToAddRestaurant;
  final VoidCallback onNavigateToMyRestaurants;
  final VoidCallback onNavigateToMeals;
  final VoidCallback onNavigateToOrders;
  final VoidCallback onNavigateToStats;

  const RestaurantOwnerDashboard({
    super.key,
    required this.restaurantCount,
    required this.mealCount,
    required this.pendingOrders,
    required this.onNavigateToAddRestaurant,
    required this.onNavigateToMyRestaurants,
    required this.onNavigateToMeals,
    required this.onNavigateToOrders,
    required this.onNavigateToStats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatisticsOverview(),
                const SizedBox(height: 24),
                const Text(
                  'Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDashboardGrid(context),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[900]!,
            Colors.blue[700]!,
          ], // Unified Blue Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome Back,',
            style: TextStyle(fontSize: 16, color: Colors.blue[100]),
          ),
          const SizedBox(height: 4),
          Text(
            authProvider.name ?? "Owner",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsOverview() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Restaurants',
            '$restaurantCount',
            Icons.store_mall_directory,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Meals',
            '$mealCount',
            Icons.restaurant_menu,
            Colors.orange, // Accent color for food
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            '$pendingOrders',
            Icons.receipt_long,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    final items = [
      DashboardItem(
        'Add Restaurant',
        Icons.add_business,
        Colors.blue[700]!,
        onNavigateToAddRestaurant,
      ),
      DashboardItem(
        'My Restaurants',
        Icons.business,
        Colors.purple[600]!,
        onNavigateToMyRestaurants,
      ),
      DashboardItem(
        'Orders',
        Icons.receipt_long,
        Colors.orange[700]!,
        onNavigateToOrders, // Switch to tab
      ),
      DashboardItem(
        'Analytics',
        Icons.bar_chart,
        Colors.red[600]!,
        onNavigateToStats, // Switch to tab
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildDashboardItem(items[index]),
    );
  }

  Widget _buildDashboardItem(DashboardItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: item.onTap,
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
                child: Icon(item.icon, color: item.color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
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
  DashboardItem(this.title, this.icon, this.color, this.onTap);
}
