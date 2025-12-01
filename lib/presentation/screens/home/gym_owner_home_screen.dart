import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/gym_provider.dart';
import 'package:sawa/presentation/screens/gym_owner/add_gym_screen.dart';
import 'package:sawa/presentation/screens/gym_owner/coaches_list_screen.dart';
import 'package:sawa/presentation/screens/gym_owner/gym_details_screen.dart';
import 'package:sawa/presentation/screens/gym_owner/gym_statistics_screen.dart';

class GymOwnerHomeScreen extends StatefulWidget {
  const GymOwnerHomeScreen({super.key});

  @override
  State<GymOwnerHomeScreen> createState() => _GymOwnerHomeScreenState();
}

class _GymOwnerHomeScreenState extends State<GymOwnerHomeScreen> {
  int _currentIndex = 0; // Tracks the active tab
  bool _isLoading = true;
  int _gymCount = 0;
  int _coachCount = 0;
  int _memberCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // Fetches data specifically for the Dashboard (Tab 0)
  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty) {
        throw Exception("User is not logged in.");
      }

      final stats = await GymProvider.getStatistics(ownerId);

      if (!mounted) return;

      setState(() {
        _gymCount = stats['gymCount'] ?? 0;
        _coachCount = stats['coachCount'] ?? 0;
        _memberCount = stats['activeMembers'] ?? 0;
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
    // If we go back to Home, refresh the stats
    if (index == 0) {
      _fetchDashboardData();
    }
  }

  // Action for "Add Gym" (Modal push, stays on current tab)
  Future<void> _navigateToAddGym() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGymScreen()),
    );
    if (!mounted) return;
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    // Define the screens for each tab
    final List<Widget> screens = [
      // Tab 0: Dashboard (We pass the fetched stats and nav callbacks here)
      _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[800]))
          : _error != null
          ? Center(
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            )
          : GymOwnerDashboard(
              gymCount: _gymCount,
              coachCount: _coachCount,
              memberCount: _memberCount,
              onNavigateToAddGym: _navigateToAddGym,
              // These callbacks now switch tabs instead of pushing screens
              onNavigateToGymDetails: () => _onTabTapped(1),
              onNavigateToCoachesList: () => _onTabTapped(2),
              onNavigateToStatistics: () => _onTabTapped(3),
            ),
      // Tab 1: My Gyms
      const GymDetailsScreen(),
      // Tab 2: Coaches
      const CoachesListScreen(),
      // Tab 3: Analytics
      const GymStatisticsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // We use IndexedStack to keep the state of tabs alive (optional, but good for performance)
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
          selectedItemColor: Colors.blue[800], // Premium Blue
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
              icon: Icon(Icons.store_mall_directory_rounded),
              label: 'Gyms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Coaches',
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

// --- Modified Dashboard Component ---

class GymOwnerDashboard extends StatelessWidget {
  final int gymCount;
  final int coachCount;
  final int memberCount;
  final VoidCallback onNavigateToAddGym;
  final VoidCallback onNavigateToGymDetails;
  final VoidCallback onNavigateToCoachesList;
  final VoidCallback onNavigateToStatistics; // Added callback for stats

  const GymOwnerDashboard({
    super.key,
    required this.gymCount,
    required this.coachCount,
    required this.memberCount,
    required this.onNavigateToAddGym,
    required this.onNavigateToGymDetails,
    required this.onNavigateToCoachesList,
    required this.onNavigateToStatistics,
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
                const SizedBox(height: 80), // Extra space for bottom nav
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
          colors: [Colors.blue[900]!, Colors.blue[700]!],
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
                  Icons.business_center,
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
            authProvider.name ?? "Gym Owner",
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
            'Gyms',
            gymCount.toString(),
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Coaches',
            coachCount.toString(),
            Icons.people,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Members',
            memberCount.toString(),
            Icons.groups,
            Colors.orange,
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
    // Grid items now trigger the callbacks provided by the parent Screen
    final List<DashboardItem> items = [
      DashboardItem(
        title: 'Add Gym',
        icon: Icons.add_location_alt,
        color: Colors.blue[700]!,
        onTap: onNavigateToAddGym,
      ),
      DashboardItem(
        title: 'Coaches',
        icon: Icons.sports_gymnastics,
        color: Colors.purple[600]!,
        onTap: onNavigateToCoachesList,
      ),
      DashboardItem(
        title: 'My Gyms',
        icon: Icons.store,
        color: Colors.orange[700]!,
        onTap: onNavigateToGymDetails,
      ),
      DashboardItem(
        title: 'Analytics',
        icon: Icons.bar_chart,
        color: Colors.red[600]!,
        onTap: onNavigateToStatistics,
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
  DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
