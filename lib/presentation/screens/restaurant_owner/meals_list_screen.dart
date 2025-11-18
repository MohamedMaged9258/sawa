// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/restaurant_provider.dart';

class MealsListScreen extends StatefulWidget {
  const MealsListScreen({super.key});

  @override
  State<MealsListScreen> createState() => _MealsListScreenState();
}

class _MealsListScreenState extends State<MealsListScreen> {
  List<Meal> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    setState(() => _isLoading = true);
    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId != null) {
        final data = await RestaurantProvider.fetchMealsByOwner(ownerId);
        setState(() => _meals = data);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddMealDialog() async {
    final result = await showDialog(context: context, builder: (context) => const AddMealDialog());
    if (result == true) _fetchMeals();
  }

  void _deleteMeal(Meal meal) async {
    await RestaurantProvider.deleteMeal(meal);
    _fetchMeals();
  }

  void _toggleAvailability(Meal meal) async {
    await RestaurantProvider.toggleMealAvailability(meal);
    _fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meals'), backgroundColor: Colors.orange[700], foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(onPressed: _showAddMealDialog, backgroundColor: Colors.orange[700], child: const Icon(Icons.add, color: Colors.white)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _meals.length,
            itemBuilder: (context, index) {
              final meal = _meals[index];
              return Card(
                child: ListTile(
                  leading: meal.photo.isNotEmpty ? CircleAvatar(backgroundImage: NetworkImage(meal.photo)) : const Icon(Icons.fastfood),
                  title: Text(meal.name),
                  subtitle: Text('\$${meal.price} - ${meal.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(meal.isAvailable ? Icons.check_circle : Icons.cancel, color: meal.isAvailable ? Colors.green : Colors.grey),
                        onPressed: () => _toggleAvailability(meal),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMeal(meal),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}

// --- Add Meal Dialog ---
class AddMealDialog extends StatefulWidget {
  const AddMealDialog({super.key});

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String? _category;
  String? _selectedRestaurantId;
  XFile? _image;
  List<Restaurant> _restaurants = [];
  bool _isLoadingRestaurants = true;

  final List<String> _categories = ['Appetizer', 'Main Course', 'Dessert', 'Beverage'];

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
    if (ownerId != null) {
      final data = await RestaurantProvider.fetchRestaurantsByOwner(ownerId);
      if (mounted) setState(() { _restaurants = data; _isLoadingRestaurants = false; });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRestaurantId == null) return;

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid!;
      final meal = Meal(
        mid: DateTime.now().millisecondsSinceEpoch.toString(),
        restaurantId: _selectedRestaurantId!,
        ownerId: ownerId,
        name: _nameController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        category: _category!,
        photo: '',
        isAvailable: true,
        createdAt: DateTime.now(),
      );
      await RestaurantProvider.addMeal(meal, _image);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Meal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (img != null) setState(() => _image = img);
                },
                child: _image == null 
                  ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                  : Image.file(File(_image!.path), height: 100, width: 100, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              _isLoadingRestaurants 
                ? const CircularProgressIndicator()
                : DropdownButtonFormField(
                    value: _selectedRestaurantId,
                    decoration: const InputDecoration(labelText: 'Assign to Restaurant'),
                    items: _restaurants.map((r) => DropdownMenuItem(value: r.rid, child: Text(r.name))).toList(),
                    onChanged: (v) => setState(() => _selectedRestaurantId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              DropdownButtonFormField(
                value: _category,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v),
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v == null ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}