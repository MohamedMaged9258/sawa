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
    final result = await showDialog(
      context: context,
      builder: (context) => const AddMealDialog(),
    );
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Meals'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMealDialog,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[800]))
          : _meals.isEmpty
          ? Center(
              child: Text(
                "No meals added",
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _meals.length,
              itemBuilder: (context, index) {
                final meal = _meals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        image: meal.photo.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(meal.photo),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: meal.photo.isEmpty
                          ? Icon(Icons.fastfood, color: Colors.blue[300])
                          : null,
                    ),
                    title: Text(
                      meal.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('\$${meal.price} • ${meal.category}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            meal.isAvailable
                                ? Icons.check_circle
                                : Icons.do_not_disturb_on,
                            color: meal.isAvailable
                                ? Colors.green
                                : Colors.grey[400],
                          ),
                          onPressed: () => _toggleAvailability(meal),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[400],
                          ),
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

  final List<String> _categories = [
    'Appetizer',
    'Main Course',
    'Dessert',
    'Beverage',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
    if (ownerId != null) {
      final data = await RestaurantProvider.fetchRestaurantsByOwner(ownerId);
      if (mounted)
        setState(() {
          _restaurants = data;
          _isLoadingRestaurants = false;
        });
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
                  final img = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (img != null) setState(() => _image = img);
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[100]!),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(File(_image!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _image == null
                      ? Icon(Icons.add_a_photo, color: Colors.blue[300])
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              _isLoadingRestaurants
                  ? const CircularProgressIndicator()
                  : _buildDropdown(
                      _selectedRestaurantId,
                      'Restaurant',
                      _restaurants
                          .map(
                            (r) => DropdownMenuItem(
                              value: r.rid,
                              child: Text(r.name),
                            ),
                          )
                          .toList(),
                      (v) => setState(() => _selectedRestaurantId = v),
                    ),
              const SizedBox(height: 12),
              _buildInput(_nameController, 'Name'),
              const SizedBox(height: 12),
              _buildInput(_descController, 'Description'),
              const SizedBox(height: 12),
              _buildInput(_priceController, 'Price', isNumber: true),
              const SizedBox(height: 12),
              _buildDropdown(
                _category,
                'Category',
                _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                (v) => setState(() => _category = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
          onPressed: _submit,
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildDropdown(
    dynamic val,
    String label,
    List<DropdownMenuItem<dynamic>> items,
    Function(dynamic) onChanged,
  ) {
    return DropdownButtonFormField(
      value: val,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
    );
  }
}
