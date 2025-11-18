import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/gym_provider.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
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
  bool _isLoading = true;
  int _gymCount = 0;
  int _coachCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    // Safety check at start (rarely needed but good practice)
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
      
      // ⚠️ SAFETY CHECK: Is widget still on screen?
      if (!mounted) return;

      setState(() {
        _gymCount = stats['gymCount'] ?? 0;
        _coachCount = stats['coachCount'] ?? 0;
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

  Future<void> _navigateToAddGym() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGymScreen()),
    );
    // ⚠️ SAFETY CHECK
    if (!mounted) return;
    _fetchDashboardData();
  }

  Future<void> _navigateToGymDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GymDetailsScreen()),
    );
    // ⚠️ SAFETY CHECK
    if (!mounted) return;
    _fetchDashboardData();
  }

  Future<void> _navigateToCoachesList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CoachesListScreen()),
    );
    // ⚠️ SAFETY CHECK
    if (!mounted) return;
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Owner Dashboard'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return GymOwnerDashboard(
      gymCount: _gymCount,
      coachCount: _coachCount,
      onNavigateToAddGym: _navigateToAddGym,
      onNavigateToGymDetails: _navigateToGymDetails,
      onNavigateToCoachesList: _navigateToCoachesList,
    );
  }
}

// (The GymOwnerDashboard class remains the same as the previous valid version)
class GymOwnerDashboard extends StatelessWidget {
  final int gymCount;
  final int coachCount;
  final VoidCallback onNavigateToAddGym;
  final VoidCallback onNavigateToGymDetails;
  final VoidCallback onNavigateToCoachesList;

  const GymOwnerDashboard({
    super.key,
    required this.gymCount,
    required this.coachCount,
    required this.onNavigateToAddGym,
    required this.onNavigateToGymDetails,
    required this.onNavigateToCoachesList,
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
          _buildWelcomeSection(context),
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.fitness_center, size: 32, color: Colors.green[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back, ${authProvider.name ?? "Gym Owner"}!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage $gymCount gyms and $coachCount coaches',
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

  Widget _buildStatisticsOverview() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Gyms', gymCount.toString(), Icons.fitness_center, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Coaches', coachCount.toString(), Icons.people, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Members', '128', Icons.people_alt, Colors.orange)),
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
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    final List<DashboardItem> items = [
      DashboardItem(title: 'Add Gym', icon: Icons.add_business, color: Colors.green, onTap: onNavigateToAddGym),
      DashboardItem(title: 'Coaches List', icon: Icons.people_alt, color: Colors.blue, onTap: onNavigateToCoachesList),
      DashboardItem(title: 'Gym Details', icon: Icons.business, color: Colors.orange, onTap: onNavigateToGymDetails),
      DashboardItem(title: 'Statistics', icon: Icons.analytics, color: Colors.red, onTap: () => _navigateToScreen(context, const GymStatisticsScreen())),
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
                decoration: BoxDecoration(color: item.color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(item.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
  DashboardItem({required this.title, required this.icon, required this.color, required this.onTap});
}