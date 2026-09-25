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
          make: 'Toyota',
          model: 'Corolla',
          year: 2020,
          trim: 'SE',
          vin: '4T1B11HK5LU123456',
          mileage: '45,230 km',
          fuelType: 'Gasoline',
          transmission: 'Automatic',
          isDefault: true,
          bodyType: 'Sedan',
          color: 'Super White',
          licensePlate: 'TOY-2020',
          engineSize: '2.0L 4-Cylinder',
          horsepower: '169 hp',
          torque: '205 Nm',
          drivetrain: 'FWD',
          fuelCapacity: '50 L',
          oilType: '0W-20 Full Synthetic',
          tireSize: '225/40 R18',
          insuranceProvider: 'State Farm',
          policyNumber: 'SF-10029384',
          serviceCenter: 'Toyota Service Hub',
          notes: 'Regular oil changes done every 5,000 km.',
          description: 'Reliable 4-door compact sedan featuring Toyota Safety Sense 2.0, dynamic force 2.0L engine, and impressive fuel efficiency ideal for daily commuting and long trips.',
          imagePath: 'assets/images/toyota_corolla.jpg',
        ),
        VehicleModel(
          id: 'v2',
          make: 'Honda',
          model: 'Civic',
          year: 2018,
          trim: 'EX Sedan',
          vin: '1HGFC2F59JH102938',
          mileage: '78,400 km',
          fuelType: 'Gasoline',
          transmission: 'Automatic',
          isDefault: false,
          bodyType: 'Sedan',
          color: 'Sonic Gray Pearl',
          licensePlate: 'HND-2018',
          engineSize: '2.0L 4-Cylinder',
          horsepower: '158 hp',
          torque: '187 Nm',
          drivetrain: 'FWD',
          fuelCapacity: '47 L',
          oilType: '0W-20 Synthetic',
          tireSize: '215/55 R16',
          insuranceProvider: 'Geico',
          policyNumber: 'GC-992011',
          serviceCenter: 'Honda Care Center',
          notes: 'Reliable commuter car.',
          description: 'Sleek 10th gen EX sedan equipped with Honda Sensing suite, touchscreen infotainment, smooth CVT transmission, and responsive sporty handling.',
          imagePath: 'assets/images/honda_civic.jpg',
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
