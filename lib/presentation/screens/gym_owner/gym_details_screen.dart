// lib/presentation/screens/gym_owner/gym_details_screen.dart
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/gym_provider.dart'; 

class GymDetailsScreen extends StatefulWidget {
  const GymDetailsScreen({super.key});

  @override
  State<GymDetailsScreen> createState() => _GymDetailsScreenState();
}

class _GymDetailsScreenState extends State<GymDetailsScreen> {
  bool _isLoading = true;
  List<Gym> _gyms = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGyms();
  }

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

  Future<void> _updateGym(Gym updatedGym) async {
    try {
      await GymProvider.updateGym(updatedGym);
      setState(() {
        final index = _gyms.indexWhere((gym) => gym.gid == updatedGym.gid);
        if (index != -1) {
          _gyms[index] = updatedGym;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gym updated successfully!'), backgroundColor: Colors.blue),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update gym: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => EditGymDialog(
        gym: _gyms[index],
        onGymUpdated: (updatedGym) => _updateGym(updatedGym),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    final gymToDelete = _gyms[index];
    showDialog(
      context: context, 
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Gym'),
        content: Text('Are you sure you want to delete ${gymToDelete.name}?'),
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
                await GymProvider.deleteGym(gymToDelete);
                if (!mounted) return;
                setState(() {
                  _gyms.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gym deleted successfully!'), backgroundColor: Colors.blue),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete gym: $e'), backgroundColor: Colors.red),
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
        title: const Text('My Gyms'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.blue));
    if (_error != null) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));
    
    if (_gyms.isEmpty) {
       return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, size: 80, color: Colors.blue[200]),
              const SizedBox(height: 16),
              Text('No gyms added yet', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Go to the dashboard to add a gym', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        );
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _gyms.length,
        itemBuilder: (context, index) {
          return _buildGymCard(_gyms[index], index);
        },
      );
  }

  Widget _buildGymCard(Gym gym, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.blue[50]),
              child: gym.photo.isNotEmpty
                  ? Image.network(gym.photo, fit: BoxFit.cover)
                  : Icon(Icons.fitness_center, size: 50, color: Colors.blue[200]),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        gym.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '\$${gym.pricePerMonth.toStringAsFixed(0)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(gym.location, style: TextStyle(color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue[800]),
                      onPressed: () => _showEditDialog(index),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red[400]),
                      onPressed: () => _showDeleteDialog(index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  const EditGymDialog({super.key, required this.gym, required this.onGymUpdated});

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
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[50],
                  image: widget.gym.photo.isNotEmpty 
                    ? DecorationImage(image: NetworkImage(widget.gym.photo), fit: BoxFit.cover)
                    : null
                ),
                child: widget.gym.photo.isEmpty ? Icon(Icons.image, color: Colors.blue[200]) : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Gym Name',
                  filled: true, fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  filled: true, fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  filled: true, fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedGym = widget.gym.copyWith(
                name: _nameController.text,
                location: _locationController.text,
                pricePerMonth: double.parse(_priceController.text),
              );
              widget.onGymUpdated(updatedGym);
              Navigator.pop(context);
            }
          },
          child: const Text('Save', style: TextStyle(color: Colors.white)),
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