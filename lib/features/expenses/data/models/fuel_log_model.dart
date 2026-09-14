class FuelLogModel {
  final String id;
  final String vehicleId;
  final String date;
  final String mileage;
  final double volume;
  final double totalCost;

  FuelLogModel({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.mileage,
    required this.volume,
    required this.totalCost,
  });

  factory FuelLogModel.fromJson(Map<String, dynamic> json) {
    return FuelLogModel(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      date: json['date'] ?? '',
      mileage: json['mileage'] ?? '',
      volume: (json['volume'] is num) ? (json['volume'] as num).toDouble() : 0.0,
      totalCost: (json['totalCost'] is num) ? (json['totalCost'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date,
      'mileage': mileage,
      'volume': volume,
      'totalCost': totalCost,
    };
  }
}
