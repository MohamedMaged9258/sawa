// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/nutritionist_provider.dart'; // NEW
import '../nutritionist/consultation_screen.dart';
import '../nutritionist/clients_screen.dart';
import '../nutritionist/plans_screen.dart';

class NutritionistHomeScreen extends StatefulWidget {
  const NutritionistHomeScreen({super.key});

  @override
  State<NutritionistHomeScreen> createState() => _NutritionistHomeScreenState();
}

class _NutritionistHomeScreenState extends State<NutritionistHomeScreen> {
  int _currentIndex = 0;

  // Define screens list
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ClientsScreen(),
    const PlansScreen(),
    const ConsultationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutritionist Dashboard'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // REMOVED: Profile button moved to dashboard grid
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
      body: _screens[_currentIndex],
      // UPDATED: Bottom Navigation Bar Style
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Fixed style
        backgroundColor: Colors.purple[700], // Solid background
        selectedItemColor: Colors.white, // High contrast selected item
        unselectedItemColor:
            Colors.purple[300], // Adjusted unselected color for better contrast
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Plans'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Consultations',
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
  Map<String, dynamic> _stats = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  /// Fetches statistics from the static provider
  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty) {
        throw Exception("User ID not available.");
      }

      final stats = await NutritionistProvider.getStatistics(ownerId);

      if (!mounted) return;
      setState(() {
        _stats = stats;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Error loading dashboard: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return _buildWelcomeCard(authProvider.name ?? "Nutritionist");
                },
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    'Total Clients',
                    (_stats['totalClients'] ?? 0).toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildDashboardCard(
                    'Active Plans',
                    (_stats['activePlans'] ?? 0).toString(),
                    Icons.assignment,
                    Colors.green,
                  ),
                  _buildDashboardCard(
                    'Pending Consultations',
                    (_stats['pendingConsultations'] ?? 0).toString(),
                    Icons.chat,
                    Colors.orange,
                  ),
                  _buildDashboardCard(
                    'Monthly Revenue',
                    '\$${_stats['monthlyRevenue'] ?? '0'}',
                    Icons.attach_money,
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Card(
      // ... (Styling remains the same)
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.medical_services, size: 32, color: Colors.purple[700]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back, $name!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your clients and meal plans',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
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
}
