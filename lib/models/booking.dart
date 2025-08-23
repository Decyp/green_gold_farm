import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String machineryId;
  final String machineryName;
  final String machineryType;
  final String machineryModel;
  final double dailyRate;
  final int duration; // in days
  final double totalAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // pending, confirmed, active, completed, cancelled
  final String? notes;
  final String phoneNumber;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.machineryId,
    required this.machineryName,
    required this.machineryType,
    required this.machineryModel,
    required this.dailyRate,
    required this.duration,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.notes,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      machineryId: data['machineryId'] ?? '',
      machineryName: data['machineryName'] ?? '',
      machineryType: data['machineryType'] ?? '',
      machineryModel: data['machineryModel'] ?? '',
      dailyRate: (data['dailyRate'] ?? 0.0).toDouble(),
      duration: data['duration'] ?? 0,
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
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
      'dailyRate': dailyRate,
      'duration': duration,
      'totalAmount': totalAmount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
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

  Booking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? machineryId,
    String? machineryName,
    String? machineryType,
    String? machineryModel,
    double? dailyRate,
    int? duration,
    double? totalAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? notes,
    String? phoneNumber,
    String? deliveryAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      machineryId: machineryId ?? this.machineryId,
      machineryName: machineryName ?? this.machineryName,
      machineryType: machineryType ?? this.machineryType,
      machineryModel: machineryModel ?? this.machineryModel,
      dailyRate: dailyRate ?? this.dailyRate,
      duration: duration ?? this.duration,
      totalAmount: totalAmount ?? this.totalAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
