// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/restaurant_provider.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();

  XFile? _selectedImage;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedCuisineType;
  bool _isSubmitting = false;

  final List<String> _cuisineTypes = [
    'Italian',
    'Mexican',
    'Chinese',
    'Indian',
    'American',
    'Mediterranean',
    'Other',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null) throw Exception("User not logged in");

      final restaurant = Restaurant(
        rid: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: ownerId,
        name: _nameController.text,
        location: _locationController.text,
        cuisineType: _selectedCuisineType!,
        priceRange: double.parse(_priceController.text),
        photo: '', // Set by provider
        createdAt: DateTime.now(),
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );

      await RestaurantProvider.addRestaurant(restaurant, _selectedImage);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant added!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ... (Helper methods _pickImage, _getCurrentLocation, _openAddressInput remain exactly the same as your code)
  // I'm omitting them for brevity, but they should be copy-pasted here.

  Future<void> _pickImage() async {
    // ... (Same as your code)
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _getCurrentLocation() async {
    // ... (Same as your code, use Geolocator/Permission)
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLatitude = position.latitude;
        _selectedLongitude = position.longitude;
        _locationController.text =
            "${position.latitude}, ${position.longitude}";
      });
    }
  }

  // ignore: unused_element
  Future<void> _openAddressInput() async {
    // ... (Same as your code)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Restaurant'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.orange[50],
                  child: _selectedImage != null
                      ? Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.orange,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _selectedCuisineType,
                items: _cuisineTypes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCuisineType = v),
                decoration: const InputDecoration(
                  labelText: 'Cuisine',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Avg Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Restaurant',
                          style: TextStyle(color: Colors.white),
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
