// lib/presentation/screens/restaurant_owner/add_restaurant_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';

class AddRestaurantScreen extends StatefulWidget {
  final Function(Restaurant) onRestaurantAdded;

  const AddRestaurantScreen({super.key, required this.onRestaurantAdded});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  XFile? _selectedImage;
  double? _selectedLatitude;
  double? _selectedLongitude;

  final List<String> _cuisineTypes = [
    'Italian',
    'Mexican',
    'Chinese',
    'Indian',
    'American',
    'Mediterranean',
    'Japanese',
    'Thai',
    'French',
    'Other'
  ];
  String? _selectedCuisineType;

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
        print('Selected restaurant image: ${image.path}');
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
        title: const Text('Enter Restaurant Address'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Restaurant'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Restaurant',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Restaurant Photo
              _buildPhotoSection(),
              const SizedBox(height: 20),
              
              // Restaurant Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter restaurant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cuisine Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCuisineType,
                decoration: const InputDecoration(
                  labelText: 'Cuisine Type',
                  prefixIcon: Icon(Icons.food_bank),
                  border: OutlineInputBorder(),
                ),
                items: _cuisineTypes.map((String cuisine) {
                  return DropdownMenuItem<String>(
                    value: cuisine,
                    child: Text(cuisine),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCuisineType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select cuisine type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Location Section
              _buildLocationSection(),
              const SizedBox(height: 16),
              
              // Price Range
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Average Price per Person (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter average price';
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newRestaurant = Restaurant(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text,
                        location: _locationController.text,
                        cuisineType: _selectedCuisineType!,
                        priceRange: double.parse(_priceController.text),
                        photo: _selectedImage?.path ?? '',
                        createdAt: DateTime.now(),
                        latitude: _selectedLatitude,
                        longitude: _selectedLongitude,
                      );
                      
                      print('Adding Restaurant:');
                      print('Name: ${newRestaurant.name}');
                      print('Cuisine: ${newRestaurant.cuisineType}');
                      print('Location: ${newRestaurant.location}');
                      print('Price Range: \$${newRestaurant.priceRange}');
                      
                      widget.onRestaurantAdded(newRestaurant);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Restaurant added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange[700],
                  ),
                  child: const Text(
                    'Add Restaurant',
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
          'Restaurant Photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
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
                      Icon(Icons.restaurant, size: 50, color: Colors.orange),
                      SizedBox(height: 8),
                      Text('Tap to add restaurant photo', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

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
            labelText: 'Restaurant Location',
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
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedLatitude != null 
                        ? 'GPS Coordinates: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}'
                        : 'Manual Address',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
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