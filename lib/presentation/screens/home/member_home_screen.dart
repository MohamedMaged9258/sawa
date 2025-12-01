// lib/presentation/screens/member/member_home_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/member_provider.dart';
import 'package:sawa/presentation/models/member_models.dart';
import '../member/member_gym_screen.dart';
import '../member/member_restaurant_screen.dart';
import '../member/member_nutritionist_screen.dart';
import '../member/member_meal_plans_screen.dart';

class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({super.key});

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MemberGymScreen(),
    const MemberRestaurantScreen(),
    const MemberNutritionistScreen(),
    const MemberMealPlansScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAWA Fitness'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _currentIndex == 0
          ? const DashboardScreen()
          : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue[700],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Gyms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Nutritionists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meal Plans',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      final memberId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (memberId == null) throw Exception("User not logged in.");

      final stats = await MemberProvider.getMemberStats(memberId);

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _errorMessage = e.toString().contains('Failed to load')
            ? e.toString()
            : 'Failed to load dashboard data. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Helper to format Date and Time based on device settings (12h/24h)
  String _formatDateTime(BuildContext context, DateTime date) {
    final dateStr = "${date.day}/${date.month}/${date.year}";
    // TimeOfDay.format(context) automatically uses the device's 12h/24h setting
    final timeStr = TimeOfDay.fromDateTime(date).format(context);
    return "$dateStr at $timeStr";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchStats,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final int gymVisits = _stats['gymVisits'] ?? 0;
    final int mealsOrdered = _stats['mealsOrdered'] ?? 0;
    final int nutritionistSessions = _stats['nutritionistSessions'] ?? 0;
    final int activePlans = _stats['activePlans'] ?? 0;
    final Booking? nextAppt = _stats['nextAppointment'];
    final FoodOrder? lastOrder = _stats['lastOrder'];

    return RefreshIndicator(
      onRefresh: _fetchStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back, ${authProvider.name ?? "Member"}!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Stay fit and healthy with SAWA',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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
            ),
            const SizedBox(height: 24),

            // Quick Stats Grid
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Gym Visits',
                  gymVisits.toString(),
                  Icons.fitness_center,
                  Colors.green,
                ),
                _buildStatCard(
                  'Meals Ordered',
                  mealsOrdered.toString(),
                  Icons.restaurant,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Sessions',
                  nutritionistSessions.toString(),
                  Icons.medical_services,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Active Plans',
                  activePlans.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upcoming Appointments
            const Text(
              'Next Appointment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (nextAppt != null)
              _buildAppointmentCard(
                // 1. Type
                nextAppt.type == 'Gym' ? 'Gym Session' : 'Consultation',

                // 2. Name (Updated Logic)
                nextAppt.type == 'Nutritionist'
                    ? 'with Doctor: ${nextAppt.serviceName}' // <--- CHANGED
                    : nextAppt.serviceName,

                // 3. Date & Time (Already checks device format)
                _formatDateTime(context, nextAppt.date),

                nextAppt.type == 'Gym'
                    ? Icons.fitness_center
                    : Icons.medical_services,
                nextAppt.type == 'Gym' ? Colors.green : Colors.purple,
              )
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No upcoming appointments."),
                ),
              ),

            const SizedBox(height: 24),

            // Last Meal
            const Text(
              'Last Meal Ordered',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (lastOrder != null)
              _buildLastMealCard(lastOrder)
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No past orders."),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // --- UPDATED APPOINTMENT CARD ---
  Widget _buildAppointmentCard(
    String type, // "Consultation"
    String name, // "Dr. Smith"
    String dateTime, // "12/12/2024 at 10:00 AM"
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Type (Small, colored)
                  Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 2. Doctor/Gym Name (Large, Bold)
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 3. Date and Time (With Icon)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateTime,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastMealCard(FoodOrder order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.orange,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.mealName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.restaurantName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ordered: ${_formatDate(order.date)}',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${order.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }
}
