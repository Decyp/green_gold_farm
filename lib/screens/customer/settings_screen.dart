import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
        title: const Text('Settings'),
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
            _buildAccountSection(),
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
                Icons.person,
                color: AppTheme.primaryGreen,
              ),
            ),
            title: Text(
              FirebaseAuth.instance.currentUser?.displayName ?? 'User',
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
            subtitle: const Text('Receive push notifications'),
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

  Widget _buildAccountSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(
              'Account',
              style: AppTheme.heading3,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: AppTheme.primaryGreen),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
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
          'Are you sure you want to delete your account? This action cannot be undone.',
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
