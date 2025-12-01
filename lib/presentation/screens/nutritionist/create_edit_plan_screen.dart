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

  // The selected Client Object
  Client? _selectedClient;
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

    // Pre-fill text fields if editing
    if (widget.isEditing && widget.plan != null) {
      _nameController.text = widget.plan!.name;
      _descriptionController.text = widget.plan!.description;
      _selectedDuration = widget.plan!.duration;
      _loadMeals(widget.plan!.dailyMeals);
      // _selectedClient is set in _fetchClients to match the object reference
    }
  }

  void _loadMeals(Map<String, String> meals) {
    _breakfastController.text = meals['breakfast'] ?? '';
    _lunchController.text = meals['lunch'] ?? '';
    _dinnerController.text = meals['dinner'] ?? '';
    _snacksController.text = meals['snacks'] ?? '';
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

            // Logic to set _selectedClient based on the fetched list
            if (widget.isEditing && widget.plan != null) {
              // Find the client that matches the ID in the plan
              try {
                _selectedClient = _availableClients.firstWhere(
                  (c) => c.cid == widget.plan!.clientId,
                );
              } catch (e) {
                // Client might have been deleted
                _selectedClient = null;
              }
            } else if (widget.planClient != null) {
              // Find the client object that matches the passed client
              try {
                _selectedClient = _availableClients.firstWhere(
                  (c) => c.cid == widget.planClient!.cid,
                );
              } catch (e) {
                // Fallback if not found in list immediately
                _selectedClient = widget.planClient;
              }
            }
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

    // Check if the client object is selected
    if (_selectedClient == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a client')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nutritionistId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).uid!;

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
              // Update client details in case they changed in the dropdown
              clientId: _selectedClient!.cid,
              clientName: _selectedClient!.name,
            )
          : MealPlan(
              mid: DateTime.now().millisecondsSinceEpoch.toString(),
              nutritionistId: nutritionistId,
              clientId: _selectedClient!.cid, // Using the object's ID
              name: _nameController.text,
              clientName: _selectedClient!.name, // Using the object's Name
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
      Navigator.pop(context, true);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Plan' : 'Create Plan'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _savePlan,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plan Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildInput(_nameController, 'Plan Name', Icons.assignment),
              const SizedBox(height: 16),

              // Client Selection Dropdown using the Client Object
              _isLoadingClients
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Client>(
                      value: _selectedClient,
                      decoration: _inputDecoration(
                        'Select Client',
                        Icons.person,
                      ),
                      items: _availableClients.map((Client client) {
                        return DropdownMenuItem<Client>(
                          value: client,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (Client? newClient) {
                        setState(() {
                          _selectedClient = newClient;
                        });
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedDuration,
                decoration: _inputDecoration('Duration', Icons.timer),
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
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildInput(
                _descriptionController,
                'Description',
                Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              const Text(
                'Daily Meals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildInput(
                _breakfastController,
                'Breakfast',
                Icons.breakfast_dining,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildInput(
                _lunchController,
                'Lunch',
                Icons.lunch_dining,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildInput(
                _dinnerController,
                'Dinner',
                Icons.dinner_dining,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildInput(
                _snacksController,
                'Snacks',
                Icons.local_cafe,
                maxLines: 2,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'Update Plan' : 'Save Plan',
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

  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue[800]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
