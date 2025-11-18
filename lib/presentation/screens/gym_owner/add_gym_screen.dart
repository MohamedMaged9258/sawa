// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io'; // Import 'dart:io' for File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/gym_provider.dart'; // Import static provider

class AddGymScreen extends StatefulWidget {
  // REMOVED: onGymAdded callback is no longer needed
  const AddGymScreen({super.key});

  @override
  State<AddGymScreen> createState() => _AddGymScreenState();
}

class _AddGymScreenState extends State<AddGymScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  XFile? _selectedImage;
  double? _selectedLatitude;
  double? _selectedLongitude;
  
  bool _isAdding = false; // State for loading indicator

  // --- _pickImage, _getCurrentLocation, _openAddressInput methods ---
  // --- are unchanged. ---

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        print('Selected image: ${image.path}');
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

  Future<void> _getCurrentLocation() async {
    // Check location permission
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
    
    if (status.isGranted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Getting your location...')),
        );

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _selectedLatitude = position.latitude;
          _selectedLongitude = position.longitude;
          _locationController.text = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });

        print('Selected location: $_selectedLatitude, $_selectedLongitude');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location selected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error getting location: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get location. Please enable location services.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required to select your location.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openAddressInput() async {
    final TextEditingController addressController = TextEditingController(
      text: _locationController.text.contains(',') ? '' : _locationController.text
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Gym Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                hintText: 'Enter full address (street, city, country)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Use current location'),
              onPressed: () {
                Navigator.pop(context, 'current_location');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (addressController.text.trim().isNotEmpty) {
                Navigator.pop(context, addressController.text.trim());
              }
            },
            child: const Text('Use Address'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result == 'current_location') {
        _getCurrentLocation();
      } else {
        setState(() {
          _locationController.text = result;
          _selectedLatitude = null;
          _selectedLongitude = null;
        });
        print('Manual address entered: $result');
      }
    }
  }
  
  /// Submits the form, calls the static provider, and handles state.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is invalid
    }
    
    setState(() {
      _isAdding = true;
    });

    try {
      // Get the current user's ID
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty) {
        throw Exception("You must be logged in to add a gym.");
      }

      // Create the Gym object
      final newGym = Gym(
        gid: DateTime.now().millisecondsSinceEpoch.toString(),
        gymOwnerId: ownerId, // Set the ownerId
        name: _nameController.text,
        location: _locationController.text,
        pricePerMonth: double.parse(_priceController.text),
        photo: '', // Will be set by the provider
        createdAt: DateTime.now(),
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );
      
      print('Adding Gym...');
      
      // Call the static provider method
      await GymProvider.addGym(newGym, _selectedImage);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gym added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context); // Go back to the home screen

    } catch (e) {
      print("Failed to add gym: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add gym: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Ensure loading state is reset even if an error occurs
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Gym'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (All form fields are unchanged)
              const Text(
                'Add New Gym',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Gym Photo
              _buildPhotoSection(),
              const SizedBox(height: 20),
              
              // Gym Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Gym Name',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter gym name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Location Section
              _buildLocationSection(),
              const SizedBox(height: 16),
              
              // Price per Month
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Month (\$)',
                  prefixIcon: Icon(Icons.attach_money),
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
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAdding ? null : _submitForm, // Disable when loading
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green[700],
                  ),
                  child: _isAdding
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Add Gym',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gym Photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            // FIXED: Use File(_selectedImage!.path)
            child: _selectedImage != null
                ? Image.file(
                    File(_selectedImage!.path), // Convert XFile to File
                    fit: BoxFit.cover,
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 50, color: Colors.green),
                      SizedBox(height: 8),
                      Text('Tap to add gym photo', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ... (_buildLocationSection and dispose methods are unchanged)
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Gym Location',
            prefixIcon: const Icon(Icons.location_on),
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                  tooltip: 'Use current location',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_location),
                  onPressed: _openAddressInput,
                  tooltip: 'Enter address manually',
                ),
              ],
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a location';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        if (_locationController.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.green[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedLatitude != null 
                        ? 'GPS Coordinates: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}'
                        : 'Manual Address',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}