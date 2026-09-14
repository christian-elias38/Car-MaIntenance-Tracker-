import 'package:flutter_test/flutter_test.dart';
import 'package:car_maintenance_tracker/features/maintenance/data/models/maintenance_model.dart';
import 'package:car_maintenance_tracker/features/vehicles/data/models/vehicle_model.dart';
import 'package:car_maintenance_tracker/main.dart';

void main() {
  testWidgets('App renders onboarding or main screen cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });

  test('MaintenanceModel json serialization and fallback test', () {
    final model = MaintenanceModel.fromJson({
      'id': '123',
      'carName': 'Toyota Corolla',
      'serviceType': 'Oil Change',
      'cost': '120',
      'date': '2025-04-10',
      'notes': 'Test notes',
    });

    expect(model.id, '123');
    expect(model.carName, 'Toyota Corolla');
    expect(model.serviceType, 'Oil Change');
    expect(model.cost, '120');
    expect(model.date, '2025-04-10');
    expect(model.notes, 'Test notes');
  });

  test('VehicleModel json serialization test', () {
    final vehicle = VehicleModel(
      id: 'v1',
      make: 'Honda',
      model: 'Civic',
      year: 2018,
      vin: '1HGFC2F59JH654321',
      mileage: '78,400 km',
      isDefault: true,
    );

    final json = vehicle.toJson();
    final restored = VehicleModel.fromJson(json);

    expect(restored.make, 'Honda');
    expect(restored.model, 'Civic');
    expect(restored.year, 2018);
    expect(restored.isDefault, true);
  });
}
