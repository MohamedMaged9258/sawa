// lib/presentation/screens/restaurant_owner/meals_list_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';

class MealsListScreen extends StatefulWidget {
  final List<Meal> meals;
  final Function(Meal) onMealAdded;
  final Function(int) onMealDeleted;

  const MealsListScreen({
    super.key,
    required this.meals,
    required this.onMealAdded,
    required this.onMealDeleted,
  });

  @override
  State<MealsListScreen> createState() => _MealsListScreenState();
}

class _MealsListScreenState extends State<MealsListScreen> {
  void _addMeal() {
    print('Opening Add Meal screen');
    showDialog(
      context: context,
      builder: (context) => AddMealDialog(
        onMealAdded: (meal) {
          widget.onMealAdded(meal);
        },
      ),
    );
  }

  void _deleteMeal(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete ${widget.meals[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onMealDeleted(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meal deleted successfully!'),
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

  void _toggleMealAvailability(int index) {
    setState(() {
      widget.meals[index].isAvailable = !widget.meals[index].isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals List'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMeal,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeal,
        backgroundColor: Colors.orange[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: widget.meals.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fastfood, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No meals added yet'),
                  SizedBox(height: 8),
                  Text('Tap the + button to add a meal', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.meals.length,
              itemBuilder: (context, index) {
                return _buildMealCard(widget.meals[index], index);
              },
            ),
    );
  }

  Widget _buildMealCard(Meal meal, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          backgroundImage: meal.photo.isNotEmpty 
              ? FileImage(meal.photo as dynamic)
              : null,
          child: meal.photo.isEmpty 
              ? const Icon(Icons.fastfood, color: Colors.orange)
              : null,
        ),
        title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meal.description),
            Text(
              '\$${meal.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              'Category: ${meal.category}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Added: ${_formatDate(meal.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                meal.isAvailable ? Icons.check_circle : Icons.cancel,
                color: meal.isAvailable ? Colors.green : Colors.red,
              ),
              onPressed: () => _toggleMealAvailability(index),
              tooltip: meal.isAvailable ? 'Available' : 'Unavailable',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteMeal(index),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AddMealDialog extends StatefulWidget {
  final Function(Meal) onMealAdded;

  const AddMealDialog({super.key, required this.onMealAdded});

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  XFile? _selectedImage;
  final List<String> _categories = ['Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Side Dish'];
  String? _selectedCategory;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        print('Selected meal image: ${image.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Meal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Meal Photo
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage! as dynamic,
                          fit: BoxFit.cover,
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fastfood, size: 30, color: Colors.orange),
                            SizedBox(height: 4),
                            Text('Add Photo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Meal Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Meal Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter meal name';
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
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final meal = Meal(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                description: _descriptionController.text,
                price: double.parse(_priceController.text),
                category: _selectedCategory!,
                photo: _selectedImage?.path ?? '',
                isAvailable: true,
                createdAt: DateTime.now(),
              );
              
              print('Adding Meal:');
              print('Name: ${meal.name}');
              print('Description: ${meal.description}');
              print('Price: \$${meal.price}');
              print('Category: ${meal.category}');
              
              widget.onMealAdded(meal);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meal added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Add Meal'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}