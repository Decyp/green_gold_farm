import 'package:cloud_firestore/cloud_firestore.dart';

class Machinery {
  final String id;
  final String name;
  final String type; // rental or sale
  final String machineryType; // Tractor, Dozer, etc.
  final String model;
  final int horsepower;
  final double price;
  final String condition;
  final String description;
  final List<String> imageUrls;
  final bool isAvailable;
  final String location;
  final DateTime createdAt;

  // Technical Specifications
  final String? cabinType;
  final double? workingWeight;
  final double? workingLength;
  final double? workingWidth;
  final double? workingHeight;
  final double? trackWidth;
  final String? bladeType;
  final double? bladeCapacity;
  final double? bladeWidth;
  final String? ripperType;
  final String? engineManufacturer;
  final String? engineType;
  final double? enginePower;
  final String? fuelType;
  final int? yearOfManufacture;
  final String? serialNumber;

  // Tractor-specific specifications
  final double? powerKW;
  final double? powerHP;
  final String? wheelArrangement;
  final int? crankshaftRatedSpeed;
  final int? numberOfCylinders;
  final double? fuelTankCapacity;
  final String? numberOfGears;
  final double? liftingCapacity;
  final double? operatingWeight;
  final double? tractorBase;
  final double? agrotechnicalClearance;

  Machinery({
    required this.id,
    required this.name,
    required this.type,
    required this.machineryType,
    required this.model,
    required this.horsepower,
    required this.price,
    required this.condition,
    required this.description,
    required this.imageUrls,
    required this.isAvailable,
    required this.location,
    required this.createdAt,
    this.cabinType,
    this.workingWeight,
    this.workingLength,
    this.workingWidth,
    this.workingHeight,
    this.trackWidth,
    this.bladeType,
    this.bladeCapacity,
    this.bladeWidth,
    this.ripperType,
    this.engineManufacturer,
    this.engineType,
    this.enginePower,
    this.fuelType,
    this.yearOfManufacture,
    this.serialNumber,
    this.powerKW,
    this.powerHP,
    this.wheelArrangement,
    this.crankshaftRatedSpeed,
    this.numberOfCylinders,
    this.fuelTankCapacity,
    this.numberOfGears,
    this.liftingCapacity,
    this.operatingWeight,
    this.tractorBase,
    this.agrotechnicalClearance,
  });

