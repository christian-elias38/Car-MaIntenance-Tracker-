import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/reminder_model.dart';

class ReminderProvider extends ChangeNotifier {
  static const String _storageKey = 'user_reminders_list';
  List<ReminderModel> _reminders = [];

  List<ReminderModel> get reminders => _reminders;
  List<ReminderModel> get upcomingReminders => _reminders.where((r) => !r.isCompleted).toList();
  List<ReminderModel> get completedReminders => _reminders.where((r) => r.isCompleted).toList();

  ReminderProvider() {
    _initReminders();
  }

  Future<void> _initReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawJson);
        _reminders = list.map((item) => ReminderModel.fromJson(item)).toList();
      }
    } catch (_) {}

    if (_reminders.isEmpty) {
      _reminders = [
        ReminderModel(
          id: 'r1',
          vehicleId: 'v1',
          carName: 'Toyota Corolla',
          title: 'Oil Change & Filter',
          dueDate: '2025-04-20',
          dueMileage: '48,000 km',
          serviceCategory: 'Oil Change',
          isCompleted: false,
        ),
        ReminderModel(
          id: 'r2',
          vehicleId: 'v1',
          carName: 'Toyota Corolla',
          title: 'Tire Rotation & Balance',
          dueDate: '2025-05-15',
          dueMileage: '50,000 km',
          serviceCategory: 'Tire Rotation',
          isCompleted: false,
        ),
        ReminderModel(
          id: 'r3',
          vehicleId: 'v1',
          carName: 'Toyota Corolla',
          title: 'Brake Pad & Fluid Check',
          dueDate: '2025-06-10',
          dueMileage: '52,000 km',
          serviceCategory: 'Brake Service',
          isCompleted: false,
        ),
      ];
      _saveToPrefs();
    }
    notifyListeners();
  }

  Future<void> addReminder(ReminderModel reminder) async {
    final newReminder = reminder.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _reminders.add(newReminder);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> toggleReminderComplete(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final current = _reminders[index];
      _reminders[index] = current.copyWith(isCompleted: !current.isCompleted);
      notifyListeners();
      await _saveToPrefs();
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_reminders.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }
}
