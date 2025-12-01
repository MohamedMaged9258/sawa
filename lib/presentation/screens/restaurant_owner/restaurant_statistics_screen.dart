import 'package:flutter/material.dart';

class RestaurantStatisticsScreen extends StatelessWidget {
  const RestaurantStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Restaurant Statistics'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatSection(
              title: 'Revenue',
              items: [
                _buildRow('Total Revenue', '\$2,850.00', Colors.green),
                _buildRow('This Week', '\$850.00', null),
                _buildRow('This Month', '\$2,850.00', null),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatSection(
              title: 'Orders',
              items: [
                _buildRow('Total Orders', '112', Colors.blue[800]),
                _buildRow('Completed', '98', null),
                _buildRow('Pending', '8', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatSection(
              title: 'Customers',
              items: [
                _buildRow('Total Customers', '85', Colors.purple),
                _buildRow('Repeat', '45', null),
                _buildRow('New This Month', '12', null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
