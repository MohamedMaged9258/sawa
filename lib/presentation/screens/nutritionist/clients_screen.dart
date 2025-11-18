// lib/presentation/screens/nutritionist/clients_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/nutritionist_provider.dart';
import 'package:sawa/presentation/models/nutritionist_models.dart';
// Note: client_details_screen.dart is no longer directly used for navigation
import '../nutritionist/create_edit_plan_screen.dart'; // Import the target screen

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  // --- STATE VARIABLES ---
  bool _isLoading = true;
  List<Client> _clients = [];
  String? _error;

  // Text controllers for the Add Client dialog (moved here for cleanup)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  /// Fetches the user's clients from the static provider
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

      if (!mounted) return; // ⚠️ SAFETY CHECK before setState
      setState(() {
        _clients = fetchedClients;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // ⚠️ SAFETY CHECK
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAddClient(BuildContext dialogContext) async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) return;

    try {
      final nutritionistId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).uid;
      if (nutritionistId == null || nutritionistId.isEmpty) {
        throw Exception("User is not logged in.");
      }

      final newClient = Client(
        cid: DateTime.now().millisecondsSinceEpoch.toString(),
        nutritionistId: nutritionistId,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        goals: _goalsController.text,
        status: 'Active',
        joinDate: DateTime.now(),
      );

      await NutritionistProvider.addClient(newClient);

      // ⚠️ CRITICAL SAFETY CHECK BEFORE CONTEXT/STATE USE
      if (!mounted) return;

      // Clear fields and close dialog immediately on success
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _goalsController.clear();

      // Use dialogContext to pop (this is safe)
      Navigator.pop(dialogContext);

      // Use the screen's context for SnackBar (SAFE NOW)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the client list
      _fetchClients();
    } catch (e) {
      // Use dialog context for error if still mounted (best effort)
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(
          content: Text('Failed to add client: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // REMOVED: _navigateToClientDetails method as it is no longer used.

  Future<void> _navigateToCreatePlan(Client client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // The parameter is renamed to planClient to avoid conflict with 'plan'
        builder: (context) => CreateEditPlanScreen(planClient: client),
      ),
    );

    // If a plan was successfully created, refresh the client list (if status updates)
    if (result == true) {
      _fetchClients();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan created! Refreshing client list.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _goalsController,
              decoration: const InputDecoration(
                labelText: 'Goals',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                _submitAddClient(dialogContext), // Pass the dialog context
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
            ),
            child: const Text(
              'Add Client',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- BUILD METHODS (Updated for Loading/Error States) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClientDialog,
        backgroundColor: Colors.purple[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Clients',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(icon: Icon(Icons.search), onPressed: null),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error loading clients: $_error'));
    }
    if (_clients.isEmpty) {
      return const Center(child: Text('No clients found. Add a new one!'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clients.length,
      itemBuilder: (context, index) {
        return _buildClientCard(_clients[index]);
      },
    );
  }

  Widget _buildClientCard(Client client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  client.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(client.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(client.status)),
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
            const SizedBox(height: 8),
            Text('Email: ${client.email}'),
            const SizedBox(height: 4),
            Text('Phone: ${client.phone}'),
            const SizedBox(height: 8),
            Text('Goals: ${client.goals}'),
            const SizedBox(height: 8),
            Text(
              'Member since: ${_formatDate(client.joinDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            // UPDATED: Single button takes full width
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // The onPressed function remains the same
                onPressed: () => _navigateToCreatePlan(client),
                icon: const Icon(Icons.assignment, color: Colors.white),
                label: const Text(
                  'Create Plan',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ), // Added padding for better height
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.orange;
      case 'Pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
