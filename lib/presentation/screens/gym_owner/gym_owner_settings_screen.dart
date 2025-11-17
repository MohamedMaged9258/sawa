import 'package:flutter/material.dart';

class GymOwnerSettingsScreen extends StatelessWidget {
  const GymOwnerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Account Settings
          _buildSectionHeader('Account Settings'),
          _buildSettingsCard(
            children: [
              _buildSettingsItem(
                Icons.notifications,
                'Push Notifications',
                'Manage your notifications',
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
              _buildSettingsItem(
                Icons.security,
                'Privacy & Security',
                'Control your privacy settings',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              _buildSettingsItem(
                Icons.language,
                'Language',
                'English',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Gym Management
          _buildSectionHeader('Gym Management'),
          _buildSettingsCard(
            children: [
              _buildSettingsItem(
                Icons.business,
                'Business Hours',
                'Set opening and closing times',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              _buildSettingsItem(
                Icons.attach_money,
                'Pricing & Plans',
                'Manage membership prices',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              _buildSettingsItem(
                Icons.people,
                'Staff Management',
                'Add and manage staff members',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // App Settings
          _buildSectionHeader('App Settings'),
          _buildSettingsCard(
            children: [
              _buildSettingsItem(
                Icons.help,
                'Help & Support',
                'Get help and contact support',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              _buildSettingsItem(
                Icons.info,
                'About',
                'App version and information',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              _buildSettingsItem(
                Icons.feedback,
                'Feedback',
                'Share your feedback with us',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Handle logout
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.green[700], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: trailing,
      onTap: () {
        // Handle item tap
      },
    );
  }
}