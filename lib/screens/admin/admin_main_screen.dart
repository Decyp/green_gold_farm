import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'product_management_screen.dart';
import 'machinery_management_screen.dart';
import 'order_management_screen.dart';
import 'booking_management_screen.dart';
import 'admin_profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _adminScreens = [
    const AdminDashboardScreen(),
    const ProductManagementScreen(),
    const MachineryManagementScreen(),
    const OrderManagementScreen(),
    const BookingManagementScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _adminScreens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.white,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: AppTheme.gray,
          selectedLabelStyle: AppTheme.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryGreen,
          ),
          unselectedLabelStyle: AppTheme.caption,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture),
              label: 'Machinery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
