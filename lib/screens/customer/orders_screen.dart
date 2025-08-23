import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/order.dart';
import 'order_details_screen.dart';
import '../../widgets/notification_badge.dart';
import 'notifications_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view your orders'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Order>>(
        stream: Provider.of<FirebaseService>(context, listen: false)
            .getUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                NotificationBadge(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Column(
              children: [
                NotificationBadge(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 60, color: AppTheme.gray),
                        const SizedBox(height: AppTheme.paddingMedium),
                        Text('Error loading orders', style: AppTheme.heading3),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Column(
              children: [
                NotificationBadge(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                Expanded(child: _buildEmptyOrders()),
              ],
            );
          }

          return Column(
            children: [
              NotificationBadge(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(orders[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: AppTheme.gray,
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          Text(
            'No orders yet',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Start shopping to see your orders here',
            style: AppTheme.bodyText.copyWith(color: AppTheme.gray),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingLarge,
                vertical: AppTheme.paddingMedium,
              ),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(order: order),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: AppTheme.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(order.createdAt),
                          style:
                              AppTheme.caption.copyWith(color: AppTheme.gray),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status)
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        _getStatusText(order.status),
                        style: AppTheme.caption.copyWith(
                          color: _getStatusColor(order.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                const Divider(),
                // Order Items
                ...order.items.take(3).map((item) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} (${item.quantity}x)',
                              style: AppTheme.bodyText,
                            ),
                          ),
                          Text(
                            'GHS ${item.totalPrice.toStringAsFixed(2)}',
                            style: AppTheme.bodyText.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (order.items.length > 3)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                    child: Text(
                      '+${order.items.length - 3} more items',
                      style: AppTheme.caption.copyWith(color: AppTheme.gray),
                    ),
                  ),
                const Divider(),
                // Order Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: AppTheme.bodyText
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'GHS ${order.total.toStringAsFixed(2)}',
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                // Payment Method
                Text(
                  'Payment: ${order.paymentMethod}',
                  style: AppTheme.caption.copyWith(color: AppTheme.gray),
                ),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    'Notes: ${order.notes}',
                    style: AppTheme.caption.copyWith(color: AppTheme.gray),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return AppTheme.primaryGreen;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.gray;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
