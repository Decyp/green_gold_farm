import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import 'pricing_management_screen.dart';
import 'product_management_screen.dart';
import 'machinery_management_screen.dart';
import 'user_management_screen.dart';
import 'order_management_screen.dart';
import 'analytics_screen.dart';
import 'category_management_screen.dart';
import 'booking_management_screen.dart';
import 'admin_notifications_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
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
                            builder: (context) =>
                                const AdminNotificationsScreen(),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsGrid(context),
            _buildManagementSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusXLarge)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 40,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'Admin Dashboard',
            style: AppTheme.heading1.copyWith(color: AppTheme.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Manage your farm operations',
            style: AppTheme.bodyText.copyWith(color: AppTheme.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.paddingMedium,
            mainAxisSpacing: AppTheme.paddingMedium,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Products', Icons.shopping_basket,
                  AppTheme.primaryGreen, _getProductsCount(context)),
              _buildStatCard('Active Machinery', Icons.agriculture,
                  AppTheme.lightGreen, _getMachineryCount(context)),
              _buildStatCard('Pending Orders', Icons.shopping_cart,
                  AppTheme.accentGold, _getPendingOrdersCount(context)),
              _buildStatCard('Total Users', Icons.people, AppTheme.darkGreen,
                  _getUsersCount(context)),
              _buildStatCard('Active Bookings', Icons.calendar_today,
                  AppTheme.primaryGreen, _getBookingsCount(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, IconData icon, Color color, Widget countWidget) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Flexible(
              child: countWidget,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              title,
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getProductsCount(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream:
          Provider.of<FirebaseService>(context, listen: false).getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryGreen,
            ),
          );
        }
        final count = snapshot.data?.length ?? 0;
        return Text(
          count.toString(),
          style: AppTheme.heading2.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _getMachineryCount(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream:
          Provider.of<FirebaseService>(context, listen: false).getMachinery(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.lightGreen,
            ),
          );
        }
        final count = snapshot.data?.length ?? 0;
        return Text(
          count.toString(),
          style: AppTheme.heading2.copyWith(
            color: AppTheme.lightGreen,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _getPendingOrdersCount(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream:
          Provider.of<FirebaseService>(context, listen: false).getAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.accentGold,
            ),
          );
        }
        final orders = snapshot.data ?? [];
        final pendingCount = orders
            .where((order) =>
                (order['status'] ?? '').toString().toLowerCase() == 'pending')
            .length;
        return Text(
          pendingCount.toString(),
          style: AppTheme.heading2.copyWith(
            color: AppTheme.accentGold,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _getUsersCount(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: Provider.of<FirebaseService>(context, listen: false).getUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.darkGreen,
            ),
          );
        }
        final count = snapshot.data?.length ?? 0;
        return Text(
          count.toString(),
          style: AppTheme.heading2.copyWith(
            color: AppTheme.darkGreen,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _getBookingsCount(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream:
          Provider.of<FirebaseService>(context, listen: false).getAllBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryGreen,
            ),
          );
        }
        final bookings = snapshot.data ?? [];
        final activeBookings = bookings
            .where((booking) => booking.status.toLowerCase() == 'active')
            .length;
        return Text(
          activeBookings.toString(),
          style: AppTheme.heading2.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _buildManagementSections() {
    final List<Map<String, dynamic>> adminSections = [
      {
        'title': 'Product Management',
        'subtitle': 'Manage farm products and inventory',
        'icon': Icons.shopping_basket,
        'color': AppTheme.primaryGreen,
        'route': '/admin/products',
        'screen': const ProductManagementScreen(),
      },
      {
        'title': 'Machinery Management',
        'subtitle': 'Manage rental and sales equipment',
        'icon': Icons.agriculture,
        'color': AppTheme.lightGreen,
        'route': '/admin/machinery',
        'screen': const MachineryManagementScreen(),
      },
      {
        'title': 'Category Management',
        'subtitle': 'Manage product categories and machinery types',
        'icon': Icons.category,
        'color': AppTheme.accentGold,
        'route': '/admin/categories',
        'screen': const CategoryManagementScreen(),
      },
      {
        'title': 'Pricing Management',
        'subtitle': 'Configure rental and product pricing',
        'icon': Icons.price_change,
        'color': AppTheme.darkGreen,
        'route': '/admin/pricing',
        'screen': const PricingManagementScreen(),
      },
      {
        'title': 'User Management',
        'subtitle': 'Manage farmers and customers',
        'icon': Icons.people,
        'color': AppTheme.primaryGreen,
        'route': '/admin/users',
        'screen': const UserManagementScreen(),
      },
      {
        'title': 'Order Management',
        'subtitle': 'Track orders and rentals',
        'icon': Icons.shopping_cart,
        'color': AppTheme.lightGreen,
        'route': '/admin/orders',
        'screen': const OrderManagementScreen(),
      },
      {
        'title': 'Analytics & Reports',
        'subtitle': 'View business insights and reports',
        'icon': Icons.analytics,
        'color': AppTheme.accentGold,
        'route': '/admin/analytics',
        'screen': const AnalyticsScreen(),
      },
      {
        'title': 'Booking Management',
        'subtitle': 'Manage farm bookings and reservations',
        'icon': Icons.calendar_today,
        'color': AppTheme.primaryGreen,
        'route': '/admin/bookings',
        'screen': const BookingManagementScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Management Tools',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          ...adminSections.map((section) => _buildSectionCard(section)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => section['screen'],
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: section['color'].withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(
                      section['icon'],
                      color: section['color'],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section['title'],
                          style: AppTheme.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Text(
                          section['subtitle'],
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.gray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.gray,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
