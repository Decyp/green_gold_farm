import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedStatus = 'all';
            break;
          case 1:
            _selectedStatus = 'pending';
            break;
          case 2:
            _selectedStatus = 'completed';
            break;
          case 3:
            _selectedStatus = 'cancelled';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
          indicatorColor: AppTheme.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList('all'),
          _buildOrderList('pending'),
          _buildOrderList('completed'),
          _buildOrderList('cancelled'),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream:
          Provider.of<FirebaseService>(context, listen: false).getAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: AppTheme.gray),
                const SizedBox(height: AppTheme.paddingMedium),
                Text('Error loading orders', style: AppTheme.heading3),
              ],
            ),
          );
        }

        final orders = snapshot.data ?? [];
        final filteredOrders = status == 'all'
            ? orders
            : orders.where((order) => order['status'] == status).toList();

        if (filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart, size: 60, color: AppTheme.gray),
                const SizedBox(height: AppTheme.paddingMedium),
                Text('No ${status == 'all' ? '' : status} orders',
                    style: AppTheme.heading3),
                const SizedBox(height: AppTheme.paddingSmall),
                Text('Orders will appear here when customers place them',
                    style: AppTheme.caption),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final type = order['type'] ?? 'order';
    final total = order['total'] ?? 0.0;
    final customerName = order['userName'] ?? 'Unknown Customer';
    final customerEmail = order['userEmail'] ?? 'No email';
    final createdAt = order['createdAt'];
    final items = order['items'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id'] ?? 'N/A'}',
                        style: AppTheme.heading3,
                      ),
                      Text(
                        type == 'rental' ? 'Machinery Rental' : 'Product Order',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _showOrderDetails(order);
                        break;
                      case 'update':
                        _showUpdateStatusDialog(order);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(order);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 16),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'update',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Update Status'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        customerEmail,
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total: GHS ${(order['total'] ?? 0.0).toStringAsFixed(2)}',
                      style: AppTheme.bodyText.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${items.length} item${items.length != 1 ? 's' : ''}',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(createdAt),
                  style: AppTheme.caption,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: AppTheme.caption.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                'Items: ${items.map((item) => item['productName'] ?? 'Unknown').join(', ')}',
                style: AppTheme.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id'] ?? 'N/A'}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Information',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Text('Name: ${order['userName'] ?? 'Unknown'}'),
                      Text('Email: ${order['userEmail'] ?? 'No email'}'),
                      Text('Phone: ${order['phoneNumber'] ?? 'No phone'}'),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMedium),

                // Order Information
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Information',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Text('Type: ${order['type'] ?? 'order'}'),
                      Text('Status: ${order['status'] ?? 'pending'}'),
                      Text(
                          'Payment Method: ${order['paymentMethod'] ?? 'Not specified'}'),
                      Text('Date: ${_formatDate(order['createdAt'])}'),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMedium),

                // Shipping Information
                if (order['shippingAddress'] != null &&
                    order['shippingAddress'].toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipping Information',
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.lightGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Text('Address: ${order['shippingAddress']}'),
                      ],
                    ),
                  ),
                if (order['shippingAddress'] != null &&
                    order['shippingAddress'].toString().isNotEmpty)
                  const SizedBox(height: AppTheme.paddingMedium),

                // Order Items
                if (order['items'] != null &&
                    (order['items'] as List).isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.gray.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Items',
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.gray,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        ...(order['items'] as List).map((item) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppTheme.paddingSmall),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '• ${item['productName'] ?? 'Unknown'}',
                                      style: AppTheme.bodyText.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Qty: ${item['quantity'] ?? 1}',
                                      style: AppTheme.caption,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'GHS ${(item['price'] ?? 0.0).toStringAsFixed(2)}',
                                      style: AppTheme.bodyText.copyWith(
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                ],

                // Order Totals
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Totals',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:'),
                          Text(
                              'GHS ${(order['subtotal'] ?? 0.0).toStringAsFixed(2)}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tax:'),
                          Text(
                              'GHS ${(order['tax'] ?? 0.0).toStringAsFixed(2)}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shipping:'),
                          Text(
                              'GHS ${(order['shipping'] ?? 0.0).toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: AppTheme.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'GHS ${(order['total'] ?? 0.0).toStringAsFixed(2)}',
                            style: AppTheme.bodyText.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Notes
                if (order['notes'] != null &&
                    order['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: AppTheme.paddingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Notes',
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Text(order['notes']),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> order) {
    String selectedStatus = order['status'] ?? 'pending';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          value: selectedStatus,
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'processing', child: Text('Processing')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
          ],
          onChanged: (value) {
            selectedStatus = value!;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order['id'], selectedStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
            'Are you sure you want to delete Order #${order['id'] ?? 'N/A'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder(order['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(String orderId, String status) async {
    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .updateOrderStatus(orderId, status);

      if (mounted) {
        _showSnackBar('Order status updated to ${_getStatusText(status)}');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error updating order status: $e');
      }
    }
  }

  void _deleteOrder(String orderId) async {
    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .deleteOrder(orderId);

      if (mounted) {
        _showSnackBar('Order deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error deleting order: $e');
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.primaryGreen;
      case 'pending':
        return AppTheme.accentGold;
      case 'processing':
        return AppTheme.lightGreen;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.gray;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';

    try {
      final date = timestamp.toDate() as DateTime;
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
