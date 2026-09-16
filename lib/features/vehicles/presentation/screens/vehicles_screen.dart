import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/add_vehicle_dialog.dart';
import '../../data/models/vehicle_model.dart';
import 'vehicle_details_screen.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  void _showAddDialog(BuildContext context, [VehicleModel? vehicleToEdit]) {
    showDialog(
      context: context,
      builder: (_) => AddVehicleDialog(vehicleToEdit: vehicleToEdit),
    );
  }

  void _confirmDelete(BuildContext context, String id, String carName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to remove $carName from your garage?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<VehicleProvider>().deleteVehicle(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicleProvider = context.watch<VehicleProvider>();
    final vehicles = vehicleProvider.vehicles;
    final activeVehicle = vehicleProvider.activeVehicle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 22),
                onPressed: () => _showAddDialog(context),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            final isActive = activeVehicle?.id == vehicle.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primaryLight
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: InkWell(
                onTap: () {
                  vehicleProvider.selectVehicle(vehicle.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Car Photo Thumbnail
                      Container(
                        width: 72,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            vehicle.make.toLowerCase().contains('toyota')
                                ? 'assets/images/toyota_corolla.jpg'
                                : 'assets/images/honda_civic.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  vehicle.displayName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                if (vehicle.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Default',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${vehicle.year} • ${vehicle.mileage}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${vehicle.fuelType} • ${vehicle.transmission}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action menu / Chevron
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        onSelected: (value) {
                          if (value == 'select') {
                            vehicleProvider.selectVehicle(vehicle.id);
                          } else if (value == 'default') {
                            vehicleProvider.setDefaultVehicle(vehicle.id);
                          } else if (value == 'edit') {
                            _showAddDialog(context, vehicle);
                          } else if (value == 'delete') {
                            _confirmDelete(context, vehicle.id, vehicle.displayName);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'select',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, size: 18),
                                SizedBox(width: 8),
                                Text('Select Active'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'default',
                            child: Row(
                              children: [
                                Icon(Icons.star_outline, size: 18),
                                SizedBox(width: 8),
                                Text('Set as Default'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Edit Details'),
                              ],
                            ),
                          ),
                          if (vehicles.length > 1)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete Vehicle', style: TextStyle(color: AppColors.danger)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Vehicle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
