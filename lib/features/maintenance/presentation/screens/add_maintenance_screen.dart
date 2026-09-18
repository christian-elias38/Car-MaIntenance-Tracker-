import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/maintenance_model.dart';
import '../../../vehicles/presentation/providers/vehicle_provider.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../providers/maintenance_provider.dart';

class AddMaintenanceScreen extends StatefulWidget {
  const AddMaintenanceScreen({super.key});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _costController = TextEditingController();
  final _dateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Oil Change';

  final List<Map<String, dynamic>> _serviceCategories = [
    {'name': 'Oil Change', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF0EA5E9)},
    {'name': 'Tire Rotation', 'icon': Icons.adjust_rounded, 'color': const Color(0xFF8B5CF6)},
    {'name': 'Brake Service', 'icon': Icons.disc_full_rounded, 'color': const Color(0xFFF59E0B)},
    {'name': 'Engine Check', 'icon': Icons.minor_crash_rounded, 'color': const Color(0xFFEF4444)},
    {'name': 'Battery', 'icon': Icons.battery_charging_full_rounded, 'color': const Color(0xFF10B981)},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded, 'color': const Color(0xFF64748B)},
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final activeCar = context.read<VehicleProvider>().activeVehicle;
    if (activeCar != null) {
      _mileageController.text = activeCar.mileage.replaceAll(RegExp(r'[^0-9]'), '');
    } else {
      _mileageController.text = '45230';
    }
  }

  @override
  void dispose() {
    _costController.dispose();
    _dateController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primaryLight,
                    onPrimary: Colors.white,
                    surface: AppColors.darkCard,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicleProvider = context.read<VehicleProvider>();
    final activeCar = vehicleProvider.activeVehicle;
    final carName = activeCar?.titleWithYear ?? 'Toyota Corolla (2020)';
    final mileageFormatted = '${_mileageController.text.trim()} km';

    final record = MaintenanceModel(
      id: '',
      carName: carName,
      serviceType: _selectedCategory,
      cost: _costController.text.trim(),
      date: _dateController.text.trim(),
      notes: _notesController.text.trim(),
      mileage: mileageFormatted,
      vehicleId: activeCar?.id ?? 'v1',
      category: _selectedCategory,
      status: 'Completed',
    );

    final success = await context.read<MaintenanceProvider>().addRecord(record);

    if (activeCar != null) {
      final updatedCar = activeCar.copyWith(mileage: mileageFormatted);
      vehicleProvider.updateVehicle(updatedCar);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Service record saved successfully!' : 'Failed to save record.'),
          backgroundColor: success ? AppColors.primaryLight : AppColors.danger,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicleProvider = context.watch<VehicleProvider>();
    final userProvider = context.watch<UserProvider>();
    final vehicles = vehicleProvider.vehicles;
    final activeVehicle = vehicleProvider.activeVehicle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service'),
        elevation: 0,
      ),
      body: Consumer<MaintenanceProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Vehicle Dropdown Card
                  Text(
                    'Select Vehicle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: activeVehicle?.id,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                        items: vehicles.map((v) {
                          return DropdownMenuItem<String>(
                            value: v.id,
                            child: Row(
                              children: [
                                const Icon(Icons.directions_car_rounded, color: AppColors.primaryLight),
                                const SizedBox(width: 10),
                                Text(
                                  v.titleWithYear,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            vehicleProvider.selectVehicle(id);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Service Type Grid (Matching design mockup #5)
                  Text(
                    'Service Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: _serviceCategories.length,
                    itemBuilder: (context, index) {
                      final item = _serviceCategories[index];
                      final name = item['name'] as String;
                      final icon = item['icon'] as IconData;
                      final isSelected = _selectedCategory == name;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = name);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.darkSurface : AppColors.mintBackground)
                                : (isDark ? AppColors.darkCard : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryLight.withValues(alpha: 0.2)
                                      : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected ? AppColors.primaryLight : (item['color'] as Color),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Date & Mileage Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _pickDate,
                              decoration: const InputDecoration(
                                hintText: 'Select date',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mileage (km)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _mileageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '45230',
                                prefixIcon: Icon(Icons.speed_outlined),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Cost Field
                  Text(
                    'Cost (${userProvider.currency})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 120',
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: userProvider.currency,
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter cost' : null,
                  ),
                  const SizedBox(height: 20),

                  // Notes Field
                  Text(
                    'Notes (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Used synthetic oil, checked fluid levels...',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Service Button
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Save Service',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
