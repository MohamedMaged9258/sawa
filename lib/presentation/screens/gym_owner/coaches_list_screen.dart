// lib/presentation/screens/gym_owner/coaches_list_screen.dart

// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

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
      _fetchCoaches();
    }
  }

  void _deleteCoach(int index) {
    final coachToDelete = _coaches[index];
    
    showDialog(
      context: context, 
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Coach'),
        content: Text('Are you sure you want to delete ${coachToDelete.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext); 
              try {
                await GymProvider.deleteCoach(coachToDelete);
                if (!mounted) return;
                setState(() {
                  _coaches.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coach deleted successfully!'), backgroundColor: Colors.blue),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete coach: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Coaches List'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCoachDialog,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.blue));
    if (_error != null) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));

    if (_coaches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.blue[200]),
            const SizedBox(height: 16),
            Text('No coaches added yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[50],
          backgroundImage: coach.photo.isNotEmpty ? NetworkImage(coach.photo) : null,
          child: coach.photo.isEmpty
              ? Icon(Icons.person, color: Colors.blue[300], size: 30)
              : null,
        ),
        title: Text(
          coach.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadge(Icons.star, coach.specialization, Colors.orange),
              const SizedBox(height: 4),
              _buildBadge(Icons.timeline, coach.experience, Colors.blue),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[400]),
          onPressed: () => _deleteCoach(index),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AddCoachDialog extends StatefulWidget {
  const AddCoachDialog({super.key});

  @override
  State<AddCoachDialog> createState() => _AddCoachDialogState();
}

class _AddCoachDialogState extends State<AddCoachDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();

  XFile? _selectedImage;
  bool _isAdding = false;
  bool _isGymListLoading = true;
  List<Gym> _availableGyms = [];
  String? _selectedGymId;
  String? _ownerId;

  @override
  void initState() {
    super.initState();
    _fetchAvailableGyms();
  }

  Future<void> _fetchAvailableGyms() async {
    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId == null || ownerId.isEmpty) {
        throw Exception("User not logged in.");
      }
      _ownerId = ownerId;
      final gyms = await GymProvider.fetchGymsByOwner(ownerId);
      setState(() {
        _availableGyms = gyms;
        _isGymListLoading = false;
      });
    } catch (e) {
      setState(() => _isGymListLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load gyms: $e')));
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _submitAddCoach() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGymId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a gym.')));
      return;
    }
    setState(() => _isAdding = true);

    try {
      if (_ownerId == null) throw Exception("User not logged in");
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coach added!'), backgroundColor: Colors.blue));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isAdding = false);
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
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(45), child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover))
                      : Icon(Icons.add_a_photo, color: Colors.blue[800]),
                ),
              ),
              const SizedBox(height: 16),
              _isGymListLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedGymId,
                      decoration: InputDecoration(
                        labelText: 'Assign to Gym',
                        filled: true, fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: _availableGyms.map((gym) => DropdownMenuItem(value: gym.gid, child: Text(gym.name))).toList(),
                      onChanged: (val) => setState(() => _selectedGymId = val),
                    ),
              const SizedBox(height: 12),
              _buildInput(_nameController, 'Coach Name'),
              const SizedBox(height: 12),
              _buildInput(_experienceController, 'Years Experience', isNumber: true),
              const SizedBox(height: 12),
              _buildInput(_specializationController, 'Specialization'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
          onPressed: _isAdding ? null : _submitAddCoach,
          child: _isAdding ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Add Coach', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true, fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
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