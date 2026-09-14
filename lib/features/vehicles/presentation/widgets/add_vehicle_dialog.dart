import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';

class AddVehicleDialog extends StatefulWidget {
  final VehicleModel? vehicleToEdit;

  const AddVehicleDialog({super.key, this.vehicleToEdit});

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _vinController;
  late TextEditingController _mileageController;

  String _fuelType = 'Gasoline';
  String _transmission = 'Automatic';
  bool _isDefault = false;

  final List<String> _fuelTypes = ['Gasoline', 'Diesel', 'Hybrid', 'Electric'];
  final List<String> _transmissions = ['Automatic', 'Manual'];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;
    _makeController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(text: v != null ? v.year.toString() : '2022');
    _vinController = TextEditingController(text: v?.vin ?? '');
    _mileageController = TextEditingController(text: v?.mileage.replaceAll(RegExp(r'[^0-9]'), '') ?? '30000');
    _fuelType = v?.fuelType ?? 'Gasoline';
    _transmission = v?.transmission ?? 'Automatic';
    _isDefault = v?.isDefault ?? false;
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.vehicleToEdit != null;
    final vehicle = VehicleModel(
      id: widget.vehicleToEdit?.id ?? '',
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? 2022,
      vin: _vinController.text.trim(),
      mileage: '${_mileageController.text.trim()} km',
      fuelType: _fuelType,
      transmission: _transmission,
      isDefault: _isDefault,
    );

    final provider = context.read<VehicleProvider>();
    if (isEdit) {
      provider.updateVehicle(vehicle);
    } else {
      provider.addVehicle(vehicle);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.vehicleToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Vehicle' : 'Add New Vehicle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Make & Model Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeController,
                      decoration: const InputDecoration(
                        labelText: 'Make',
                        hintText: 'e.g. Toyota',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        hintText: 'e.g. Corolla',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Year & Mileage Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        hintText: '2022',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _mileageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Mileage (km)',
                        hintText: '45000',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // VIN Number
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'VIN Number (optional)',
                  hintText: 'e.g. 4T1B11HK5LU...',
                ),
              ),
              const SizedBox(height: 16),

              // Fuel Type Radio Dropdown
              Text(
                'Fuel Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _fuelTypes.map((type) {
                  final selected = _fuelType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    selectedColor: AppColors.primaryLight,
                    onSelected: (val) {
                      if (val) setState(() => _fuelType = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Transmission Choice
              Text(
                'Transmission',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _transmissions.map((trans) {
                  final selected = _transmission == trans;
                  return ChoiceChip(
                    label: Text(trans),
                    selected: selected,
                    selectedColor: AppColors.primaryLight,
                    onSelected: (val) {
                      if (val) setState(() => _transmission = trans);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Set as Default Checkbox
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as Default Vehicle'),
                activeColor: AppColors.primaryLight,
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    isEdit ? 'Update Vehicle' : 'Add Vehicle',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
