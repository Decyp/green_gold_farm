import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product.dart';
import '../models/machinery.dart';
import '../models/pricing.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/booking.dart';
import '../models/purchase.dart';
import 'notification_service.dart';

class FirebaseService {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Check if Firebase is properly initialized
  bool get isFirebaseAvailable {
    try {
      return _auth != null;
    } catch (e) {
      return false;
    }
  }

  // Getter for storage
  FirebaseStorage get storage => _storage;

  // Pricing Management
  Stream<List<Pricing>> getPricing() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('pricing')
          .where('isActive', isEqualTo: true)
          .orderBy('machineType')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Pricing.fromFirestore(doc)).toList();
      });
    } catch (e) {
      // print('Error getting pricing: $e');
      return Stream.value([]);
    }
  }

  Future<Pricing?> getPricingByMachineType(String machineType) async {
    if (!isFirebaseAvailable) return null;

    try {
      final querySnapshot = await _firestore
          .collection('pricing')
          .where('machineType', isEqualTo: machineType)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Pricing.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      // print('Error getting pricing for $machineType: $e');
      return null;
    }
  }

  Future<void> addPricing(Pricing pricing) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('pricing').add(pricing.toFirestore());
    } catch (e) {
      // print('Error adding pricing: $e');
    }
  }

  Future<void> updatePricing(Pricing pricing) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore
          .collection('pricing')
          .doc(pricing.id)
          .update(pricing.toFirestore());
    } catch (e) {
      // print('Error updating pricing: $e');
    }
  }

  Future<void> deletePricing(String pricingId) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('pricing').doc(pricingId).delete();
    } catch (e) {
      // print('Error deleting pricing: $e');
    }
  }

  // Admin Check
  Future<bool> isUserAdmin() async {
    if (!isFirebaseAvailable) return false;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Add timeout to prevent long delays
        firestore.DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 5));
        final data = doc.data() as Map<String, dynamic>?;
        return data?['role'] == 'admin' || data?['isAdmin'] == true;
      }
      return false;
    } catch (e) {
      // print('Error checking admin status: $e');
      return false;
    }
  }

  // Products
  Stream<List<Product>> getProducts({String? category}) {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      firestore.Query query = _firestore.collection('products');
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      });
    } catch (e) {
      // print('Error getting products: $e');
      return Stream.value([]);
    }
  }

  Future<void> addProduct(Product product) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('products').add(product.toFirestore());
    } catch (e) {
      // print('Error adding product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toFirestore());
    } catch (e) {
      // print('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      // print('Error deleting product: $e');
    }
  }

  // Machinery
  Stream<List<Machinery>> getMachinery({String? type, bool? availableOnly}) {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      firestore.Query query = _firestore.collection('machinery');

      // Filter by type if specified
      if (type != null && type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }

      // Filter by availability for customer-facing queries
      if (availableOnly == true) {
        query = query.where('isAvailable', isEqualTo: true);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Machinery.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error getting machinery: $e');
      return Stream.value([]);
    }
  }

  Future<void> addMachinery(Machinery machinery) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('machinery').add(machinery.toFirestore());
    } catch (e) {
      print('Error adding machinery: $e');
    }
  }

  Future<void> updateMachinery(Machinery machinery) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore
          .collection('machinery')
          .doc(machinery.id)
          .update(machinery.toFirestore());
    } catch (e) {
      print('Error updating machinery: $e');
    }
  }

  Future<void> deleteMachinery(String machineryId) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('machinery').doc(machineryId).delete();
    } catch (e) {
      print('Error deleting machinery: $e');
    }
  }

  // Get unique machine types from machinery collection
  Stream<List<String>> getMachineTypes() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('machinery')
          .where('isAvailable', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final machineryTypes = snapshot.docs
            .map((doc) => doc.data()['machineryType'] as String?)
            .where((type) => type != null && type.isNotEmpty)
            .map((type) => type!)
            .toSet()
            .toList();

        // Sort alphabetically
        machineryTypes.sort();
        return machineryTypes;
      });
    } catch (e) {
      print('Error getting machine types: $e');
      return Stream.value([]);
    }
  }

  // User Profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isFirebaseAvailable) return null;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        firestore.DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> profile) async {
    if (!isFirebaseAvailable) return;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(profile, firestore.SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Orders
  Future<void> createOrder(Map<String, dynamic> order) async {
    if (!isFirebaseAvailable) return;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        order['userId'] = user.uid;
        order['createdAt'] = firestore.Timestamp.now();

        // Create the order
        final orderDoc = await _firestore.collection('orders').add(order);
        final orderId = orderDoc.id;

        // Send notification to admins
        final notificationService = NotificationService();
        await notificationService.sendNewOrderNotificationToAdmins(
          orderId: orderId,
          orderNumber: orderId, // Using orderId as order number for now
          customerName: order['userName'] ?? 'Customer',
          totalAmount: order['total'] ?? 0.0,
          itemCount: (order['items'] as List?)?.length ?? 0,
        );
      }
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  Stream<List<Order>> getUserOrders() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
        });
      }
      return Stream.value([]);
    } catch (e) {
      print('Error getting user orders: $e');
      return Stream.value([]);
    }
  }

  // News/Updates
  Stream<List<Map<String, dynamic>>> getNews() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('news')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error getting news: $e');
      return Stream.value([]);
    }
  }

  // Cart
  Future<void> addToCart(String userId, CartItem cartItem) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItem.id.isEmpty ? cartItem.productId : cartItem.id)
          .set(cartItem.toFirestore());
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> removeFromCart(String userId, String cartItemId) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .delete();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> updateCartItemQuantity(
      String userId, String cartItemId, int quantity) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .update({'quantity': quantity});
    } catch (e) {
      print('Error updating cart item quantity: $e');
    }
  }

  Stream<List<CartItem>> getCart() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => CartItem.fromFirestore(doc))
              .toList();
        });
      }
      return Stream.value([]);
    } catch (e) {
      print('Error getting cart: $e');
      return Stream.value([]);
    }
  }

  Future<void> clearCart() async {
    if (!isFirebaseAvailable) return;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final cartSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();

        final batch = _firestore.batch();
        for (var doc in cartSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // User Management
  Stream<List<Map<String, dynamic>>> getUsers() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore.collection('users').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error getting users: $e');
      return Stream.value([]);
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('users').doc(userId).update(userData);
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  // Order Management
  Stream<List<Map<String, dynamic>>> getAllOrders() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error getting all orders: $e');
      return Stream.value([]);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (!isFirebaseAvailable) return;

    try {
      // Get the current order to get old status and user info
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        print('Order not found: $orderId');
        return;
      }

      final orderData = orderDoc.data()!;
      final oldStatus = orderData['status'] ?? 'pending';
      final userId = orderData['userId'] ?? '';
      final userName = orderData['userName'] ?? '';

      // Update the order status
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': firestore.Timestamp.now(),
      });

      // Send notification if status actually changed
      if (oldStatus != status && userId.isNotEmpty) {
        print('Sending notification to user: $userId for order: $orderId');
        print('Status changed from: $oldStatus to: $status');

        final notificationService = NotificationService();
        await notificationService.sendOrderStatusNotification(
          userId: userId,
          orderId: orderId,
          orderNumber: orderId, // Using orderId as order number for now
          oldStatus: oldStatus,
          newStatus: status,
          userName: userName,
        );
      } else {
        print(
            'No notification sent - oldStatus: $oldStatus, newStatus: $status, userId: $userId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  // Category Management
  Stream<List<Category>> getCategories(String type) {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('categories')
          .where('type', isEqualTo: type)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error getting categories: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Category>> getAllCategories() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('categories')
          .orderBy('type')
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error getting all categories: $e');
      return Stream.value([]);
    }
  }

  Future<void> addCategory(Category category) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('categories').add(category.toFirestore());
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(category.toFirestore());
    } catch (e) {
      print('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  // Booking Management
  Stream<List<Booking>> getUserBookings(String userId) {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error getting user bookings: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Booking>> getAllBookings() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error getting all bookings: $e');
      return Stream.value([]);
    }
  }

  Future<void> createBooking(Booking booking) async {
    if (!isFirebaseAvailable) return;

    try {
      // Create the booking
      final bookingDoc =
          await _firestore.collection('bookings').add(booking.toFirestore());
      final bookingId = bookingDoc.id;

      // Send notification to admins
      final notificationService = NotificationService();
      await notificationService.sendNewBookingNotificationToAdmins(
        bookingId: bookingId,
        bookingNumber: bookingId, // Using bookingId as booking number for now
        customerName: booking.userName,
        machineryName: booking.machineryName,
        startDate: booking.startDate,
        endDate: booking.endDate,
        totalAmount: booking.totalAmount,
      );
    } catch (e) {
      print('Error creating booking: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (!isFirebaseAvailable) return;

    try {
      // Get the current booking to get old status and user info
      final bookingDoc =
          await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        print('Booking not found: $bookingId');
        return;
      }

      final bookingData = bookingDoc.data()!;
      final oldStatus = bookingData['status'] ?? 'pending';
      final userId = bookingData['userId'] ?? '';
      final userName = bookingData['userName'] ?? '';
      final machineryName = bookingData['machineryName'] ?? 'Machinery';

      // Update the booking status
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': firestore.Timestamp.now(),
      });

      // Send notification if status actually changed
      if (oldStatus != status && userId.isNotEmpty) {
        final notificationService = NotificationService();
        await notificationService.sendBookingStatusNotification(
          userId: userId,
          bookingId: bookingId,
          bookingNumber: bookingId, // Using bookingId as booking number for now
          oldStatus: oldStatus,
          newStatus: status,
          userName: userName,
          machineryName: machineryName,
        );
      }
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Failed to update booking status: $e');
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      print('Error deleting booking: $e');
    }
  }

  // Purchase Management
  Stream<List<Purchase>> getUserPurchases(String userId) {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('purchases')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Purchase.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error getting user purchases: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Purchase>> getAllPurchases() {
    if (!isFirebaseAvailable) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('purchases')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Purchase.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error getting all purchases: $e');
      return Stream.value([]);
    }
  }

  Future<void> createPurchase(Purchase purchase) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('purchases').add(purchase.toFirestore());
    } catch (e) {
      print('Error creating purchase: $e');
      throw Exception('Failed to create purchase: $e');
    }
  }

  Future<void> updatePurchaseStatus(String purchaseId, String status) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('purchases').doc(purchaseId).update({
        'status': status,
        'updatedAt': firestore.Timestamp.now(),
      });
    } catch (e) {
      print('Error updating purchase status: $e');
    }
  }

  Future<void> deletePurchase(String purchaseId) async {
    if (!isFirebaseAvailable) return;

    try {
      await _firestore.collection('purchases').doc(purchaseId).delete();
    } catch (e) {
      print('Error deleting purchase: $e');
    }
  }

  // Collection Count Methods
  Stream<int> getCollectionCount(String collectionName) {
    if (!isFirebaseAvailable) {
      return Stream.value(0);
    }

    try {
      return _firestore
          .collection(collectionName)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      print('Error getting collection count for $collectionName: $e');
      return Stream.value(0);
    }
  }

  Stream<int> getUserCollectionCount(String collectionName, String userId) {
    if (!isFirebaseAvailable) {
      return Stream.value(0);
    }

    try {
      return _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      print('Error getting user collection count for $collectionName: $e');
      return Stream.value(0);
    }
  }

  // Notification Methods
  Stream<List<Map<String, dynamic>>> getUserNotifications() {
    print('getUserNotifications: Starting...');

    if (!isFirebaseAvailable) {
      print('getUserNotifications: Firebase not available');
      return Stream.value([]);
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('getUserNotifications: No current user');
        return Stream.value([]);
      }

      print('getUserNotifications: Current user ID: ${user.uid}');

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        print(
            'getUserNotifications: Got ${snapshot.docs.length} notifications');

        final notifications = snapshot.docs.map((doc) {
          final data = doc.data();
          final notification = {
            'id': doc.id,
            'title': data['title'] ?? '',
            'body': data['body'] ?? '',
            'type': data['type'] ?? 'general',
            'timestamp': data['timestamp'],
            'read': data['read'] ?? false,
          };
          print(
              'getUserNotifications: Notification ${doc.id}: ${notification['title']} - read: ${notification['read']}');
          return notification;
        }).toList();

        return notifications;
      });
    } catch (e) {
      print('Error getting user notifications: $e');
      return Stream.value([]);
    }
  }
}
