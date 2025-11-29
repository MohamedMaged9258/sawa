// lib/presentation/screens/nutritionist/clients_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

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

  Future<void> _fetchClients() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final nutritionistId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (nutritionistId == null || nutritionistId.isEmpty) {
        throw Exception("User is not logged in.");
      }

      final fetchedClients = await NutritionistProvider.fetchClientsByNutritionId(nutritionistId);

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

  Future<void> _submitAddClient(BuildContext dialogContext) async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) return;

    try {
      final nutritionistId = Provider.of<AuthProvider>(context, listen: false).uid;
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

      if (!mounted) return;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _goalsController.clear();

      Navigator.pop(dialogContext);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client added successfully!'), backgroundColor: Colors.blue),
      );

      _fetchClients();
    } catch (e) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(content: Text('Failed to add client: $e'), backgroundColor: Colors.red),
      );
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
      _fetchClients();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan created!'), backgroundColor: Colors.blue),
      );
    }
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Client'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogInput(_nameController, 'Full Name', Icons.person),
              const SizedBox(height: 12),
              _buildDialogInput(_emailController, 'Email', Icons.email, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildDialogInput(_phoneController, 'Phone', Icons.phone, type: TextInputType.phone),
              const SizedBox(height: 12),
              _buildDialogInput(_goalsController, 'Goals', Icons.flag, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submitAddClient(dialogContext),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
            child: const Text('Add Client', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInput(TextEditingController ctrl, String label, IconData icon, {TextInputType? type, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[800]),
        filled: true, fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
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
            // Removed the Row with Search Icon as requested
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('My Clients', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.blue));
    if (_error != null) return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));
    if (_clients.isEmpty) return Center(child: Text('No clients found.', style: TextStyle(color: Colors.grey[600])));

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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
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
                      child: Text(client.name[0].toUpperCase(), style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Text(client.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(client.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    client.status,
                    style: TextStyle(color: _getStatusColor(client.status), fontSize: 12, fontWeight: FontWeight.bold),
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
                icon: const Icon(Icons.assignment_add, color: Colors.white, size: 18),
                label: const Text('Create Meal Plan', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 14))),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Inactive': return Colors.red;
      default: return Colors.blue;
    }
  }
}