class VehicleModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String vin;
  final String mileage;
  final String fuelType;
  final String transmission;
  final bool isDefault;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.mileage,
    this.fuelType = 'Gasoline',
    this.transmission = 'Automatic',
    this.isDefault = false,
  });

  String get displayName => '$make $model';
  String get titleWithYear => '$make $model ($year)';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year'].toString()) ?? 2020,
      vin: json['vin'] ?? '',
      mileage: json['mileage'] ?? '0 km',
      fuelType: json['fuelType'] ?? 'Gasoline',
      transmission: json['transmission'] ?? 'Automatic',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'mileage': mileage,
      'fuelType': fuelType,
      'transmission': transmission,
      'isDefault': isDefault,
    };
  }

  VehicleModel copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? mileage,
    String? fuelType,
    String? transmission,
    bool? isDefault,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
