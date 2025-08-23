import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await _notificationService.getUserNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error loading notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Notifications'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNotificationStats(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(_notifications[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStats() {
    final unreadCount = _notifications.where((n) => !n['read']).length;

    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: AppTheme.primaryGreen,
            size: 24,
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Notifications',
                  style:
                      AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$unreadCount unread',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Mark all as read'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingLarge,
        vertical: AppTheme.paddingSmall,
      ),
      decoration: AppTheme.cardDecoration.copyWith(
        color: notification['read']
            ? Colors.white
            : AppTheme.primaryGreen.withValues(alpha: 0.05),
      ),
      child: ListTile(
        leading: _buildNotificationIcon(notification['type']),
        title: Text(
          notification['title'],
          style: AppTheme.bodyText.copyWith(
            fontWeight:
                notification['read'] ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['body'] ?? '',
              style: AppTheme.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              _formatTime(notification['timestamp']),
              style: AppTheme.caption.copyWith(
                color: AppTheme.gray,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: notification['read']
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          _markAsRead(notification['id']);
        },
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'order':
        iconData = Icons.shopping_cart;
        iconColor = AppTheme.primaryGreen;
        break;
      case 'booking':
        iconData = Icons.calendar_today;
        iconColor = AppTheme.accentGold;
        break;
      case 'payment':
        iconData = Icons.payment;
        iconColor = AppTheme.darkGreen;
        break;
      case 'product':
        iconData = Icons.inventory;
        iconColor = AppTheme.lightGreen;
        break;
      case 'user':
        iconData = Icons.person_add;
        iconColor = AppTheme.primaryGreen;
        break;
      case 'system':
        iconData = Icons.system_update;
        iconColor = AppTheme.darkGreen;
        break;
      case 'alert':
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppTheme.gray;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 64,
            color: AppTheme.gray,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'No admin notifications',
            style: AppTheme.heading3.copyWith(color: AppTheme.gray),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'You\'re all caught up!',
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      setState(() {
        final notification =
            _notifications.firstWhere((n) => n['id'] == notificationId);
        notification['read'] = true;
      });
    } catch (e) {
      _showSnackBar('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllNotificationsAsRead();
      setState(() {
        for (var notification in _notifications) {
          notification['read'] = true;
        }
      });
      _showSnackBar('All notifications marked as read');
    } catch (e) {
      _showSnackBar('Error marking all notifications as read: $e');
    }
  }

  String _formatTime(dynamic timestamp) {
    DateTime time;

    if (timestamp is DateTime) {
      time = timestamp;
    } else if (timestamp != null) {
      // Handle Firestore timestamp
      time = timestamp.toDate();
    } else {
      return 'Just now';
    }

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
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
