// lib/presentation/screens/nutritionist/create_edit_plan_screen.dart
import 'package:flutter/material.dart';

class CreateEditPlanScreen extends StatefulWidget {
  final bool isEditing;
  final MealPlan? plan;

  const CreateEditPlanScreen({super.key, this.isEditing = false, this.plan});

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

  String? _selectedClient;
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
    if (widget.isEditing && widget.plan != null) {
      _nameController.text = widget.plan!.name;
      _descriptionController.text = widget.plan!.description;
      _selectedDuration = widget.plan!.duration;
      _selectedClient = widget.plan!.clientName;
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
          IconButton(icon: const Icon(Icons.save), onPressed: _savePlan),
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

              // Plan Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plan Name',
                  prefixIcon: Icon(Icons.assignment),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter plan name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Client Selection
              DropdownButtonFormField<String>(
                value: _selectedClient,
                decoration: const InputDecoration(
                  labelText: 'Select Client',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'John Doe', child: Text('John Doe')),
                  DropdownMenuItem(
                    value: 'Sarah Smith',
                    child: Text('Sarah Smith'),
                  ),
                  DropdownMenuItem(
                    value: 'Mike Johnson',
                    child: Text('Mike Johnson'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedClient = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a client';
                  }
                  return null;
                },
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
                items: _durations.map((String duration) {
                  return DropdownMenuItem<String>(
                    value: duration,
                    child: Text(duration),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDuration = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select duration';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Daily Meal Plan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Breakfast
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

              // Lunch
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

              // Dinner
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

              // Snacks
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

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePlan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple[700],
                  ),
                  child: Text(
                    widget.isEditing ? 'Update Plan' : 'Create Plan',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePlan() {
    if (_formKey.currentState!.validate()) {
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
      Navigator.pop(context);
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
}

class MealPlan {
  String id;
  String name;
  String clientName;
  String duration;
  String description;
  DateTime createdAt;

  MealPlan({
    required this.id,
    required this.name,
    required this.clientName,
    required this.duration,
    required this.description,
    required this.createdAt,
  });
}
