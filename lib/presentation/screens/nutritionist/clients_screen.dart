import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/nutritionist_provider.dart';
import 'package:sawa/presentation/models/nutritionist_models.dart';
import '../nutritionist/create_edit_plan_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  bool _isLoading = true;
  List<Client> _clients = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final nutritionistId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).uid;
      if (nutritionistId == null || nutritionistId.isEmpty) {
        throw Exception("User is not logged in.");
      }

      final fetchedClients =
          await NutritionistProvider.fetchClientsByNutritionId(nutritionistId);

      if (!mounted) return;
      setState(() {
        _clients = fetchedClients;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreatePlan(Client client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditPlanScreen(planClient: client),
      ),
    );

    if (result == true) {
      _fetchClients(); // Refresh if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan created!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showAddClientDialog() async {
    // We await the result of the dialog (true if client added)
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddClientDialog(),
    );

    if (result == true) {
      _fetchClients(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClientDialog,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Clients',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading)
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    if (_error != null)
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    if (_clients.isEmpty)
      return Center(
        child: Text(
          'No clients found.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clients.length,
      itemBuilder: (context, index) {
        return _buildClientCard(_clients[index]);
      },
    );
  }

  Widget _buildClientCard(Client client) {
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      radius: 20,
                      child: Text(
                        client.name.isNotEmpty
                            ? client.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      client.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(client.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    client.status,
                    style: TextStyle(
                      color: _getStatusColor(client.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.email, client.email),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, client.phone),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.flag, client.goals),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCreatePlan(client),
                icon: const Icon(
                  Icons.assignment_add,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Create Meal Plan',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

// --- NEW DIALOG WIDGET ---

class AddClientDialog extends StatefulWidget {
  const AddClientDialog({super.key});

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final TextEditingController _goalsController = TextEditingController();

  List<Map<String, dynamic>> _availableMembers = [];
  bool _isLoadingMembers = true;
  String? _selectedMemberUid;

  @override
  void initState() {
    super.initState();
    _fetchAvailableMembers();
  }

  @override
  void dispose() {
    _goalsController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableMembers() async {
    try {
      // Fetch users with role 'member' from the provider
      final members = await NutritionistProvider.fetchAllMembers();
      if (mounted) {
        setState(() {
          _availableMembers = members;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading members: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedMemberUid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a member')));
      return;
    }

    try {
      final nutritionistId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).uid;
      if (nutritionistId == null) throw Exception("User not logged in");

      // Find selected member data
      final selectedMember = _availableMembers.firstWhere(
        (m) => m['uid'] == _selectedMemberUid,
      );

      final newClient = Client(
        cid: selectedMember['uid'], // Use member's UID as client ID
        nutritionistId: nutritionistId,
        name: selectedMember['name'], // From selected member
        email: selectedMember['email'], // From selected member
        phone: selectedMember['phone'], // From selected member
        goals: _goalsController.text, // From input
        status: 'Active',
        joinDate: DateTime.now(),
      );

      await NutritionistProvider.addClient(newClient);

      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add client: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Client'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Member",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _isLoadingMembers
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedMemberUid,
                    hint: const Text('Choose a member'),
                    items: _availableMembers.map((member) {
                      return DropdownMenuItem<String>(
                        value: member['uid'],
                        child: Text("${member['name']} (${member['email']})"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMemberUid = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            const Text("Goals", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _goalsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter client goals...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
          child: const Text(
            'Add Client',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
