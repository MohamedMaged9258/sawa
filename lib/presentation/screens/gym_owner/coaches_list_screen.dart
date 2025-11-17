import 'package:flutter/material.dart';

class CoachesListScreen extends StatefulWidget {
  const CoachesListScreen({super.key});

  @override
  State<CoachesListScreen> createState() => _CoachesListScreenState();
}

class _CoachesListScreenState extends State<CoachesListScreen> {
  final List<Coach> _coaches = [
    Coach('John Smith', '5 years', 'assets/coach1.jpg'),
    Coach('Sarah Johnson', '3 years', 'assets/coach2.jpg'),
    Coach('Mike Davis', '7 years', 'assets/coach3.jpg'),
  ];

  void _addCoach() {
    print('Navigating to Add Coach screen');
    // In real app, you'd navigate to AddCoachScreen
    showDialog(
      context: context,
      builder: (context) => AddCoachDialog(
        onCoachAdded: (coach) {
          setState(() {
            _coaches.add(coach);
          });
        },
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
      body: _coaches.isEmpty
          ? const Center(
              child: Text('No coaches added yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _coaches.length,
              itemBuilder: (context, index) {
                return _buildCoachCard(_coaches[index]);
              },
            ),
    );
  }

  Widget _buildCoachCard(Coach coach) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: const Icon(Icons.person, color: Colors.green),
        ),
        title: Text(coach.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Experience: ${coach.experience}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          print('Viewing coach profile: ${coach.name}');
        },
      ),
    );
  }
}

class Coach {
  final String name;
  final String experience;
  final String photo;

  Coach(this.name, this.experience, this.photo);
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
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_a_photo, size: 30),
                  onPressed: () {
                    print('Opening photo picker for coach photo');
                  },
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
                _nameController.text,
                '${_experienceController.text} years',
                'assets/coach_photo.jpg',
              );
              
              print('Adding Coach:');
              print('Name: ${_nameController.text}');
              print('Experience: ${_experienceController.text} years');
              print('Photo: Selected coach photo');
              
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
    super.dispose();
  }
}