import 'package:cloud_firestore/cloud_firestore.dart';

class Purchase {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String machineryId;
  final String machineryName;
  final String machineryType;
  final String machineryModel;
  final double price;
  final String status; // pending, confirmed, completed, cancelled
  final String? notes;
  final String phoneNumber;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Purchase({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.machineryId,
    required this.machineryName,
    required this.machineryType,
    required this.machineryModel,
    required this.price,
    required this.status,
    this.notes,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.createdAt,
    this.updatedAt,
  });

  factory Purchase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Purchase(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      machineryId: data['machineryId'] ?? '',
      machineryName: data['machineryName'] ?? '',
      machineryType: data['machineryType'] ?? '',
      machineryModel: data['machineryModel'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      phoneNumber: data['phoneNumber'] ?? '',
      deliveryAddress: data['deliveryAddress'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'machineryId': machineryId,
      'machineryName': machineryName,
      'machineryType': machineryType,
      'machineryModel': machineryModel,
      'price': price,
      'status': status,
      'notes': notes,
      'phoneNumber': phoneNumber,
      'deliveryAddress': deliveryAddress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
    if (updatedAt != null) {
      data['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }
    return data;
  }

  Purchase copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? machineryId,
    String? machineryName,
    String? machineryType,
    String? machineryModel,
    double? price,
    String? status,
    String? notes,
    String? phoneNumber,
    String? deliveryAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      machineryId: machineryId ?? this.machineryId,
      machineryName: machineryName ?? this.machineryName,
      machineryType: machineryType ?? this.machineryType,
      machineryModel: machineryModel ?? this.machineryModel,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
