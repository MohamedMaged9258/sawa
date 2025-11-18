// lib/presentation/screens/nutritionist/plans_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/nutritionist_provider.dart';
import 'package:sawa/presentation/models/nutritionist_models.dart';
import 'create_edit_plan_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  // State for data management
  List<MealPlan> _plans = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final nutritionistId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (nutritionistId == null || nutritionistId.isEmpty) throw Exception("User not logged in.");
      
      final fetchedPlans = await NutritionistProvider.fetchPlansByNutritionist(nutritionistId);
      
      if (!mounted) return;
      setState(() {
        _plans = fetchedPlans;
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

  Future<void> _navigateOrCreatePlan({MealPlan? plan, bool isEditing = false}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditPlanScreen(isEditing: isEditing, plan: plan),
      ),
    );
    // If the creation/editing was successful (popped with true), refresh the list
    if (result == true) {
      _fetchPlans();
    }
  }

  // Inside _PlansScreenState (plans_screen.dart)

void _deletePlan(String mid) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog( // Renaming context here is important
        title: const Text('Delete Plan'),
        content: const Text('Are you sure you want to delete this meal plan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              
              try {
                await NutritionistProvider.deletePlan(mid);
                
                // ⚠️ CRITICAL SAFETY CHECK
                if (!mounted) return; 
                
                setState(() {
                  _plans.removeWhere((plan) => plan.mid == mid);
                });
                
                // Use the screen's context for SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan deleted successfully!'), backgroundColor: Colors.green)
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete plan: $e'), backgroundColor: Colors.red)
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateOrCreatePlan(),
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
                const Text('Meal Plans', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error loading plans: $_error'));
    if (_plans.isEmpty) return const Center(child: Text('No meal plans created yet.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        return _buildPlanCard(_plans[index]);
      },
    );
  }

  Widget _buildPlanCard(MealPlan mealPlan) {
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
                Text(mealPlan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateOrCreatePlan(plan: mealPlan, isEditing: true);
                    } else if (value == 'delete') {
                      _deletePlan(mealPlan.mid);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Plan')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete Plan'),)
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Client: ${mealPlan.clientName}'),
            const SizedBox(height: 4),
            Text('Duration: ${mealPlan.duration}'),
            const SizedBox(height: 8),
            Text(mealPlan.description, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Created: ${_formatDate(mealPlan.createdAt)}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 12),
            // ... (Buttons remain the same)
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}