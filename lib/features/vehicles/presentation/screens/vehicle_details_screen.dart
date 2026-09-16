import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/vehicle_model.dart';
import '../widgets/add_vehicle_dialog.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddVehicleDialog(vehicleToEdit: vehicle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorolla = vehicle.make.toLowerCase().contains('toyota');
    final carAssetPath = isCorolla
        ? 'assets/images/toyota_corolla.jpg'
        : 'assets/images/honda_civic.jpg';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Hero Photo Container
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    carAssetPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title & Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.displayName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.year}  •  ${vehicle.mileage}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (vehicle.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Specifications Card List (Matching Image 2 Screen 7)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSpecRow(
                      context,
                      icon: Icons.qr_code_rounded,
                      label: 'VIN',
                      value: vehicle.vin.isNotEmpty ? vehicle.vin : 'JTDBR32E5LJ001234',
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildSpecRow(
                      context,
                      icon: Icons.speed_rounded,
                      label: 'Engine',
                      value: '1.8L 4-Cylinder',
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildSpecRow(
                      context,
                      icon: Icons.local_gas_station_rounded,
                      label: 'Fuel Type',
                      value: vehicle.fuelType,
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildSpecRow(
                      context,
                      icon: Icons.tune_rounded,
                      label: 'Transmission',
                      value: vehicle.transmission,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Edit Vehicle Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _showEditDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Text(
                    'Edit Vehicle',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
