import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _fcmTokenKey = 'fcm_token';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permission for notifications
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    await _getFCMToken();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    _isInitialized = true;
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Also check local notification permissions
    final localNotifications = FlutterLocalNotificationsPlugin();
    final androidImplementation =
        localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final areNotificationsEnabled =
          await androidImplementation.areNotificationsEnabled();
      print('Local notifications enabled: $areNotificationsEnabled');

      if (areNotificationsEnabled != null && !areNotificationsEnabled) {
        print('Local notifications are disabled. Requesting permission...');
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
        await _updateFCMTokenInFirestore(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await _saveFCMToken(newToken);
        await _updateFCMTokenInFirestore(newToken);
      });
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  Future<void> _updateFCMTokenInFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating FCM token in Firestore: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');

      // Show local notification
      await _showLocalNotification(message);

      // Save notification to Firestore
      await _saveNotificationToFirestore(message);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Handle navigation based on notification type
    _handleNotificationNavigation(message.data);
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Handle navigation based on notification type
    switch (data['type']) {
      case 'order':
      case 'order_status':
        // Navigate to order details
        // TODO: Navigate to specific order details screen
        break;
      case 'booking':
      case 'booking_status':
        // Navigate to booking details
        // TODO: Navigate to specific booking details screen
        break;
      case 'payment':
        // Navigate to payment details
        break;
      case 'product':
        // Navigate to product details
        break;
      default:
        // Default navigation
        break;
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .add({
          'title': message.notification?.title ?? 'Notification',
          'body': message.notification?.body ?? '',
          'type': message.data['type'] ?? 'general',
          'data': message.data,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
    } catch (e) {
      print('Error saving notification to Firestore: $e');
    }
  }

  // Public methods
  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      await _requestPermission();
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'body': data['body'] ?? '',
          'type': data['type'] ?? 'general',
          'timestamp': data['timestamp'],
          'read': data['read'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notificationId)
            .update({'read': true});
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final batch = _firestore.batch();
        final querySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .where('read', isEqualTo: false)
            .get();

        for (var doc in querySnapshot.docs) {
          batch.update(doc.reference, {'read': true});
        }

        await batch.commit();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notificationId)
            .delete();
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Send order status update notification
  Future<void> sendOrderStatusNotification({
    required String userId,
    required String orderId,
    required String orderNumber,
    required String oldStatus,
    required String newStatus,
    required String userName,
  }) async {
    try {
      print(
          'Starting order status notification for user: $userId, order: $orderId');

      // Get user's FCM token (optional for local notifications)
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final fcmToken = userData?['fcmToken'];

      if (fcmToken != null) {
        print('FCM token found: ${fcmToken.substring(0, 20)}...');
      } else {
        print(
            'User FCM token not found, but continuing with local notification');
      }

      // Create notification data
      final notificationData = {
        'type': 'order_status',
        'orderId': orderId,
        'orderNumber': orderNumber,
        'oldStatus': oldStatus,
        'newStatus': newStatus,
      };

      // Save notification to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': 'Order Status Updated',
        'body':
            'Your order #$orderNumber status has been updated from ${_formatStatus(oldStatus)} to ${_formatStatus(newStatus)}',
        'type': 'order_status',
        'data': notificationData,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      print('Notification saved to Firestore');

      // Check if the current user is the one who should receive the notification
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        // Show local notification only if the current user is the target user
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/launcher_icon',
        );

        const DarwinNotificationDetails iOSPlatformChannelSpecifics =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );

        final notificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(100000);
        await _localNotifications.show(
          notificationId,
          'Order Status Updated',
          'Your order #$orderNumber status has been updated from ${_formatStatus(oldStatus)} to ${_formatStatus(newStatus)}',
          platformChannelSpecifics,
          payload: json.encode(notificationData),
        );

        print('Local notification shown with ID: $notificationId');
      } else {
        print(
            'Current user is not the target user, skipping local notification');
      }

      // TODO: Send FCM notification to user's device
      // This would require a backend service or Cloud Functions
      print('Order status notification sent for order #$orderNumber');
    } catch (e) {
      print('Error sending order status notification: $e');
    }
  }

  String _formatStatus(String status) {
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
        return status;
    }
  }

  String _formatBookingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Send booking status update notification
  Future<void> sendBookingStatusNotification({
    required String userId,
    required String bookingId,
    required String bookingNumber,
    required String oldStatus,
    required String newStatus,
    required String userName,
    required String machineryName,
  }) async {
    try {
      // Get user's FCM token (optional for local notifications)
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final fcmToken = userData?['fcmToken'];

      if (fcmToken != null) {
        print('FCM token found: ${fcmToken.substring(0, 20)}...');
      } else {
        print(
            'User FCM token not found, but continuing with local notification');
      }

      // Create notification data
      final notificationData = {
        'type': 'booking_status',
        'bookingId': bookingId,
        'bookingNumber': bookingNumber,
        'oldStatus': oldStatus,
        'newStatus': newStatus,
        'machineryName': machineryName,
      };

      // Save notification to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': 'Booking Status Updated',
        'body':
            'Your booking for $machineryName has been updated from ${_formatBookingStatus(oldStatus)} to ${_formatBookingStatus(newStatus)}',
        'type': 'booking_status',
        'data': notificationData,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Check if the current user is the one who should receive the notification
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        // Show local notification only if the current user is the target user
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/launcher_icon',
        );

        const DarwinNotificationDetails iOSPlatformChannelSpecifics =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );

        final notificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(100000);
        await _localNotifications.show(
          notificationId,
          'Booking Status Updated',
          'Your booking for $machineryName has been updated from ${_formatBookingStatus(oldStatus)} to ${_formatBookingStatus(newStatus)}',
          platformChannelSpecifics,
          payload: json.encode(notificationData),
        );

        print('Local notification shown with ID: $notificationId');
      } else {
        print(
            'Current user is not the target user, skipping local notification');
      }

      // TODO: Send FCM notification to user's device
      // This would require a backend service or Cloud Functions
      print('Booking status notification sent for booking #$bookingNumber');
    } catch (e) {
      print('Error sending booking status notification: $e');
    }
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    print('Sending test notification...');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _localNotifications.show(
      notificationId,
      'Test Notification',
      'This is a test notification from Green Gold Farms',
      platformChannelSpecifics,
    );

    print('Test notification sent with ID: $notificationId');
  }

  // Test order status notification
  Future<void> sendTestOrderStatusNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await sendOrderStatusNotification(
        userId: user.uid,
        orderId: 'test_order_123',
        orderNumber: 'ORD-123',
        oldStatus: 'pending',
        newStatus: 'confirmed',
        userName: 'Test User',
      );
    }
  }

  // Test booking status notification
  Future<void> sendTestBookingStatusNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await sendBookingStatusNotification(
        userId: user.uid,
        bookingId: 'test_booking_123',
        bookingNumber: 'BK-123',
        oldStatus: 'pending',
        newStatus: 'confirmed',
        userName: 'Test User',
        machineryName: 'Tractor X1000',
      );
    }
  }

  // Test order status notification for specific user
  Future<void> sendTestOrderStatusNotificationForUser(String userId) async {
    await sendOrderStatusNotification(
      userId: userId,
      orderId: 'test_order_123',
      orderNumber: 'ORD-123',
      oldStatus: 'pending',
      newStatus: 'confirmed',
      userName: 'Test User',
    );
  }

  // Send new order notification to all admins
  Future<void> sendNewOrderNotificationToAdmins({
    required String orderId,
    required String orderNumber,
    required String customerName,
    required double totalAmount,
    required int itemCount,
  }) async {
    try {
      print('Sending new order notification to admins for order: $orderId');

      // Get all admin users
      final adminUsers = await _firestore
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .get();

      print('Found ${adminUsers.docs.length} admin users');

      for (final adminDoc in adminUsers.docs) {
        final adminId = adminDoc.id;
        final adminData = adminDoc.data();
        final adminName = adminData['name'] ?? 'Admin';

        // Create notification data
        final notificationData = {
          'type': 'new_order',
          'orderId': orderId,
          'orderNumber': orderNumber,
          'customerName': customerName,
          'totalAmount': totalAmount,
          'itemCount': itemCount,
        };

        // Save notification to admin's Firestore
        await _firestore
            .collection('users')
            .doc(adminId)
            .collection('notifications')
            .add({
          'title': 'New Order Received',
          'body':
              'New order #$orderNumber from $customerName for GHS ${totalAmount.toStringAsFixed(2)}',
          'type': 'new_order',
          'data': notificationData,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

        // Check if the current user is this admin
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.uid == adminId) {
          // Show local notification if admin is currently using the app
          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/launcher_icon',
          );

          const DarwinNotificationDetails iOSPlatformChannelSpecifics =
              DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iOSPlatformChannelSpecifics,
          );

          final notificationId =
              DateTime.now().millisecondsSinceEpoch.remainder(100000);
          await _localNotifications.show(
            notificationId,
            'New Order Received',
            'New order #$orderNumber from $customerName for GHS ${totalAmount.toStringAsFixed(2)}',
            platformChannelSpecifics,
            payload: json.encode(notificationData),
          );

          print('Local notification shown to admin with ID: $notificationId');
        }
      }

      print('New order notifications sent to all admins');
    } catch (e) {
      print('Error sending new order notification to admins: $e');
    }
  }

  // Send new booking notification to all admins
  Future<void> sendNewBookingNotificationToAdmins({
    required String bookingId,
    required String bookingNumber,
    required String customerName,
    required String machineryName,
    required DateTime startDate,
    required DateTime endDate,
    required double totalAmount,
  }) async {
    try {
      print(
          'Sending new booking notification to admins for booking: $bookingId');

      // Get all admin users
      final adminUsers = await _firestore
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .get();

      print('Found ${adminUsers.docs.length} admin users');

      for (final adminDoc in adminUsers.docs) {
        final adminId = adminDoc.id;
        final adminData = adminDoc.data();
        final adminName = adminData['name'] ?? 'Admin';

        // Create notification data
        final notificationData = {
          'type': 'new_booking',
          'bookingId': bookingId,
          'bookingNumber': bookingNumber,
          'customerName': customerName,
          'machineryName': machineryName,
          'startDate': startDate,
          'endDate': endDate,
          'totalAmount': totalAmount,
        };

        // Save notification to admin's Firestore
        await _firestore
            .collection('users')
            .doc(adminId)
            .collection('notifications')
            .add({
          'title': 'New Booking Received',
          'body':
              'New booking #$bookingNumber from $customerName for $machineryName',
          'type': 'new_booking',
          'data': notificationData,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

        // Check if the current user is this admin
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.uid == adminId) {
          // Show local notification if admin is currently using the app
          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/launcher_icon',
          );

          const DarwinNotificationDetails iOSPlatformChannelSpecifics =
              DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iOSPlatformChannelSpecifics,
          );

          final notificationId =
              DateTime.now().millisecondsSinceEpoch.remainder(100000);
          await _localNotifications.show(
            notificationId,
            'New Booking Received',
            'New booking #$bookingNumber from $customerName for $machineryName',
            platformChannelSpecifics,
            payload: json.encode(notificationData),
          );

          print('Local notification shown to admin with ID: $notificationId');
        }
      }

      print('New booking notifications sent to all admins');
    } catch (e) {
      print('Error sending new booking notification to admins: $e');
    }
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');

  // Save notification to Firestore
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': message.notification?.title ?? 'Notification',
        'body': message.notification?.body ?? '',
        'type': message.data['type'] ?? 'general',
        'data': message.data,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error saving background notification: $e');
    }
  }
}
