import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String quantity;
  final String imageUrl;
  final String description;
  final bool isAvailable;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.description,
    required this.isAvailable,
    required this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'description': description,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? quantity,
    String? imageUrl,
    String? description,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
