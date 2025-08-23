import 'package:cloud_firestore/cloud_firestore.dart';

class Pricing {
  final String id;
  final String machineType;
  final double basePrice;
  final Map<String, double> durationMultipliers;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pricing({
    required this.id,
    required this.machineType,
    required this.basePrice,
    required this.durationMultipliers,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pricing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pricing(
      id: doc.id,
      machineType: data['machineType'] ?? '',
      basePrice: (data['basePrice'] ?? 0.0).toDouble(),
      durationMultipliers:
          Map<String, double>.from(data['durationMultipliers'] ?? {}),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'machineType': machineType,
      'basePrice': basePrice,
      'durationMultipliers': durationMultipliers,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Pricing copyWith({
    String? id,
    String? machineType,
    double? basePrice,
    Map<String, double>? durationMultipliers,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pricing(
      id: id ?? this.id,
      machineType: machineType ?? this.machineType,
      basePrice: basePrice ?? this.basePrice,
      durationMultipliers: durationMultipliers ?? this.durationMultipliers,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
