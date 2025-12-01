import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/gym_provider.dart';

class AddGymScreen extends StatefulWidget {
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

  bool _isAdding = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _selectedImage = image);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.status;
    if (!status.isGranted) status = await Permission.location.request();

    if (status.isGranted) {
      try {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Getting location...')));
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _selectedLatitude = position.latitude;
          _selectedLongitude = position.longitude;
          _locationController.text =
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location found!'),
            backgroundColor: Colors.blue,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location error.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Permission required.')));
    }
  }

  Future<void> _openAddressInput() async {
    final TextEditingController addressController = TextEditingController(
      text: _locationController.text.contains(',')
          ? ''
          : _locationController.text,
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(hintText: 'Address'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Use GPS'),
              onPressed: () => Navigator.pop(context, 'current_location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, addressController.text.trim()),
            child: const Text('Use'),
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
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isAdding = true);

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty)
        throw Exception("User not logged in.");

      final newGym = Gym(
        gid: DateTime.now().millisecondsSinceEpoch.toString(),
        gymOwnerId: ownerId,
        name: _nameController.text,
        location: _locationController.text,
        pricePerMonth: double.parse(_priceController.text),
        photo: '',
        createdAt: DateTime.now(),
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );

      await GymProvider.addGym(newGym, _selectedImage);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gym added!'),
          backgroundColor: Colors.blue,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Gym'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gym Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in the information below',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              _buildPhotoSection(),
              const SizedBox(height: 24),

              _buildTextField(
                _nameController,
                'Gym Name',
                Icons.fitness_center,
              ),
              const SizedBox(height: 16),
              _buildLocationSection(),
              const SizedBox(height: 16),
              _buildTextField(
                _priceController,
                'Price / Month',
                Icons.attach_money,
                isNumber: true,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isAdding ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isAdding
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Gym',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue[100]!,
            width: 2,
          ), // Dashed look simulated
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 50,
                    color: Colors.blue[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Cover Photo',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[800]),
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

  Widget _buildLocationSection() {
    return Column(
      children: [
        TextFormField(
          controller: _locationController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Location',
            prefixIcon: Icon(Icons.location_on, color: Colors.blue[800]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _getCurrentLocation,
              color: Colors.blue[600],
            ),
          ),
          onTap: _openAddressInput,
          validator: (v) => v!.isEmpty ? 'Required' : null,
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
