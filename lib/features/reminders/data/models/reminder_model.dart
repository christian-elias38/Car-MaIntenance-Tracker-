class ReminderModel {
  final String id;
  final String vehicleId;
  final String carName;
  final String title;
  final String dueDate;
  final String dueMileage;
  final String serviceCategory;
  final bool isCompleted;

  ReminderModel({
    required this.id,
    required this.vehicleId,
    required this.carName,
    required this.title,
    required this.dueDate,
    required this.dueMileage,
    required this.serviceCategory,
    this.isCompleted = false,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? 'v1',
      carName: json['carName'] ?? 'Toyota Corolla',
      title: json['title'] ?? '',
      dueDate: json['dueDate'] ?? '',
      dueMileage: json['dueMileage'] ?? '',
      serviceCategory: json['serviceCategory'] ?? 'General Service',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'carName': carName,
      'title': title,
      'dueDate': dueDate,
      'dueMileage': dueMileage,
      'serviceCategory': serviceCategory,
      'isCompleted': isCompleted,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? vehicleId,
    String? carName,
    String? title,
    String? dueDate,
    String? dueMileage,
    String? serviceCategory,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      carName: carName ?? this.carName,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
