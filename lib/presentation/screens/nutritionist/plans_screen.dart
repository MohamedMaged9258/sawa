// lib/presentation/screens/nutritionist/plans_screen.dart
import 'package:flutter/material.dart';
import 'create_edit_plan_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final List<MealPlan> _plans = [
    MealPlan(
      id: '1',
      name: 'Weight Loss Program',
      clientName: 'John Doe',
      duration: '1 Month',
      description: 'Focus on calorie deficit and protein intake',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    MealPlan(
      id: '2',
      name: 'Muscle Building Diet',
      clientName: 'Sarah Smith',
      duration: '3 Months',
      description: 'High protein, moderate carbs for muscle growth',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    MealPlan(
      id: '3',
      name: 'Healthy Eating Plan',
      clientName: 'Mike Johnson',
      duration: '2 Weeks',
      description: 'Balanced meals for overall health improvement',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEditPlanScreen(),
            ),
          );
        },
        backgroundColor: Colors.purple[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meal Plans',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Filter functionality
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                return _buildPlanCard(_plans[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(MealPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateEditPlanScreen(isEditing: true, plan: plan),
                        ),
                      );
                    } else if (value == 'delete') {
                      _deletePlan(plan.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Plan'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Plan'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Client: ${plan.clientName}'),
            const SizedBox(height: 4),
            Text('Duration: ${plan.duration}'),
            const SizedBox(height: 8),
            Text(plan.description, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(plan.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // View plan details
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Share plan
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                    ),
                    child: const Text(
                      'Share Plan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _deletePlan(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text('Are you sure you want to delete this meal plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _plans.removeWhere((plan) => plan.id == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Plan deleted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
