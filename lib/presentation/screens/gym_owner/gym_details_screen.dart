import 'package:flutter/material.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';

class GymDetailsScreen extends StatefulWidget {
  final List<Gym> gyms;
  final Function(Gym) onGymUpdated;
  final Function(int) onGymDeleted;

  const GymDetailsScreen({
    super.key,
    required this.gyms,
    required this.onGymUpdated,
    required this.onGymDeleted,
  });

  @override
  State<GymDetailsScreen> createState() => _GymDetailsScreenState();
}

class _GymDetailsScreenState extends State<GymDetailsScreen> {
  void _editGym(int index) {
    print('Editing gym: ${widget.gyms[index].name}');
    showDialog(
      context: context,
      builder: (context) => EditGymDialog(
        gym: widget.gyms[index],
        onGymUpdated: (updatedGym) {
          widget.onGymUpdated(updatedGym);
        },
      ),
    );
  }

  void _deleteGym(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gym'),
        content: Text('Are you sure you want to delete ${widget.gyms[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onGymDeleted(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gym deleted successfully!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gyms'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: widget.gyms.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No gyms added yet'),
                  SizedBox(height: 8),
                  Text('Tap "Add Gym" to get started', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.gyms.length,
              itemBuilder: (context, index) {
                return _buildGymCard(widget.gyms[index], index);
              },
            ),
    );
  }

  Widget _buildGymCard(Gym gym, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gym Photo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage('assets/gym_placeholder.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red[500], size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              gym.location,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green[700], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '\$${gym.pricePerMonth.toStringAsFixed(2)}/month',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Added: ${_formatDate(gym.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () => _editGym(index),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: () => _deleteGym(index),
                  ),
                ),
              ],
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

class EditGymDialog extends StatefulWidget {
  final Gym gym;
  final Function(Gym) onGymUpdated;

  const EditGymDialog({
    super.key,
    required this.gym,
    required this.onGymUpdated,
  });

  @override
  State<EditGymDialog> createState() => _EditGymDialogState();
}

class _EditGymDialogState extends State<EditGymDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gym.name);
    _locationController = TextEditingController(text: widget.gym.location);
    _priceController = TextEditingController(text: widget.gym.pricePerMonth.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Gym Details'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gym Photo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage('assets/gym_placeholder.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                      onPressed: () {
                        print('Changing gym photo');
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Gym Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Gym Name',
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
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () {
                      print('Opening Google Maps for location selection');
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter gym location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Month (\$)',
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
              final updatedGym = Gym(
                id: widget.gym.id,
                name: _nameController.text,
                location: _locationController.text,
                pricePerMonth: double.parse(_priceController.text),
                photo: widget.gym.photo,
                createdAt: widget.gym.createdAt,
              );
              
              print('Updating Gym:');
              print('Name: ${updatedGym.name}');
              print('Location: ${updatedGym.location}');
              print('Price: \$${updatedGym.pricePerMonth} per month');
              
              widget.onGymUpdated(updatedGym);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gym details updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Save Changes'),
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