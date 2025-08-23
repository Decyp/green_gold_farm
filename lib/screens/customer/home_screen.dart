import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'produce_screen.dart';
import 'machinery_screen.dart';
import 'cart_screen.dart';
import '../../widgets/notification_badge.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
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
                    _buildWelcomeSection(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildQuickAccessGrid(context),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildRecentActivity(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: AppTheme.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Builder(
          builder: (context) => StreamBuilder<List<Map<String, dynamic>>>(
            stream: Provider.of<FirebaseService>(context, listen: false)
                .getUserNotifications(),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? [];
              final unreadCount =
                  notifications.where((n) => n['read'] == false).length;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryGreen,
                AppTheme.darkGreen,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Professional header with icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 40,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    'Green Gold Farms',
                    style: AppTheme.heading1.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    'Premium Agricultural Solutions',
                    style: AppTheme.bodyText.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.08),
            AppTheme.lightGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.agriculture,
              color: AppTheme.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                Text(
                  'Discover our premium agricultural products and professional machinery services',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.gray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final List<Map<String, dynamic>> quickAccessItems = [
      {
        'title': 'Fresh Produce',
        'subtitle': 'Browse our products',
        'icon': Icons.shopping_basket,
        'color': AppTheme.primaryGreen,
        'route': '/produce',
        'screen': const ProduceScreen(),
      },
      {
        'title': 'Machinery Rental',
        'subtitle': 'Rent equipment',
        'icon': Icons.agriculture,
        'color': AppTheme.lightGreen,
        'route': '/machinery',
        'screen': const MachineryScreen(),
      },
      {
        'title': 'Machinery Sales',
        'subtitle': 'Buy equipment',
        'icon': Icons.sell,
        'color': AppTheme.darkGreen,
        'route': '/machinery',
        'screen': const MachineryScreen(),
      },
      {
        'title': 'Shopping Cart',
        'subtitle': 'View your cart',
        'icon': Icons.shopping_cart,
        'color': AppTheme.accentGold,
        'route': '/cart',
        'screen': const CartScreen(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Our Services',
              style: AppTheme.heading2.copyWith(
                color: AppTheme.darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${quickAccessItems.length} Services',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.paddingMedium,
            mainAxisSpacing: AppTheme.paddingMedium,
            childAspectRatio: 1.1,
          ),
          itemCount: quickAccessItems.length,
          itemBuilder: (context, index) {
            final item = quickAccessItems[index];
            return _buildQuickAccessCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
      BuildContext context, Map<String, dynamic> item) {
    return Container(
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
        border: Border.all(
          color: AppTheme.lightGray,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: () {
            if (item['screen'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => item['screen'],
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item['color'],
                        item['color'].withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: item['color'].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    item['icon'],
                    color: AppTheme.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  item['title'],
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'],
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.gray,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Orders',
              style: AppTheme.heading2.copyWith(
                color: AppTheme.darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: StreamBuilder<List<Order>>(
                stream: Provider.of<FirebaseService>(context, listen: false)
                    .getUserOrders(),
                builder: (context, snapshot) {
                  final orderCount = snapshot.data?.length ?? 0;
                  return Text(
                    '$orderCount Orders',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        StreamBuilder<List<Order>>(
          stream: Provider.of<FirebaseService>(context, listen: false)
              .getUserOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppTheme.lightGray),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppTheme.lightGray),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.error, size: 60, color: AppTheme.gray),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text('Error loading orders', style: AppTheme.heading3),
                  ],
                ),
              );
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppTheme.lightGray),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 40,
                        color: AppTheme.gray,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      'No orders yet',
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      'Start shopping to see your orders here',
                      style: AppTheme.bodyText.copyWith(
                        color: AppTheme.gray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProduceScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingLarge,
                          vertical: AppTheme.paddingMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      child: const Text('Start Shopping'),
                    ),
                  ],
                ),
              );
            }

            // Show only the 3 most recent orders
            final recentOrders = orders.take(3).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentOrders.length,
              itemBuilder: (context, index) {
                final order = recentOrders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(color: AppTheme.lightGray),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.all(AppTheme.paddingSmall),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: const Icon(
                                Icons.receipt,
                                color: AppTheme.primaryGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: Text(
                                'Order #${order.id.substring(0, 8)}',
                                style: AppTheme.bodyText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkGray,
                                ),
                              ),
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
                                border: Border.all(
                                  color: _getStatusColor(order.status),
                                  width: 1,
                                ),
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
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_basket,
                              size: 16,
                              color: AppTheme.gray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${order.items.length} items',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.gray,
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingMedium),
                            Icon(
                              Icons.attach_money,
                              size: 16,
                              color: AppTheme.gray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'GHS ${order.total.toStringAsFixed(2)}',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppTheme.gray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(order.createdAt),
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.gray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
