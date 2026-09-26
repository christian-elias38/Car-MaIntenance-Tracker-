import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ai_assistant/presentation/widgets/ai_vehicle_banner.dart';
import '../../data/models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/add_vehicle_dialog.dart';
import '../widgets/app_vehicle_image.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  void _showEditDialog(BuildContext context, VehicleModel currentVehicle) {
    showDialog(
      context: context,
      builder: (_) => AddVehicleDialog(vehicleToEdit: currentVehicle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicleProvider = context.watch<VehicleProvider>();
    final currentVehicle = vehicleProvider.vehicles.firstWhere(
      (v) => v.id == vehicle.id,
      orElse: () => vehicle,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentVehicle.displayName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditDialog(context, currentVehicle),
            tooltip: 'Edit Details',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Vehicle Photo Container with Badges Overlay & Tap to Change Photo
                      GestureDetector(
                        onTap: () => _showEditDialog(context, currentVehicle),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: isWide ? 320 : 230,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: AppVehicleImage(
                                imagePath: currentVehicle.imagePath,
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),

                    // Overlay Gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Change Photo Button Top Right
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Change Photo',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Title & License Plate Overlay
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  vehicle.displayName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${vehicle.year}  •  ${vehicle.mileage}  •  ${vehicle.bodyType}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (vehicle.licensePlate.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 4),
                                ],
                              ),
                              child: Text(
                                vehicle.licensePlate,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // AI Assistant Banner Card
              AiVehicleBanner(vehicle: vehicle),
              const SizedBox(height: 20),

              // Quick Specs Pills (Drivetrain, HP, Fuel, Transmission)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickBadge(context, Icons.flash_on_rounded, vehicle.horsepower, AppColors.primaryLight),
                    _buildQuickBadge(context, Icons.grid_view_rounded, vehicle.drivetrain, AppColors.info),
                    _buildQuickBadge(context, Icons.local_gas_station_rounded, vehicle.fuelType, AppColors.warning),
                    _buildQuickBadge(context, Icons.tune_rounded, vehicle.transmission, AppColors.accent),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full Vehicle Description Section
              if (vehicle.description.isNotEmpty) ...[
                _buildSectionTitle(context, '📖 Full Description & Overview', isDark),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    vehicle.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // SECTION 1: Engine & Performance
              _buildSectionTitle(context, '🏎️ Engine & Performance', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSpecRow(context, icon: Icons.speed_rounded, label: 'Engine Size', value: vehicle.engineSize, isDark: isDark),
                    const Divider(height: 20),
                    _buildSpecRow(context, icon: Icons.bolt_rounded, label: 'Horsepower', value: vehicle.horsepower, isDark: isDark),
                    const Divider(height: 20),
                    _buildSpecRow(context, icon: Icons.rotate_right_rounded, label: 'Torque', value: vehicle.torque, isDark: isDark),
                    const Divider(height: 20),
                    _buildSpecRow(context, icon: Icons.alt_route_rounded, label: 'Drivetrain', value: vehicle.drivetrain, isDark: isDark),
                    const Divider(height: 20),
                    _buildSpecRow(context, icon: Icons.local_gas_station_outlined, label: 'Fuel / Battery Capacity', value: vehicle.fuelCapacity, isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 2: Maintenance Specs
              _buildSectionTitle(context, '⚙️ Maintenance Specifications', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSpecRow(context, icon: Icons.opacity_rounded, label: 'Oil Viscosity', value: vehicle.oilType, isDark: isDark),
                    const Divider(height: 20),
                    _buildSpecRow(context, icon: Icons.tire_repair_rounded, label: 'Tire Specs', value: vehicle.tireSize, isDark: isDark),
                    const Divider(height: 20),
                    _buildSpecRow(context, icon: Icons.store_mall_directory_outlined, label: 'Service Center', value: vehicle.serviceCenter, isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 3: Legal & Registration
              _buildSectionTitle(context, '📄 Legal & Registration', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSpecRow(context, icon: Icons.fingerprint_rounded, label: 'VIN Number', value: vehicle.vin.isNotEmpty ? vehicle.vin : 'Not Set', isDark: isDark),
                    const Divider(height: 20),
                    _buildSpecRow(context, icon: Icons.pin_drop_outlined, label: 'License Plate', value: vehicle.licensePlate.isNotEmpty ? vehicle.licensePlate : 'Not Set', isDark: isDark),
                    const Divider(height: 20),
                    _buildSpecRow(context, icon: Icons.security_rounded, label: 'Insurance Co.', value: vehicle.insuranceProvider.isNotEmpty ? vehicle.insuranceProvider : 'Not Set', isDark: isDark),
                    const Divider(height: 20),
                    _buildSpecRow(context, icon: Icons.confirmation_number_outlined, label: 'Policy Number', value: vehicle.policyNumber.isNotEmpty ? vehicle.policyNumber : 'Not Set', isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 4: Notes (if any)
              if (vehicle.notes.isNotEmpty) ...[
                _buildSectionTitle(context, '📝 Notes & Instructions', isDark),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    vehicle.notes,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // Edit Vehicle Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context, currentVehicle),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  label: const Text(
                    'Edit All Vehicle Details',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                ),
              ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _buildQuickBadge(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
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
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
