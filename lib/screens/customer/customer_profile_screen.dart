import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/order.dart';
import '../../models/booking.dart';
import 'bookings_screen.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'help_center_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildMenuSection(),
            _buildOrdersSection(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildBookingsSection(),
            const SizedBox(height: AppTheme.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: AppTheme.primaryGreen,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          // User Info
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                );
              }

              final user = snapshot.data;
              if (user == null) {
                return Column(
                  children: [
                    Text(
                      'Guest User',
                      style: AppTheme.heading2,
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      'Please sign in to access your profile',
                      style: AppTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to login
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Text(
                    user.displayName ?? 'Farmer',
                    style: AppTheme.heading2,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    user.email ?? '',
                    style: AppTheme.caption,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDynamicStatItem('Orders', 'orders'),
                      _buildDynamicStatItem('Rentals', 'bookings'),
                      _buildDynamicStatItem('Saved', 'saved'),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.heading3.copyWith(color: AppTheme.primaryGreen),
        ),
        Text(
          label,
          style: AppTheme.caption,
        ),
      ],
    );
  }

  Widget _buildDynamicStatItem(String label, String collectionName) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: AppTheme.primaryGreen,
          );
        }

        final user = userSnapshot.data;
        if (user == null) {
          return Column(
            children: [
              Text(
                '0',
                style: AppTheme.heading3.copyWith(color: AppTheme.primaryGreen),
              ),
              Text(
                label,
                style: AppTheme.caption,
              ),
            ],
          );
        }

        return StreamBuilder<int>(
          stream: Provider.of<FirebaseService>(context, listen: false)
              .getUserCollectionCount(collectionName, user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              );
            }

            final count = snapshot.data ?? 0;
            return Column(
              children: [
                Text(
                  count.toString(),
                  style:
                      AppTheme.heading3.copyWith(color: AppTheme.primaryGreen),
                ),
                Text(
                  label,
                  style: AppTheme.caption,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMenuSection() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Settings',
        'icon': Icons.settings,
        'color': AppTheme.primaryGreen,
        'route': 'settings',
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications,
        'color': AppTheme.lightGreen,
        'route': 'notifications',
      },
      {
        'title': 'Help Center',
        'icon': Icons.help,
        'color': AppTheme.accentGold,
        'route': 'help_center',
      },
      {
        'title': 'Sign Out',
        'icon': Icons.logout,
        'color': Colors.red,
        'route': 'sign_out',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          ...menuItems.map((item) => _buildMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: () {
            // Handle menu item tap
            switch (item['route']) {
              case 'settings':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
                break;
              case 'notifications':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
                break;
              case 'help_center':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpCenterScreen(),
                  ),
                );
                break;
              case 'sign_out':
                _showSignOutDialog();
                break;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Expanded(
                  child: Text(
                    item['title'],
                    style: AppTheme.bodyText.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
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
    );
  }

  Widget _buildOrdersSection() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Orders',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            StreamBuilder<List<Order>>(
              stream: Provider.of<FirebaseService>(context, listen: false)
                  .getUserOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingOrders();
                }

                if (snapshot.hasError) {
                  return _buildErrorOrders();
                }

                final orders = snapshot.data ?? [];

                if (orders.isEmpty) {
                  return _buildEmptyOrders();
                }

                return Column(
                  children: orders
                      .take(3)
                      .map((order) => _buildOrderCard(order))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrdersScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  side: const BorderSide(color: AppTheme.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: const Text('View All Orders'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
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
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    order.status,
                    style: AppTheme.caption.copyWith(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              '${order.items.length} items',
              style: AppTheme.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GHS ${order.total.toStringAsFixed(2)}',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(order.createdAt),
                  style: AppTheme.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOrders() {
    return Column(
      children: List.generate(
          3,
          (index) => Container(
                height: 80,
                margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                decoration: AppTheme.cardDecoration,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                ),
              )),
    );
  }

  Widget _buildErrorOrders() {
    return Container(
      height: 100,
      decoration: AppTheme.cardDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.gray,
              size: 30,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              'Failed to load orders',
              style: AppTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      height: 100,
      decoration: AppTheme.cardDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag,
              color: AppTheme.gray,
              size: 30,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              'No orders yet',
              style: AppTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Bookings',
              style: AppTheme.heading3,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingsScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        StreamBuilder<List<Booking>>(
          stream: Provider.of<FirebaseService>(context, listen: false)
              .getUserBookings(FirebaseAuth.instance.currentUser?.uid ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 100,
                decoration: AppTheme.cardDecoration,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorBookings();
            }

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return _buildEmptyBookings();
            }

            // Show only the first 2 bookings
            final recentBookings = bookings.take(2).toList();

            return Column(
              children: recentBookings
                  .map((booking) => _buildBookingCard(booking))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(
                Icons.agriculture,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.machineryName,
                    style: AppTheme.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${booking.duration} days • GHS ${booking.totalAmount.toStringAsFixed(2)}',
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _getBookingStatusColor(booking.status)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                _getBookingStatusText(booking.status),
                style: AppTheme.caption.copyWith(
                  color: _getBookingStatusColor(booking.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBookings() {
    return Container(
      height: 100,
      decoration: AppTheme.cardDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.gray,
              size: 30,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              'Failed to load bookings',
              style: AppTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBookings() {
    return Container(
      height: 100,
      decoration: AppTheme.cardDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppTheme.gray,
              size: 30,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              'No bookings yet',
              style: AppTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'active':
        return AppTheme.primaryGreen;
      case 'completed':
        return AppTheme.darkGreen;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.gray;
    }
  }

  String _getBookingStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return AppTheme.primaryGreen;
      case 'pending':
        return AppTheme.accentGold;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.gray;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _showSnackBar('Signed out successfully');
    } catch (e) {
      _showSnackBar('Error signing out: $e');
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
}
