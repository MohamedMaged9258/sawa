import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/gym_provider.dart';

class GymStatisticsScreen extends StatefulWidget {
  const GymStatisticsScreen({super.key});

  @override
  State<GymStatisticsScreen> createState() => _GymStatisticsScreenState();
}

class _GymStatisticsScreenState extends State<GymStatisticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
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

      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: () {}),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading)
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    if (_error != null)
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    if (_stats == null) return const Center(child: Text('No data found.'));

    // --- FETCHING REAL DATA (Defaults to 0 if null) ---
    final double totalRevenue = (_stats!['totalMonthlyRevenue'] is num)
        ? _stats!['totalMonthlyRevenue'].toDouble()
        : 0.0;

    // THIS is the line that gets the members count.
    final int activeMembers = (_stats!['activeMembers'] is int)
        ? _stats!['activeMembers']
        : 0;

    // Additional real fields (default to 0 to remove hardcoded demo values)
    final int newMembers = (_stats!['newMembers'] is int)
        ? _stats!['newMembers']
        : 0;
    final String retentionRate = _stats!['retentionRate'] ?? '0%';
    final double weeklyRevenue = (_stats!['weeklyRevenue'] is num)
        ? _stats!['weeklyRevenue'].toDouble()
        : 0.0;
    final double yearlyRevenue = (_stats!['yearlyRevenue'] is num)
        ? _stats!['yearlyRevenue'].toDouble()
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildOverviewCards(
            totalRevenue: totalRevenue,
            activeMembers: activeMembers.toString(),
          ),
          const SizedBox(height: 20),
          _buildRevenueSection(
            totalRevenue: totalRevenue,
            weekly: weeklyRevenue,
            yearly: yearlyRevenue,
          ),
          const SizedBox(height: 20),
          _buildMemberStatsSection(
            newMembers: newMembers,
            retention: retentionRate,
          ),
          const SizedBox(height: 20),
          // Only show popular times if the data exists in the backend
          if (_stats!['popularTimes'] != null &&
              _stats!['popularTimes'] is List)
            _buildPopularTimesSection(_stats!['popularTimes']),
        ],
      ),
    );
  }

  Widget _buildOverviewCards({
    required double totalRevenue,
    required String activeMembers,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Revenue',
            value: '\$${totalRevenue.toStringAsFixed(0)}',
            change: '',
            isPositive: true,
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Active Members',
            value: activeMembers,
            change: '',
            isPositive: true,
            icon: Icons.group,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueSection({
    required double totalRevenue,
    required double weekly,
    required double yearly,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(Icons.bar_chart, size: 60, color: Colors.blue[200]),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStatItem(
                label: 'This Week',
                value: '\$${weekly.toStringAsFixed(0)}',
              ),
              _MiniStatItem(
                label: 'This Month',
                value: '\$${totalRevenue.toStringAsFixed(0)}',
              ),
              _MiniStatItem(
                label: 'This Year',
                value: '\$${yearly.toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberStatsSection({
    required int newMembers,
    required String retention,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Engagement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatRow('New Members This Month', newMembers.toString()),
          _buildStatRow('Retention Rate', retention),
        ],
      ),
    );
  }

  Widget _buildPopularTimesSection(List<dynamic> popularTimesData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Peak Hours',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...popularTimesData.map((time) {
            final Map<String, dynamic> slot = Map<String, dynamic>.from(time);
            return _buildTimeSlot(slot);
          }),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(Map<String, dynamic> timeSlot) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeSlot['time']?.toString() ?? '',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${timeSlot['percentage']}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:
                  (int.tryParse(timeSlot['percentage'].toString()) ?? 0) / 100,
              backgroundColor: Colors.blue[50],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          if (change.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStatItem extends StatelessWidget {
  final String label, value;
  const _MiniStatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }
}
