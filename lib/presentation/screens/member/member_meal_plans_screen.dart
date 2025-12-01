import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/member_provider.dart';
import 'package:sawa/presentation/models/nutritionist_models.dart';

class MemberMealPlansScreen extends StatefulWidget {
  const MemberMealPlansScreen({super.key});

  @override
  State<MemberMealPlansScreen> createState() => _MemberMealPlansScreenState();
}

class _MemberMealPlansScreenState extends State<MemberMealPlansScreen> {
  List<MealPlan> _mealPlans = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMealPlans();
  }

  Future<void> _fetchMealPlans() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final plans = await MemberProvider.fetchMealPlansForMember(auth.uid!);
      if (!mounted) return;
      setState(() {
        _mealPlans = plans;
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _fetchMealPlans,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blue[800]))
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchMealPlans,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _mealPlans.isEmpty
            ? const Center(child: Text('No meal plans assigned yet.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _mealPlans.length,
                itemBuilder: (context, index) {
                  return _buildMealPlanCard(_mealPlans[index]);
                },
              ),
      ),
    );
  }

  Widget _buildMealPlanCard(MealPlan plan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nutritionist: ${plan.clientName}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    plan.duration,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              plan.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Daily Meal Plan',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [..._buildDailyMeals(plan.dailyMeals)],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDailyMeals(Map<String, String> dailyMeals) {
    if (dailyMeals.isEmpty) {
      return [
        const ListTile(
          title: Text('No daily meals specified'),
          subtitle: Text('Contact your nutritionist for details'),
        ),
      ];
    }

    final meals = <Widget>[];

    if (dailyMeals.containsKey('breakfast') &&
        dailyMeals['breakfast']!.isNotEmpty) {
      meals.add(
        ListTile(
          leading: const Icon(Icons.free_breakfast, color: Colors.amber),
          title: const Text('Breakfast'),
          subtitle: Text(dailyMeals['breakfast']!),
        ),
      );
    }

    if (dailyMeals.containsKey('lunch') && dailyMeals['lunch']!.isNotEmpty) {
      meals.add(
        ListTile(
          leading: const Icon(Icons.fastfood, color: Colors.orange),
          title: const Text('Lunch'),
          subtitle: Text(dailyMeals['lunch']!),
        ),
      );
    }

    if (dailyMeals.containsKey('dinner') && dailyMeals['dinner']!.isNotEmpty) {
      meals.add(
        ListTile(
          leading: const Icon(Icons.restaurant, color: Colors.deepOrange),
          title: const Text('Dinner'),
          subtitle: Text(dailyMeals['dinner']!),
        ),
      );
    }

    if (dailyMeals.containsKey('snacks') && dailyMeals['snacks']!.isNotEmpty) {
      meals.add(
        ListTile(
          leading: const Icon(Icons.local_cafe, color: Colors.brown),
          title: const Text('Snacks'),
          subtitle: Text(dailyMeals['snacks']!),
        ),
      );
    }

    return meals;
  }
}
