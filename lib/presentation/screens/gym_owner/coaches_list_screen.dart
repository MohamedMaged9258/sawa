import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
class CoachesListScreen extends StatefulWidget {
  final List<Coach> coaches;
  final Function(Coach) onCoachAdded;
  
  final Function(int) onCoachDeleted;

  const CoachesListScreen({
    super.key,
    required this.coaches,
    required this.onCoachAdded,
    required this.onCoachDeleted,
  });

  @override
  State<CoachesListScreen> createState() => _CoachesListScreenState();
}

class _CoachesListScreenState extends State<CoachesListScreen> {
  void _addCoach() {
    print('Opening Add Coach screen');
    showDialog(
      context: context,
      builder: (context) => AddCoachDialog(
        onCoachAdded: (coach) {
          widget.onCoachAdded(coach);
        },
      ),
    );
  }

  void _deleteCoach(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coach'),
        content: Text('Are you sure you want to delete ${widget.coaches[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onCoachDeleted(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coach deleted successfully!'),
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
        title: const Text('Coaches List'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCoach,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCoach,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: widget.coaches.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No coaches added yet'),
                  SizedBox(height: 8),
                  Text('Tap the + button to add a coach', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.coaches.length,
              itemBuilder: (context, index) {
                return _buildCoachCard(widget.coaches[index], index);
              },
            ),
    );
  }

  Widget _buildCoachCard(Coach coach, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          backgroundImage: coach.photo.isNotEmpty 
              ? FileImage(coach.photo as dynamic)
              : null,
          child: coach.photo.isEmpty 
              ? const Icon(Icons.person, color: Colors.green)
              : null,
        ),
        title: Text(coach.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Experience: ${coach.experience}'),
            Text('Specialization: ${coach.specialization}'),
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

class AddCoachDialog extends StatefulWidget {
  final Function(Coach) onCoachAdded;

  const AddCoachDialog({super.key, required this.onCoachAdded});

  @override
  State<AddCoachDialog> createState() => _AddCoachDialogState();
}

class _AddCoachDialogState extends State<AddCoachDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  
  XFile? _selectedImage;

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
        print('Selected coach image: ${image.path}');
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
      title: const Text('Add New Coach'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Coach Photo
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
                      ? Image.file(
                          _selectedImage! as dynamic,
                          fit: BoxFit.cover,
                        )
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
              
              // Coach Name
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
              
              // Years of Experience
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
              
              // Specialization
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final coach = Coach(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                experience: '${_experienceController.text} years',
                photo: _selectedImage?.path ?? '',
                specialization: _specializationController.text,
                joinedDate: DateTime.now(),
              );
              
              print('Adding Coach:');
              print('Name: ${coach.name}');
              print('Experience: ${coach.experience}');
              print('Specialization: ${coach.specialization}');
              print('Photo: ${coach.photo}');
              
              widget.onCoachAdded(coach);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coach added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Add Coach'),
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