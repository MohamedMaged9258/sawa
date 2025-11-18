// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/gym_provider.dart'; // Import static provider

class GymDetailsScreen extends StatefulWidget {
  // REMOVED: All parameters are gone. This screen is self-sufficient.
  const GymDetailsScreen({super.key});

  @override
  State<GymDetailsScreen> createState() => _GymDetailsScreenState();
}

class _GymDetailsScreenState extends State<GymDetailsScreen> {
  // --- STATE VARIABLES ---
  bool _isLoading = true;
  List<Gym> _gyms = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGyms();
  }

  /// Fetches the user's gyms from the static provider
  Future<void> _fetchGyms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty) {
        throw Exception("User is not logged in.");
      }
      
      final fetchedGyms = await GymProvider.fetchGymsByOwner(ownerId);
      
      setState(() {
        _gyms = fetchedGyms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Called from the EditGymDialog
  Future<void> _updateGym(Gym updatedGym) async {
    try {
      await GymProvider.updateGym(updatedGym);
      
      // Update the gym in the local list
      setState(() {
        final index = _gyms.indexWhere((gym) => gym.gid == updatedGym.gid);
        if (index != -1) {
          _gyms[index] = updatedGym;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gym updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update gym: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditDialog(int index) {
    print('Editing gym: ${_gyms[index].name}');
    showDialog(
      context: context,
      builder: (context) => EditGymDialog(
        gym: _gyms[index],
        onGymUpdated: (updatedGym) {
          // Pass the update to our stateful method
          _updateGym(updatedGym);
        },
      ),
    );
  }

  void _showDeleteDialog(int index) {
    final gymToDelete = _gyms[index];
    
    showDialog(
      context: context, // Uses the Screen's context
      // 1. RENAME context -> dialogContext to avoid confusion
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Gym'),
        content: Text('Are you sure you want to delete ${gymToDelete.name}?'),
        actions: [
          TextButton(
            // Use dialogContext to close the dialog
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // 2. Close the dialog first using dialogContext
              Navigator.pop(dialogContext);
              
              try {
                // Perform async delete
                await GymProvider.deleteGym(gymToDelete);
                
                // 3. SAFETY CHECK: Is the Screen still there?
                if (!mounted) return;
                
                // Update local state
                setState(() {
                  _gyms.removeAt(index);
                });
                
                // 4. Use 'context' (Screen), NOT 'dialogContext'
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gym deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Safety check before using context
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete gym: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    
    if (_gyms.isEmpty) {
       return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No gyms added yet'),
              SizedBox(height: 8),
              Text('Go to the dashboard to add a gym', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _gyms.length,
        itemBuilder: (context, index) {
          // Get gym from state
          return _buildGymCard(_gyms[index], index);
        },
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
                    // FIXED: Load image from network or show placeholder
                    image: DecorationImage(
                      image: (gym.photo.isNotEmpty
                              ? NetworkImage(gym.photo)
                              : const AssetImage('assets/gym_placeholder.jpg'))
                          as ImageProvider,
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
                    onPressed: () => _showEditDialog(index), // Use new method
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: () => _showDeleteDialog(index), // Use new method
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

// --- EditGymDialog (Slightly modified to pass back the full gym object) ---
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
                  // FIXED: Show the actual gym photo
                  image: DecorationImage(
                    image: (widget.gym.photo.isNotEmpty
                            ? NetworkImage(widget.gym.photo)
                            : const AssetImage('assets/gym_placeholder.jpg'))
                        as ImageProvider,
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
                        // Note: Photo changing in edit dialog is not
                        // implemented in the static provider yet.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo update not yet implemented.'))
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // ... (Form fields are unchanged)
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
              // FIXED: Use copyWith to preserve all unchanged data
              final updatedGym = widget.gym.copyWith(
                name: _nameController.text,
                location: _locationController.text,
                pricePerMonth: double.parse(_priceController.text),
                // Note: lat/long are not updated here,
                // this would require the location picker logic
              );
              
              widget.onGymUpdated(updatedGym);
              Navigator.pop(context);
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