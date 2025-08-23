import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _notificationService.isNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildNotificationSection(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildAdminSection(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
              child: const Icon(
                Icons.admin_panel_settings,
                color: AppTheme.primaryGreen,
              ),
            ),
            title: Text(
              FirebaseAuth.instance.currentUser?.displayName ?? 'Admin',
              style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: AppTheme.caption,
            ),
            trailing: const Icon(Icons.edit, color: AppTheme.primaryGreen),
            onTap: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(
              'Notifications',
              style: AppTheme.heading3,
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive admin notifications'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              await _notificationService.setNotificationsEnabled(value);
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(
              'Admin',
              style: AppTheme.heading3,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: AppTheme.primaryGreen),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to change password
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: AppTheme.primaryGreen),
            title: const Text('Analytics'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to analytics
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: AppTheme.primaryGreen),
            title: const Text('Backup & Restore'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to backup
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Account'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(
              'About',
              style: AppTheme.heading3,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primaryGreen),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your admin account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      _showSnackBar('Account deleted successfully');
    } catch (e) {
      _showSnackBar('Error deleting account: $e');
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
