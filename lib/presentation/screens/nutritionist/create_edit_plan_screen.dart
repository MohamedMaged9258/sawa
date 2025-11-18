// lib/presentation/screens/nutritionist/create_edit_plan_screen.dart
// Note: This file now manages its own state for saving the plan.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/nutritionist_provider.dart';
import 'package:sawa/presentation/models/nutritionist_models.dart';

class CreateEditPlanScreen extends StatefulWidget {
  final bool isEditing;
  final MealPlan? plan;
  final Client? planClient;

  const CreateEditPlanScreen({
    super.key,
    this.isEditing = false,
    this.plan,
    this.planClient,
  });

  @override
  State<CreateEditPlanScreen> createState() => _CreateEditPlanScreenState();
}

class _CreateEditPlanScreenState extends State<CreateEditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  final TextEditingController _snacksController = TextEditingController();

  // State for data fetching
  List<Client> _availableClients = [];
  bool _isLoadingClients = true;
  bool _isSaving = false;

  String? _selectedClientName;
  String? _selectedClientId; // NEW: Actual ID for linking
  String? _selectedDuration;

  final List<String> _durations = [
    '1 Week',
    '2 Weeks',
    '1 Month',
    '3 Months',
    '6 Months',
  ];

  @override
  void initState() {
    super.initState();
    _fetchClients();
    if (widget.isEditing && widget.plan != null) {
      _nameController.text = widget.plan!.name;
      _descriptionController.text = widget.plan!.description;
      _selectedDuration = widget.plan!.duration;
      _selectedClientName = widget.plan!.clientName;
      _selectedClientId = widget.plan!.clientId;
      // Load daily meals (if implemented)
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _snacksController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    try {
      final nutritionistId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).uid;
      if (nutritionistId != null) {
        final clients = await NutritionistProvider.fetchClientsByNutritionId(
          nutritionistId,
        );
        if (mounted) {
          setState(() {
            _availableClients = clients;
            _isLoadingClients = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingClients = false;
        });
        print('Error fetching clients for plan: $e');
      }
    }
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) return;

    setState(() => _isSaving = true);

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid!;

      final Map<String, String> dailyMeals = {
        'breakfast': _breakfastController.text,
        'lunch': _lunchController.text,
        'dinner': _dinnerController.text,
        'snacks': _snacksController.text,
      };

      final MealPlan planToSave = widget.isEditing
          ? widget.plan!.copyWith(
              name: _nameController.text,
              description: _descriptionController.text,
              duration: _selectedDuration,
              dailyMeals: dailyMeals,
            )
          : MealPlan(
              mid: DateTime.now().millisecondsSinceEpoch.toString(),
              nutritionistId: ownerId,
              clientId: _selectedClientId!,
              name: _nameController.text,
              clientName: _selectedClientName!,
              duration: _selectedDuration!,
              description: _descriptionController.text,
              createdAt: DateTime.now(),
              dailyMeals: dailyMeals,
            );

      if (widget.isEditing) {
        await NutritionistProvider.updatePlan(planToSave);
      } else {
        await NutritionistProvider.addPlan(planToSave);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Plan updated successfully!'
                : 'Plan created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Pop with 'true' to signal success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Meal Plan' : 'Create Meal Plan'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _savePlan,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meal Plan Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plan Name',
                  prefixIcon: Icon(Icons.assignment),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter plan name' : null,
              ),
              const SizedBox(height: 16),

              // Client Selection Dropdown
              _isLoadingClients
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedClientName,
                      decoration: const InputDecoration(
                        labelText: 'Select Client',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      items: _availableClients.map((client) {
                        return DropdownMenuItem<String>(
                          value: client.name,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedClientName = newValue;
                          // Find the corresponding Client ID
                          _selectedClientId = _availableClients
                              .firstWhere((c) => c.name == newValue)
                              .cid;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a client'
                          : null,
                      // Disable selection when editing, as client link shouldn't change
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      // enabled: !widget.isEditing,
                    ),
              const SizedBox(height: 16),

              // Duration
              DropdownButtonFormField<String>(
                value: _selectedDuration,
                decoration: const InputDecoration(
                  labelText: 'Plan Duration',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: _durations
                    .map(
                      (String duration) => DropdownMenuItem<String>(
                        value: duration,
                        child: Text(duration),
                      ),
                    )
                    .toList(),
                onChanged: (String? newValue) =>
                    setState(() => _selectedDuration = newValue),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select duration'
                    : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    v!.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'Daily Meal Plan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Daily Meals
              TextFormField(
                controller: _breakfastController,
                decoration: const InputDecoration(
                  labelText: 'Breakfast',
                  prefixIcon: Icon(Icons.breakfast_dining),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lunchController,
                decoration: const InputDecoration(
                  labelText: 'Lunch',
                  prefixIcon: Icon(Icons.lunch_dining),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dinnerController,
                decoration: const InputDecoration(
                  labelText: 'Dinner',
                  prefixIcon: Icon(Icons.dinner_dining),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _snacksController,
                decoration: const InputDecoration(
                  labelText: 'Snacks',
                  prefixIcon: Icon(Icons.local_cafe),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Save Button (Again)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePlan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple[700],
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isEditing ? 'Update Plan' : 'Create Plan',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
