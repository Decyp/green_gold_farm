import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import 'customer/customer_profile_screen.dart';
import 'admin/admin_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future:
          Provider.of<FirebaseService>(context, listen: false).isUserAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            ),
          );
        }

        // Show admin profile if user is admin, otherwise show customer profile
        if (snapshot.hasData && snapshot.data == true) {
          return const AdminProfileScreen();
        } else {
          return const CustomerProfileScreen();
        }
      },
    );
  }
}