  factory Machinery.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Machinery(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      machineryType: data['machineryType'] ?? '',
      model: data['model'] ?? '',
      horsepower: data['horsepower'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      condition: data['condition'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      location: data['location'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      cabinType: data['cabinType'],
      workingWeight: data['workingWeight']?.toDouble(),
      workingLength: data['workingLength']?.toDouble(),
      workingWidth: data['workingWidth']?.toDouble(),
      workingHeight: data['workingHeight']?.toDouble(),
      trackWidth: data['trackWidth']?.toDouble(),
      bladeType: data['bladeType'],
      bladeCapacity: data['bladeCapacity']?.toDouble(),
      bladeWidth: data['bladeWidth']?.toDouble(),
      ripperType: data['ripperType'],
      engineManufacturer: data['engineManufacturer'],
      engineType: data['engineType'],
      enginePower: data['enginePower']?.toDouble(),
      fuelType: data['fuelType'],
      yearOfManufacture: data['yearOfManufacture'],
      serialNumber: data['serialNumber'],
      powerKW: data['powerKW']?.toDouble(),
      powerHP: data['powerHP']?.toDouble(),
      wheelArrangement: data['wheelArrangement'],
      crankshaftRatedSpeed: data['crankshaftRatedSpeed'],
      numberOfCylinders: data['numberOfCylinders'],
      fuelTankCapacity: data['fuelTankCapacity']?.toDouble(),
      numberOfGears: data['numberOfGears'],
      liftingCapacity: data['liftingCapacity']?.toDouble(),
      operatingWeight: data['operatingWeight']?.toDouble(),
      tractorBase: data['tractorBase']?.toDouble(),
      agrotechnicalClearance: data['agrotechnicalClearance']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'machineryType': machineryType,
      'model': model,
      'horsepower': horsepower,
      'price': price,
      'condition': condition,
      'description': description,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'cabinType': cabinType,
      'workingWeight': workingWeight,
      'workingLength': workingLength,
      'workingWidth': workingWidth,
      'workingHeight': workingHeight,
      'trackWidth': trackWidth,
      'bladeType': bladeType,
      'bladeCapacity': bladeCapacity,
      'bladeWidth': bladeWidth,
      'ripperType': ripperType,
      'engineManufacturer': engineManufacturer,
      'engineType': engineType,
      'enginePower': enginePower,
      'fuelType': fuelType,
      'yearOfManufacture': yearOfManufacture,
      'serialNumber': serialNumber,
      'powerKW': powerKW,
      'powerHP': powerHP,
      'wheelArrangement': wheelArrangement,
      'crankshaftRatedSpeed': crankshaftRatedSpeed,
      'numberOfCylinders': numberOfCylinders,
      'fuelTankCapacity': fuelTankCapacity,
      'numberOfGears': numberOfGears,
      'liftingCapacity': liftingCapacity,
      'operatingWeight': operatingWeight,
      'tractorBase': tractorBase,
      'agrotechnicalClearance': agrotechnicalClearance,
    };
  }

  Machinery copyWith({
    String? id,
    String? name,
    String? type,
    String? machineryType,
    String? model,
    int? horsepower,
    double? price,
    String? condition,
    String? description,
    List<String>? imageUrls,
    bool? isAvailable,
    String? location,
    DateTime? createdAt,
    String? cabinType,
    double? workingWeight,
    double? workingLength,
    double? workingWidth,
    double? workingHeight,
    double? trackWidth,
    String? bladeType,
    double? bladeCapacity,
    double? bladeWidth,
    String? ripperType,
    String? engineManufacturer,
    String? engineType,
    double? enginePower,
    String? fuelType,
    int? yearOfManufacture,
    String? serialNumber,
    double? powerKW,
    double? powerHP,
    String? wheelArrangement,
    int? crankshaftRatedSpeed,
    int? numberOfCylinders,
    double? fuelTankCapacity,
    String? numberOfGears,
    double? liftingCapacity,
    double? operatingWeight,
    double? tractorBase,
    double? agrotechnicalClearance,
  }) {
    return Machinery(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      machineryType: machineryType ?? this.machineryType,
      model: model ?? this.model,
      horsepower: horsepower ?? this.horsepower,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      cabinType: cabinType ?? this.cabinType,
      workingWeight: workingWeight ?? this.workingWeight,
      workingLength: workingLength ?? this.workingLength,
      workingWidth: workingWidth ?? this.workingWidth,
      workingHeight: workingHeight ?? this.workingHeight,
      trackWidth: trackWidth ?? this.trackWidth,
      bladeType: bladeType ?? this.bladeType,
      bladeCapacity: bladeCapacity ?? this.bladeCapacity,
      bladeWidth: bladeWidth ?? this.bladeWidth,
      ripperType: ripperType ?? this.ripperType,
      engineManufacturer: engineManufacturer ?? this.engineManufacturer,
      engineType: engineType ?? this.engineType,
      enginePower: enginePower ?? this.enginePower,
      fuelType: fuelType ?? this.fuelType,
      yearOfManufacture: yearOfManufacture ?? this.yearOfManufacture,
      serialNumber: serialNumber ?? this.serialNumber,
      powerKW: powerKW ?? this.powerKW,
      powerHP: powerHP ?? this.powerHP,
      wheelArrangement: wheelArrangement ?? this.wheelArrangement,
      crankshaftRatedSpeed: crankshaftRatedSpeed ?? this.crankshaftRatedSpeed,
      numberOfCylinders: numberOfCylinders ?? this.numberOfCylinders,
      fuelTankCapacity: fuelTankCapacity ?? this.fuelTankCapacity,
      numberOfGears: numberOfGears ?? this.numberOfGears,
      liftingCapacity: liftingCapacity ?? this.liftingCapacity,
      operatingWeight: operatingWeight ?? this.operatingWeight,
      tractorBase: tractorBase ?? this.tractorBase,
      agrotechnicalClearance:
          agrotechnicalClearance ?? this.agrotechnicalClearance,
    );
  }
}
