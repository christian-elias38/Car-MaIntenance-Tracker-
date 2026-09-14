class MaintenanceModel {
  final String id;
  final String carName;
  final String serviceType;
  final String cost;
  final String date;
  final String notes;
  final String mileage;
  final String vehicleId;
  final String category;
  final String status;

  MaintenanceModel({
    required this.id,
    required this.carName,
    required this.serviceType,
    required this.cost,
    required this.date,
    required this.notes,
    this.mileage = '45,210 km',
    this.vehicleId = 'v1',
    this.category = 'Oil Change',
    this.status = 'Completed',
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    final rawServiceType = json['serviceType'] ?? 'General Service';
    final rawNotes = json['notes'] ?? '';
    final rawCarName = json['carName'] ?? 'Toyota Corolla';
    final rawCost = json['cost'] ?? '0';

    return MaintenanceModel(
      id: json['id'].toString(),
      carName: rawCarName.toString().isNotEmpty ? rawCarName.toString() : 'Toyota Corolla',
      serviceType: rawServiceType.toString().isNotEmpty ? rawServiceType.toString() : 'General Service',
      cost: rawCost.toString(),
      date: json['date'] ?? '2025-04-10',
      notes: rawNotes.toString(),
      mileage: json['mileage'] != null && json['mileage'].toString().isNotEmpty
          ? json['mileage'].toString()
          : _extractOrFallbackMileage(rawNotes),
      vehicleId: json['vehicleId'] ?? 'v1',
      category: json['category'] ?? rawServiceType,
      status: json['status'] ?? 'Completed',
    );
  }

  static String _extractOrFallbackMileage(String notes) {
    if (notes.contains('km')) return notes;
    return '45,230 km';
  }

  Map<String, dynamic> toJson() {
    return {
      'carName': carName,
      'serviceType': serviceType,
      'cost': cost,
      'date': date,
      'notes': notes,
      'mileage': mileage,
      'vehicleId': vehicleId,
      'category': category,
      'status': status,
    };
  }

  MaintenanceModel copyWith({
    String? id,
    String? carName,
    String? serviceType,
    String? cost,
    String? date,
    String? notes,
    String? mileage,
    String? vehicleId,
    String? category,
    String? status,
  }) {
    return MaintenanceModel(
      id: id ?? this.id,
      carName: carName ?? this.carName,
      serviceType: serviceType ?? this.serviceType,
      cost: cost ?? this.cost,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      mileage: mileage ?? this.mileage,
      vehicleId: vehicleId ?? this.vehicleId,
      category: category ?? this.category,
      status: status ?? this.status,
    );
  }
}
