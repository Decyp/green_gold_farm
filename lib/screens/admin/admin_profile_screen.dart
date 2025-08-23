import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'admin_settings_screen.dart';
import 'admin_profile_edit_screen.dart';
import 'admin_notifications_screen.dart';
import '../customer/change_password_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildAdminInfo(),
            _buildProfileActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          // Admin Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: AppTheme.white,
                width: 3,
              ),
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
                  color: AppTheme.white,
                );
              }

              final user = snapshot.data;
              if (user == null) {
                return Column(
                  children: [
                    Text(
                      'Admin Access Required',
                      style: AppTheme.heading2.copyWith(color: AppTheme.white),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      'Please sign in with admin credentials',
                      style: AppTheme.bodyText.copyWith(color: AppTheme.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to login
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.white,
                        foregroundColor: AppTheme.primaryGreen,
                      ),
                      child: const Text('Sign In'),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Text(
                    user.displayName ?? 'Administrator',
                    style: AppTheme.heading2.copyWith(color: AppTheme.white),
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    user.email ?? '',
                    style: AppTheme.bodyText.copyWith(color: AppTheme.white),
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingMedium,
                      vertical: AppTheme.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Text(
                      'ADMINISTRATOR',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Container(
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
                children: [
                  _buildInfoRow(
                      'Role', 'Administrator', Icons.admin_panel_settings),
                  const Divider(),
                  _buildInfoRow('Status', 'Active', Icons.check_circle),
                  const Divider(),
                  _buildInfoRow('Last Login', 'Today', Icons.access_time),
                  const Divider(),
                  _buildInfoRow(
                      'Account Created', '2024', Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit_profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminProfileEditScreen(),
          ),
        );
        break;
      case 'change_password':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChangePasswordScreen(),
          ),
        );
        break;
      case 'notifications':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminNotificationsScreen(),
          ),
        );
        break;
      case 'sign_out':
        FirebaseAuth.instance.signOut();
        break;
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.gray,
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    final List<Map<String, dynamic>> profileActions = [
      {
        'title': 'Edit Profile',
        'subtitle': 'Update your personal information',
        'icon': Icons.edit,
        'color': AppTheme.primaryGreen,
        'action': 'edit_profile',
      },
      {
        'title': 'Change Password',
        'subtitle': 'Update your account password',
        'icon': Icons.lock,
        'color': AppTheme.lightGreen,
        'action': 'change_password',
      },
      {
        'title': 'Notifications',
        'subtitle': 'Manage notification preferences',
        'icon': Icons.notifications,
        'color': AppTheme.accentGold,
        'action': 'notifications',
      },
      {
        'title': 'Sign Out',
        'subtitle': 'Sign out of your account',
        'icon': Icons.logout,
        'color': Colors.red,
        'action': 'sign_out',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Actions',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          ...profileActions.map((action) => _buildActionCard(action)),
        ],
      ),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
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
            onTap: () => _handleAction(context, action['action']),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: action['color'].withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(
                      action['icon'],
                      color: action['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action['title'],
                          style: AppTheme.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Text(
                          action['subtitle'],
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.gray,
                          ),
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
