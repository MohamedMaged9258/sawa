// lib/presentation/screens/restaurant_owner/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';

class OrdersScreen extends StatefulWidget {
  final List<Order> orders;
  final Function(int, String) onOrderStatusUpdated;

  const OrdersScreen({
    super.key,
    required this.orders,
    required this.onOrderStatusUpdated,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<Order> _sampleOrders = [
    Order(
      id: '1',
      customerName: 'John Doe',
      meals: [
        Meal(
          id: '1',
          name: 'Margherita Pizza',
          description: 'Classic pizza with tomato and mozzarella',
          price: 12.99,
          category: 'Main Course',
          photo: '',
          isAvailable: true,
          createdAt: DateTime.now(),
        ),
      ],
      totalAmount: 12.99,
      status: 'pending',
      orderDate: DateTime.now(),
    ),
    Order(
      id: '2',
      customerName: 'Sarah Smith',
      meals: [
        Meal(
          id: '2',
          name: 'Caesar Salad',
          description: 'Fresh salad with caesar dressing',
          price: 8.99,
          category: 'Appetizer',
          photo: '',
          isAvailable: true,
          createdAt: DateTime.now(),
        ),
      ],
      totalAmount: 8.99,
      status: 'preparing',
      orderDate: DateTime.now(),
    ),
  ];

  void _updateOrderStatus(int index, String status) {
    setState(() {
      _sampleOrders[index].status = status;
    });
    widget.onOrderStatusUpdated(index, status);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = widget.orders.isEmpty ? _sampleOrders : widget.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No orders yet'),
                  SizedBox(height: 8),
                  Text('Orders will appear here when customers place them', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index], index);
              },
            ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
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
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(order.status)),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Customer: ${order.customerName}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            ...order.meals.map((meal) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text('• ${meal.name} - \$${meal.price.toStringAsFixed(2)}'),
            )),
            const SizedBox(height: 12),
            Text(
              'Ordered: ${_formatDate(order.orderDate)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            if (order.status != 'completed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String newStatus = '';
                    switch (order.status) {
                      case 'pending':
                        newStatus = 'preparing';
                        break;
                      case 'preparing':
                        newStatus = 'ready';
                        break;
                      case 'ready':
                        newStatus = 'completed';
                        break;
                    }
                    if (newStatus.isNotEmpty) {
                      _updateOrderStatus(index, newStatus);
                    }
                  },
                  child: Text(_getNextStatusText(order.status)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getNextStatusText(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return 'Start Preparing';
      case 'preparing':
        return 'Mark as Ready';
      case 'ready':
        return 'Complete Order';
      default:
        return 'Update Status';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')} - ${date.day}/${date.month}/${date.year}';
  }
}