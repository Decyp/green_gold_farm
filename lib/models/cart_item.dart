import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String category;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.category,
    required this.addedAt,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImage: data['productImage'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      category: data['category'] ?? '',
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'category': category,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? category,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  double get totalPrice => price * quantity;
}
