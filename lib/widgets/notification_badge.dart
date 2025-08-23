import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Provider.of<FirebaseService>(context, listen: false)
          .getUserNotifications(),
      builder: (context, snapshot) {
        print(
            'NotificationBadge: Connection state: ${snapshot.connectionState}');
        print('NotificationBadge: Has error: ${snapshot.hasError}');
        print('NotificationBadge: Has data: ${snapshot.hasData}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('NotificationBadge: Waiting for data...');
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          print('NotificationBadge: Error: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        final notifications = snapshot.data ?? [];
        final unreadCount =
            notifications.where((n) => n['read'] == false).length;

        print(
            'NotificationBadge: Total notifications: ${notifications.length}');
        print('NotificationBadge: Unread count: $unreadCount');

        if (unreadCount == 0) {
          print('NotificationBadge: No unread notifications, hiding badge');
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(AppTheme.paddingSmall),
          child: Material(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium,
                  vertical: AppTheme.paddingSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications,
                            color: AppTheme.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.paddingSmall),
                          Expanded(
                            child: Text(
                              'You have $unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                              style: AppTheme.bodyText.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
