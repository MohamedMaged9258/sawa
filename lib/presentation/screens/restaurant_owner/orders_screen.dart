// lib/presentation/screens/restaurant_owner/orders_screen.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';
import 'package:sawa/presentation/providers/auth_provider.dart';
import 'package:sawa/presentation/providers/restaurant_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final ownerId = Provider.of<AuthProvider>(context, listen: false).uid;
      if (ownerId != null) {
        final data = await RestaurantProvider.fetchOrdersByOwner(ownerId);
        setState(() => _orders = data);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    await RestaurantProvider.updateOrderStatus(orderId, status);
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[800]))
          : ListView.builder(
              itemCount: _orders.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final order = _orders[index];
                return _buildOrderCard(order);
              },
            ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    switch (order.status.toLowerCase()) {
      case 'completed': statusColor = Colors.green; break;
      case 'preparing': statusColor = Colors.blue; break;
      case 'cancelled': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.oid.substring(0, 5)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text('${item['quantity'] ?? 1}x', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('${item['name']}', style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(color: Colors.grey)),
                Text('\$${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            if (order.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(order.oid, 'preparing'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
                  child: const Text('Accept Order', style: TextStyle(color: Colors.white)),
                ),
              ),
            if (order.status == 'preparing')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(order.oid, 'completed'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Mark Ready', style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}