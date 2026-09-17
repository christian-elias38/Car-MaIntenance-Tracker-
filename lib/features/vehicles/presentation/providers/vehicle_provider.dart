import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/vehicle_model.dart';

class VehicleProvider extends ChangeNotifier {
  static const String _storageKey = 'user_vehicles_list_v2';
  static const String _activeIdKey = 'active_vehicle_id';

  List<VehicleModel> _vehicles = [];
  String? _activeVehicleId;

  List<VehicleModel> get vehicles => _vehicles;

  VehicleModel? get activeVehicle {
    if (_vehicles.isEmpty) return null;
    if (_activeVehicleId != null) {
      final found = _vehicles.firstWhere(
        (v) => v.id == _activeVehicleId,
        orElse: () => _vehicles.first,
      );
      return found;
    }
    return _vehicles.firstWhere((v) => v.isDefault, orElse: () => _vehicles.first);
  }

  VehicleProvider() {
    _initVehicles();
  }

  Future<void> _initVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _activeVehicleId = prefs.getString(_activeIdKey);
      final rawJson = prefs.getString(_storageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawJson);
        _vehicles = list.map((item) => VehicleModel.fromJson(item)).toList();
      }
    } catch (_) {}

    if (_vehicles.isEmpty) {
      _vehicles = [
        VehicleModel(
          id: 'v1',
          make: 'Phantom',
          model: 'Aero GT',
          year: 2024,
          trim: 'Performance EV',
          vin: 'PH7709GT9928371X',
          mileage: '12,500 km',
          fuelType: 'Electric',
          transmission: 'Automatic',
          isDefault: true,
          bodyType: 'Supercar',
          color: 'Cyber Titanium & Emerald',
          licensePlate: 'PHANTOM-01',
          engineSize: 'Dual Electric Motors',
          horsepower: '850 hp',
          torque: '1050 Nm',
          drivetrain: 'AWD',
          fuelCapacity: '100 kWh Battery',
          oilType: 'Electric Powertrain Fluid',
          tireSize: '295/30 R21',
          insuranceProvider: 'Apex Global Insurance',
          policyNumber: 'APX-998822-GT',
          serviceCenter: 'Apex Hypercar Hub',
          notes: 'Ceramic coated exterior. Carbon ceramic brakes installed.',
          imagePath: 'assets/images/cool_car_landing.jpg',
        ),
        VehicleModel(
          id: 'v2',
          make: 'Alfa',
          model: 'Giulia Quad',
          year: 2023,
          trim: 'Bi-Turbo V6',
          vin: 'ZARFAGAV7N7612349',
          mileage: '28,400 km',
          fuelType: 'Gasoline',
          transmission: 'Automatic',
          isDefault: false,
          bodyType: 'Sport Sedan',
          color: 'Rosso Competizione',
          licensePlate: 'QUAD-505',
          engineSize: '2.9L Twin-Turbo V6',
          horsepower: '505 hp',
          torque: '600 Nm',
          drivetrain: 'RWD',
          fuelCapacity: '58 L',
          oilType: '5W-40 Full Synthetic',
          tireSize: '285/30 R19',
          insuranceProvider: 'Scuderia Mutual',
          policyNumber: 'SCU-404011',
          serviceCenter: 'Scuderia Performance Center',
          notes: 'Annual oil flush and spark plug check every 10,000 km.',
          imagePath: 'assets/images/sport_sedan_red.jpg',
        ),
        VehicleModel(
          id: 'v3',
          make: 'Toyota',
          model: 'Corolla',
          year: 2021,
          trim: 'SE Apex',
          vin: '4T1B11HK5LU123456',
          mileage: '45,230 km',
          fuelType: 'Gasoline',
          transmission: 'CVT',
          isDefault: false,
          bodyType: 'Sedan',
          color: 'Super White',
          licensePlate: 'TOY-2021',
          engineSize: '2.0L 4-Cylinder Dynamic Force',
          horsepower: '169 hp',
          torque: '205 Nm',
          drivetrain: 'FWD',
          fuelCapacity: '50 L',
          oilType: '0W-20 Synthetic',
          tireSize: '225/40 R18',
          insuranceProvider: 'State Farm',
          policyNumber: 'SF-10029384',
          serviceCenter: 'Toyota Certified Center',
          notes: 'Reliable daily driver. Regular 5,000 km maintenance.',
          imagePath: 'assets/images/toyota_corolla.jpg',
        ),
      ];
      _saveToPrefs();
    }
    notifyListeners();
  }

  Future<void> selectVehicle(String id) async {
    _activeVehicleId = id;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeIdKey, id);
    } catch (_) {}
  }

  Future<void> addVehicle(VehicleModel vehicle) async {
    final newVehicle = vehicle.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isDefault: _vehicles.isEmpty ? true : vehicle.isDefault,
    );

    if (newVehicle.isDefault) {
      _vehicles = _vehicles.map((v) => v.copyWith(isDefault: false)).toList();
    }

    _vehicles.add(newVehicle);
    _activeVehicleId = newVehicle.id;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      if (vehicle.isDefault) {
        _vehicles = _vehicles.map((v) => v.copyWith(isDefault: false)).toList();
      }
      _vehicles[index] = vehicle;
      notifyListeners();
      await _saveToPrefs();
    }
  }

  Future<void> deleteVehicle(String id) async {
    if (_vehicles.length <= 1) return; // Keep at least 1 vehicle
    _vehicles.removeWhere((v) => v.id == id);
    if (_activeVehicleId == id) {
      _activeVehicleId = _vehicles.first.id;
    }
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> setDefaultVehicle(String id) async {
    _vehicles = _vehicles.map((v) => v.copyWith(isDefault: v.id == id)).toList();
    _activeVehicleId = id;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_vehicles.map((v) => v.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
      if (_activeVehicleId != null) {
        await prefs.setString(_activeIdKey, _activeVehicleId!);
      }
    } catch (_) {}
  }
}
