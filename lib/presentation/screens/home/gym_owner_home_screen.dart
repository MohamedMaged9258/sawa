import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
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
  final List<Gym> _gyms = [];
  final List<Coach> _coaches = [];

  void _addGym(Gym gym) {
    setState(() {
      _gyms.add(gym);
    });
  }

  void _updateGym(Gym updatedGym) {
    setState(() {
      final index = _gyms.indexWhere((gym) => gym.id == updatedGym.id);
      if (index != -1) {
        _gyms[index] = updatedGym;
      }
    });
  }

  void _deleteGym(int index) {
    setState(() {
      _gyms.removeAt(index);
    });
  }

  void _addCoach(Coach coach) {
    setState(() {
      _coaches.add(coach);
    });
  }

  void _deleteCoach(int index) {
    setState(() {
      _coaches.removeAt(index);
    });
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
          // Logout Icon only
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
      body: GymOwnerDashboard(
        gyms: _gyms,
        coaches: _coaches,
        onGymAdded: _addGym,
        onGymUpdated: _updateGym,
        onGymDeleted: _deleteGym,
        onCoachAdded: _addCoach,
        onCoachDeleted: _deleteCoach,
      ),
    );
  }
}

class GymOwnerDashboard extends StatelessWidget {
  final List<Gym> gyms;
  final List<Coach> coaches;
  final Function(Gym) onGymAdded;
  final Function(Gym) onGymUpdated;
  final Function(int) onGymDeleted;
  final Function(Coach) onCoachAdded;
  final Function(int) onCoachDeleted;

  const GymOwnerDashboard({
    super.key,
    required this.gyms,
    required this.coaches,
    required this.onGymAdded,
    required this.onGymUpdated,
    required this.onGymDeleted,
    required this.onCoachAdded,
    required this.onCoachDeleted,
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
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 32,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back, ${authProvider.name ?? "Gym Owner"}!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage ${gyms.length} gyms and ${coaches.length} coaches',
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
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Gyms', gyms.length.toString(), Icons.fitness_center, Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Coaches', coaches.length.toString(), Icons.people, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Members', '128', Icons.people_alt, Colors.orange),
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
        title: 'Add Gym',
        icon: Icons.add_business,
        color: Colors.green,
        onTap: () => _navigateToScreen(
          context,
          AddGymScreen(onGymAdded: onGymAdded),
        ),
      ),
      DashboardItem(
        title: 'Coaches List',
        icon: Icons.people_alt,
        color: Colors.blue,
        onTap: () => _navigateToScreen(
          context,
          CoachesListScreen(
            coaches: coaches,
            onCoachAdded: onCoachAdded,
            onCoachDeleted: onCoachDeleted,
          ),
        ),
      ),
      DashboardItem(
        title: 'Gym Details',
        icon: Icons.business,
        color: Colors.orange,
        onTap: () => _navigateToScreen(
          context,
          GymDetailsScreen(
            gyms: gyms,
            onGymUpdated: onGymUpdated,
            onGymDeleted: onGymDeleted,
          ),
        ),
      ),
      DashboardItem(
        title: 'Statistics',
        icon: Icons.analytics,
        color: Colors.red,
        onTap: () => _navigateToScreen(context, const GymStatisticsScreen()),
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