// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/gym_provider.dart';

class CoachesListScreen extends StatefulWidget {
  const CoachesListScreen({super.key});

  @override
  State<CoachesListScreen> createState() => _CoachesListScreenState();
}

class _CoachesListScreenState extends State<CoachesListScreen> {
  bool _isLoading = true;
  List<Coach> _coaches = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCoaches();
  }

  Future<void> _fetchCoaches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty) {
        throw Exception("User is not logged in.");
      }
      final fetchedCoaches = await GymProvider.fetchCoachesByOwner(ownerId);
      setState(() {
        _coaches = fetchedCoaches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddCoachDialog() async {
    final bool? coachWasAdded = await showDialog<bool>(
      context: context,
      builder: (context) => const AddCoachDialog(),
    );

    if (coachWasAdded == true) {
      _fetchCoaches(); // Refresh the list
    }
  }

  void _deleteCoach(int index) {
    final coachToDelete = _coaches[index];
    
    showDialog(
      context: context, // 1. This uses the Screen's context
      builder: (dialogContext) => AlertDialog( // 2. Rename this to avoid confusion!
        title: const Text('Delete Coach'),
        content: Text('Are you sure you want to delete ${coachToDelete.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Close using dialogContext
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(dialogContext); 
              
              try {
                // Perform the async delete
                await GymProvider.deleteCoach(coachToDelete);
                
                // 3. Safety check: Is the SCREEN still mounted?
                if (!mounted) return;
                
                setState(() {
                  _coaches.removeAt(index);
                });
                
                // 4. Use 'context' (Screen), NOT 'dialogContext' (Dialog)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coach deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete coach: $e'),
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
        title: const Text('Coaches List'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCoachDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCoachDialog,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
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

    if (_coaches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No coaches added yet'),
            SizedBox(height: 8),
            Text('Tap the + button to add a coach',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _coaches.length,
      itemBuilder: (context, index) {
        return _buildCoachCard(_coaches[index], index);
      },
    );
  }

  Widget _buildCoachCard(Coach coach, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          backgroundImage:
              coach.photo.isNotEmpty ? NetworkImage(coach.photo) : null,
          child: coach.photo.isEmpty
              ? const Icon(Icons.person, color: Colors.green)
              : null,
        ),
        title:
            Text(coach.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Experience: ${coach.experience}'),
            Text('Specialization: ${coach.specialization}'),
            Text('Gym ID: ${coach.gymId}', style: const TextStyle(fontSize: 12)),
            Text(
              'Joined: ${_formatDate(coach.joinedDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteCoach(index),
        ),
        onTap: () {
          print('Viewing coach profile: ${coach.name}');
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// --- AddCoachDialog (Refactored with Gym Dropdown) ---
class AddCoachDialog extends StatefulWidget {
  const AddCoachDialog({super.key});

  @override
  State<AddCoachDialog> createState() => _AddCoachDialogState();
}

class _AddCoachDialogState extends State<AddCoachDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();

  XFile? _selectedImage;
  bool _isAdding = false;

  // --- NEW STATE for gym dropdown ---
  bool _isGymListLoading = true;
  List<Gym> _availableGyms = [];
  String? _selectedGymId;
  String? _ownerId;

  @override
  void initState() {
    super.initState();
    _fetchAvailableGyms();
  }

  /// Fetches the user's gyms to populate the dropdown
  Future<void> _fetchAvailableGyms() async {
    try {
      // Use your AuthProvider to get the logged-in user's ID
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty) {
        throw Exception("User not logged in.");
      }
      _ownerId = ownerId; // Save ownerId for submission
      
      final gyms = await GymProvider.fetchGymsByOwner(ownerId);
      
      setState(() {
        _availableGyms = gyms;
        _isGymListLoading = false;
      });
    } catch (e) {
      print("Error fetching gyms for dialog: $e");
      setState(() {
        _isGymListLoading = false;
      });
      // Optionally show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load gyms: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _submitAddCoach() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGymId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a gym.'), backgroundColor: Colors.red));
      return;
    }

    setState(() { _isAdding = true; });

    try {
      if (_ownerId == null) throw Exception("You must be logged in to add a coach.");

      final coach = Coach(
        cid: DateTime.now().millisecondsSinceEpoch.toString(),
        gymId: _selectedGymId!,
        ownerId: _ownerId!,
        name: _nameController.text,
        experience: '${_experienceController.text} years',
        photo: '',
        specialization: _specializationController.text,
        joinedDate: DateTime.now(),
      );

      await GymProvider.addCoach(coach, _selectedImage);

      // ⚠️ SAFETY CHECK: If dialog was closed while loading, stop here.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coach added successfully!'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return; // Safety check before using context
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add coach: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() { _isAdding = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Coach'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add, size: 30, color: Colors.green),
                            SizedBox(height: 4),
                            Text('Add Photo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // --- NEW: Gym Selection Dropdown ---
              _isGymListLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedGymId,
                      hint: const Text('Select a Gym'),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Assign to Gym',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableGyms.map((gym) {
                        return DropdownMenuItem(
                          value: gym.gid, // Use the gym's ID
                          child: Text(gym.name), // Show the gym's name
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGymId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a gym';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Coach Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter coach name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter years of experience';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter specialization';
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
          onPressed: _isAdding ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isAdding ? null : _submitAddCoach,
          child: _isAdding
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Add Coach'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    _specializationController.dispose();
    super.dispose();
  }
}