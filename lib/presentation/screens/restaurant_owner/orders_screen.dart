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
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _orders.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.oid.substring(0, 5)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              order.status.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Total: \$${order.totalAmount}'),
                        const SizedBox(height: 8),
                        ...order.items.map(
                          (item) => Text(
                            '- ${item['name']} x${item['quantity'] ?? 1}',
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (order.status == 'pending')
                          ElevatedButton(
                            onPressed: () =>
                                _updateStatus(order.oid, 'preparing'),
                            child: const Text('Accept Order'),
                          ),
                        if (order.status == 'preparing')
                          ElevatedButton(
                            onPressed: () =>
                                _updateStatus(order.oid, 'completed'),
                            child: const Text('Mark Ready'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
