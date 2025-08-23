import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final String paymentMethod;
  final String shippingAddress;
  final String phoneNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.phoneNumber,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      shipping: (data['shipping'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      shippingAddress: data['shippingAddress'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'phoneNumber': phoneNumber,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? total,
    String? status,
    String? paymentMethod,
    String? shippingAddress,
    String? phoneNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String category;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.category,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'category': category,
    };
  }

  double get totalPrice => price * quantity;
}
