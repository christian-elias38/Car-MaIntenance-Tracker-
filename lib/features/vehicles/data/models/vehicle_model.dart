class VehicleModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String trim;
  final String vin;
  final String mileage;
  final String fuelType;
  final String transmission;
  final bool isDefault;

  // Extended Specific Details
  final String bodyType;
  final String color;
  final String licensePlate;
  final String engineSize;
  final String horsepower;
  final String torque;
  final String drivetrain;
  final String fuelCapacity;
  final String oilType;
  final String tireSize;
  final String insuranceProvider;
  final String policyNumber;
  final String serviceCenter;
  final String notes;
  final String imagePath;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.trim = '',
    required this.vin,
    required this.mileage,
    this.fuelType = 'Gasoline',
    this.transmission = 'Automatic',
    this.isDefault = false,
    this.bodyType = 'Sedan',
    this.color = 'Midnight Black',
    this.licensePlate = '',
    this.engineSize = '2.0L 4-Cylinder',
    this.horsepower = '169 hp',
    this.torque = '205 Nm',
    this.drivetrain = 'FWD',
    this.fuelCapacity = '50 L',
    this.oilType = '0W-20 Full Synthetic',
    this.tireSize = '225/45 R17',
    this.insuranceProvider = '',
    this.policyNumber = '',
    this.serviceCenter = 'Authorized Service Center',
    this.notes = '',
    this.imagePath = 'assets/images/cool_car_landing.jpg',
  });

  String get displayName => trim.isNotEmpty ? '$make $model $trim' : '$make $model';
  String get titleWithYear => '$displayName ($year)';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year'].toString()) ?? 2022,
      trim: json['trim'] ?? '',
      vin: json['vin'] ?? '',
      mileage: json['mileage'] ?? '0 km',
      fuelType: json['fuelType'] ?? 'Gasoline',
      transmission: json['transmission'] ?? 'Automatic',
      isDefault: json['isDefault'] ?? false,
      bodyType: json['bodyType'] ?? 'Sedan',
      color: json['color'] ?? 'Black',
      licensePlate: json['licensePlate'] ?? '',
      engineSize: json['engineSize'] ?? '2.0L 4-Cylinder',
      horsepower: json['horsepower'] ?? '169 hp',
      torque: json['torque'] ?? '205 Nm',
      drivetrain: json['drivetrain'] ?? 'FWD',
      fuelCapacity: json['fuelCapacity'] ?? '50 L',
      oilType: json['oilType'] ?? '0W-20 Full Synthetic',
      tireSize: json['tireSize'] ?? '225/45 R17',
      insuranceProvider: json['insuranceProvider'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      serviceCenter: json['serviceCenter'] ?? 'Authorized Service Center',
      notes: json['notes'] ?? '',
      imagePath: json['imagePath'] ?? 'assets/images/cool_car_landing.jpg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'trim': trim,
      'vin': vin,
      'mileage': mileage,
      'fuelType': fuelType,
      'transmission': transmission,
      'isDefault': isDefault,
      'bodyType': bodyType,
      'color': color,
      'licensePlate': licensePlate,
      'engineSize': engineSize,
      'horsepower': horsepower,
      'torque': torque,
      'drivetrain': drivetrain,
      'fuelCapacity': fuelCapacity,
      'oilType': oilType,
      'tireSize': tireSize,
      'insuranceProvider': insuranceProvider,
      'policyNumber': policyNumber,
      'serviceCenter': serviceCenter,
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  VehicleModel copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? trim,
    String? vin,
    String? mileage,
    String? fuelType,
    String? transmission,
    bool? isDefault,
    String? bodyType,
    String? color,
    String? licensePlate,
    String? engineSize,
    String? horsepower,
    String? torque,
    String? drivetrain,
    String? fuelCapacity,
    String? oilType,
    String? tireSize,
    String? insuranceProvider,
    String? policyNumber,
    String? serviceCenter,
    String? notes,
    String? imagePath,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      trim: trim ?? this.trim,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      isDefault: isDefault ?? this.isDefault,
      bodyType: bodyType ?? this.bodyType,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      engineSize: engineSize ?? this.engineSize,
      horsepower: horsepower ?? this.horsepower,
      torque: torque ?? this.torque,
      drivetrain: drivetrain ?? this.drivetrain,
      fuelCapacity: fuelCapacity ?? this.fuelCapacity,
      oilType: oilType ?? this.oilType,
      tireSize: tireSize ?? this.tireSize,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      policyNumber: policyNumber ?? this.policyNumber,
      serviceCenter: serviceCenter ?? this.serviceCenter,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
