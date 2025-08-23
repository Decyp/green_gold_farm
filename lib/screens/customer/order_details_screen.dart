import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildOrderHeader(),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildOrderItems(),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildOrderSummary(),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildOrderTimeline(),
            const SizedBox(height: AppTheme.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      'Order #${order.id.substring(0, 8)}',
                      style: AppTheme.heading2.copyWith(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      _formatDate(order.createdAt),
                      style: AppTheme.bodyText.copyWith(
                        color: AppTheme.gray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium,
                  vertical: AppTheme.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: _getStatusColor(order.status),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(order.status),
                      size: 16,
                      color: _getStatusColor(order.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(order.status),
                      style: AppTheme.bodyText.copyWith(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Icon(
                Icons.shopping_basket,
                size: 20,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                '${order.items.length} items',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'GHS ${order.total.toStringAsFixed(2)}',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                'Order Items',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return _buildOrderItemCard(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.lightGray,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Item Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: item.productImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Image.network(
                      item.productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          color: AppTheme.gray,
                          size: 30,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.image,
                    color: AppTheme.gray,
                    size: 30,
                  ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.gray,
                  ),
                ),
              ],
            ),
          ),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GHS ${item.price.toStringAsFixed(2)}',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'GHS ${item.totalPrice.toStringAsFixed(2)}',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final tax = subtotal * 0.05; // 5% tax
    final shipping = subtotal > 100 ? 0.0 : 10.0; // Free shipping over GHS 100
    final total = subtotal + tax + shipping;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                'Order Summary',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          _buildSummaryRow('Subtotal', 'GHS ${subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Tax (5%)', 'GHS ${tax.toStringAsFixed(2)}'),
          _buildSummaryRow(
            'Shipping',
            shipping == 0 ? 'Free' : 'GHS ${shipping.toStringAsFixed(2)}',
            isHighlighted: shipping == 0,
          ),
          const Divider(height: AppTheme.paddingLarge),
          _buildSummaryRow(
            'Total',
            'GHS ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyText.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppTheme.darkGray : AppTheme.gray,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyText.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted
                  ? AppTheme.primaryGreen
                  : isTotal
                      ? AppTheme.primaryGreen
                      : AppTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                'Order Timeline',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          _buildTimelineItem(
            'Order Placed',
            _formatDate(order.createdAt),
            Icons.shopping_cart,
            AppTheme.primaryGreen,
            isCompleted: true,
          ),
          _buildTimelineItem(
            'Order Confirmed',
            _getEstimatedDate(order.createdAt, 1),
            Icons.check_circle,
            AppTheme.primaryGreen,
            isCompleted: order.status.toLowerCase() != 'pending',
          ),
          _buildTimelineItem(
            'Processing',
            _getEstimatedDate(order.createdAt, 2),
            Icons.inventory_2,
            Colors.blue,
            isCompleted: ['confirmed', 'shipped', 'delivered']
                .contains(order.status.toLowerCase()),
          ),
          _buildTimelineItem(
            'Shipped',
            _getEstimatedDate(order.createdAt, 3),
            Icons.local_shipping,
            Colors.orange,
            isCompleted:
                ['shipped', 'delivered'].contains(order.status.toLowerCase()),
          ),
          _buildTimelineItem(
            'Delivered',
            _getEstimatedDate(order.createdAt, 4),
            Icons.home,
            Colors.green,
            isCompleted: order.status.toLowerCase() == 'delivered',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      String title, String date, IconData icon, Color color,
      {required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? color : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? color : AppTheme.gray,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isCompleted ? AppTheme.white : AppTheme.gray,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppTheme.darkGray : AppTheme.gray,
                  ),
                ),
                Text(
                  date,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.gray,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: color,
              size: 20,
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return AppTheme.primaryGreen;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
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
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.home;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getEstimatedDate(DateTime baseDate, int daysToAdd) {
    final estimatedDate = baseDate.add(Duration(days: daysToAdd));
    return '${estimatedDate.day}/${estimatedDate.month}/${estimatedDate.year}';
  }
}
