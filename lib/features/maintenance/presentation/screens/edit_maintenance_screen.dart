import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/maintenance_model.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../providers/maintenance_provider.dart';

class EditMaintenanceScreen extends StatefulWidget {
  final MaintenanceModel record;

  const EditMaintenanceScreen({super.key, required this.record});

  @override
  State<EditMaintenanceScreen> createState() => _EditMaintenanceScreenState();
}

class _EditMaintenanceScreenState extends State<EditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _carNameController;
  late TextEditingController _costController;
  late TextEditingController _dateController;
  late TextEditingController _mileageController;
  late TextEditingController _notesController;

  late String _selectedCategory;

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
    _carNameController = TextEditingController(text: widget.record.carName);
    _costController = TextEditingController(text: widget.record.cost);
    _dateController = TextEditingController(text: widget.record.date);
    _mileageController = TextEditingController(text: widget.record.mileage);
    _notesController = TextEditingController(text: widget.record.notes);
    _selectedCategory = widget.record.serviceType.isNotEmpty
        ? widget.record.serviceType
        : 'Oil Change';
  }

  @override
  void dispose() {
    _carNameController.dispose();
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
      initialDate: DateTime.tryParse(widget.record.date) ?? DateTime.now(),
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

    final updated = widget.record.copyWith(
      carName: _carNameController.text.trim(),
      serviceType: _selectedCategory,
      cost: _costController.text.trim(),
      date: _dateController.text.trim(),
      mileage: _mileageController.text.trim(),
      notes: _notesController.text.trim(),
      category: _selectedCategory,
    );

    final success = await context.read<MaintenanceProvider>().updateRecord(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Record updated successfully!' : 'Failed to update record.'),
          backgroundColor: success ? AppColors.primaryLight : AppColors.danger,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service Record'),
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
                  // Car Name Input
                  Text(
                    'Car Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _carNameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.directions_car_rounded),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter car name' : null,
                  ),
                  const SizedBox(height: 20),

                  // Category Selection Grid
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
                  const SizedBox(height: 20),

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
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
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
                              'Mileage',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _mileageController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.speed_outlined),
                              ),
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
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: userProvider.currency,
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter cost' : null,
                  ),
                  const SizedBox(height: 20),

                  // Notes Field
                  Text(
                    'Notes',
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
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        child: const Text(
                          'Update Record',
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
          );
        },
      ),
    );
  }
}
