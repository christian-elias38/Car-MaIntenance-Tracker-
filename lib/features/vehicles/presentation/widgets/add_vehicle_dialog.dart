import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';
import 'app_vehicle_image.dart';

class AddVehicleDialog extends StatefulWidget {
  final VehicleModel? vehicleToEdit;

  const AddVehicleDialog({super.key, this.vehicleToEdit});

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Basic Info Controllers
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _trimController;
  late TextEditingController _colorController;
  late TextEditingController _licensePlateController;
  late TextEditingController _mileageController;

  // Engine & Performance Controllers
  late TextEditingController _engineSizeController;
  late TextEditingController _hpController;
  late TextEditingController _torqueController;
  late TextEditingController _fuelCapacityController;

  // Legal & Maintenance Controllers
  late TextEditingController _vinController;
  late TextEditingController _oilTypeController;
  late TextEditingController _tireSizeController;
  late TextEditingController _insuranceProviderController;
  late TextEditingController _policyNumberController;
  late TextEditingController _serviceCenterController;
  late TextEditingController _notesController;

  String _fuelType = 'Gasoline';
  String _transmission = 'Automatic';
  String _drivetrain = 'FWD';
  String _bodyType = 'Sedan';
  String _selectedImagePath = 'assets/images/cool_car_landing.jpg';
  bool _isDefault = false;

  final List<String> _fuelTypes = ['Gasoline', 'Diesel', 'Hybrid', 'Electric', 'Plug-in Hybrid'];
  final List<String> _transmissions = ['Automatic', 'Manual', 'CVT', 'Dual-Clutch'];
  final List<String> _drivetrains = ['FWD', 'RWD', 'AWD', '4WD'];
  final List<String> _bodyTypes = ['Sedan', 'SUV', 'Coupe', 'Convertible', 'Hatchback', 'Truck', 'Supercar'];

  final List<Map<String, String>> _imagePresets = [
    {'name': 'Phantom GT', 'path': 'assets/images/cool_car_landing.jpg'},
    {'name': 'Sport Sedan', 'path': 'assets/images/sport_sedan_red.jpg'},
    {'name': 'Toyota Corolla', 'path': 'assets/images/toyota_corolla.jpg'},
    {'name': 'Honda Civic', 'path': 'assets/images/honda_civic.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final v = widget.vehicleToEdit;

    _makeController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(text: v != null ? v.year.toString() : '2024');
    _trimController = TextEditingController(text: v?.trim ?? '');
    _colorController = TextEditingController(text: v?.color ?? 'Midnight Black');
    _licensePlateController = TextEditingController(text: v?.licensePlate ?? '');
    _mileageController = TextEditingController(text: v?.mileage.replaceAll(RegExp(r'[^0-9]'), '') ?? '15000');

    _engineSizeController = TextEditingController(text: v?.engineSize ?? '2.0L 4-Cylinder');
    _hpController = TextEditingController(text: v?.horsepower ?? '200 hp');
    _torqueController = TextEditingController(text: v?.torque ?? '250 Nm');
    _fuelCapacityController = TextEditingController(text: v?.fuelCapacity ?? '55 L');

    _vinController = TextEditingController(text: v?.vin ?? '');
    _oilTypeController = TextEditingController(text: v?.oilType ?? '0W-20 Full Synthetic');
    _tireSizeController = TextEditingController(text: v?.tireSize ?? '225/45 R18');
    _insuranceProviderController = TextEditingController(text: v?.insuranceProvider ?? '');
    _policyNumberController = TextEditingController(text: v?.policyNumber ?? '');
    _serviceCenterController = TextEditingController(text: v?.serviceCenter ?? 'Authorized Center');
    _notesController = TextEditingController(text: v?.notes ?? '');

    _fuelType = v?.fuelType ?? 'Gasoline';
    _transmission = v?.transmission ?? 'Automatic';
    _drivetrain = v?.drivetrain ?? 'FWD';
    _bodyType = v?.bodyType ?? 'Sedan';
    _selectedImagePath = v?.imagePath ?? 'assets/images/cool_car_landing.jpg';
    _isDefault = v?.isDefault ?? false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _trimController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();

    _engineSizeController.dispose();
    _hpController.dispose();
    _torqueController.dispose();
    _fuelCapacityController.dispose();

    _vinController.dispose();
    _oilTypeController.dispose();
    _tireSizeController.dispose();
    _insuranceProviderController.dispose();
    _policyNumberController.dispose();
    _serviceCenterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.vehicleToEdit != null;
    final mileageText = _mileageController.text.trim();

    final vehicle = VehicleModel(
      id: widget.vehicleToEdit?.id ?? '',
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? 2024,
      trim: _trimController.text.trim(),
      vin: _vinController.text.trim(),
      mileage: mileageText.endsWith('km') ? mileageText : '$mileageText km',
      fuelType: _fuelType,
      transmission: _transmission,
      isDefault: _isDefault,
      bodyType: _bodyType,
      color: _colorController.text.trim(),
      licensePlate: _licensePlateController.text.trim(),
      engineSize: _engineSizeController.text.trim(),
      horsepower: _hpController.text.trim(),
      torque: _torqueController.text.trim(),
      drivetrain: _drivetrain,
      fuelCapacity: _fuelCapacityController.text.trim(),
      oilType: _oilTypeController.text.trim(),
      tireSize: _tireSizeController.text.trim(),
      insuranceProvider: _insuranceProviderController.text.trim(),
      policyNumber: _policyNumberController.text.trim(),
      serviceCenter: _serviceCenterController.text.trim(),
      notes: _notesController.text.trim(),
      imagePath: _selectedImagePath,
    );

    final provider = context.read<VehicleProvider>();
    if (isEdit) {
      provider.updateVehicle(vehicle);
    } else {
      provider.addVehicle(vehicle);
    }

    Navigator.pop(context);
  }

  void _showCustomImageDialog(BuildContext context) {
    final controller = TextEditingController(text: _selectedImagePath);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_a_photo_rounded, color: AppColors.primaryLight),
            SizedBox(width: 8),
            Text('Vehicle Image / Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a file path from your device or an image URL:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. C:/Photos/my_car.jpg or https://...',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() => _selectedImagePath = text);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight),
            child: const Text('Apply Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.vehicleToEdit != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Modal Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_car_rounded, color: AppColors.primaryLight),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEdit ? 'Edit Specific Details' : 'Add New Vehicle',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Tab Bar for Categories
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryLight,
                labelColor: AppColors.primaryLight,
                unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline, size: 18), text: '1. Basic'),
                  Tab(icon: Icon(Icons.speed, size: 18), text: '2. Specs'),
                  Tab(icon: Icon(Icons.verified_user_outlined, size: 18), text: '3. Legal & Maint.'),
                ],
              ),
              const Divider(height: 1),

              // Tab Bar View Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: BASIC DETAILS
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _makeController,
                                  decoration: const InputDecoration(labelText: 'Make *', hintText: 'e.g. Porsche'),
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _modelController,
                                  decoration: const InputDecoration(labelText: 'Model *', hintText: 'e.g. 911 GT3'),
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _yearController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Year *', hintText: '2024'),
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _trimController,
                                  decoration: const InputDecoration(labelText: 'Trim / Package', hintText: 'e.g. Touring / GT'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _mileageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Current Odometer (km) *', hintText: '15000'),
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _licensePlateController,
                                  decoration: const InputDecoration(labelText: 'License Plate', hintText: 'XYZ-9876'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _colorController,
                            decoration: const InputDecoration(labelText: 'Exterior Color', hintText: 'e.g. Midnight Black / Carbon'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Body Style',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _bodyTypes.map((type) {
                              final selected = _bodyType == type;
                              return ChoiceChip(
                                label: Text(type),
                                selected: selected,
                                selectedColor: AppColors.primaryLight,
                                onSelected: (val) {
                                  if (val) setState(() => _bodyType = type);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          // Vehicle Photo / Graphic Selection Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Vehicle Graphic & Photo',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _showCustomImageDialog(context),
                                icon: const Icon(Icons.upload_file_rounded, size: 16),
                                label: const Text('Upload / Choose', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  side: const BorderSide(color: AppColors.primaryLight),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Live Selected Image Preview Container
                          Container(
                            width: double.infinity,
                            height: 110,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.mintBackground.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: AppVehicleImage(
                                    imagePath: _selectedImagePath,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Active Choice',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            'Or Select Preset Graphic Model:',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imagePresets.length,
                              itemBuilder: (ctx, i) {
                                final preset = _imagePresets[i];
                                final isSel = _selectedImagePath == preset['path'];
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedImagePath = preset['path']!),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSel ? AppColors.primaryLight : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: AppVehicleImage(
                                      imagePath: preset['path']!,
                                      width: 76,
                                      height: 50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TAB 2: ENGINE & SPECS
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _engineSizeController,
                                  decoration: const InputDecoration(labelText: 'Engine / Motor', hintText: '3.0L Twin-Turbo'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _hpController,
                                  decoration: const InputDecoration(labelText: 'Horsepower (hp)', hintText: '502 hp'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _torqueController,
                                  decoration: const InputDecoration(labelText: 'Torque (Nm)', hintText: '470 Nm'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _fuelCapacityController,
                                  decoration: const InputDecoration(labelText: 'Fuel/Battery Capacity', hintText: '64 L / 85 kWh'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Fuel / Power Type',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
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
                          const SizedBox(height: 16),
                          Text(
                            'Transmission Type',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
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
                          const SizedBox(height: 16),
                          Text(
                            'Drivetrain Layout',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: _drivetrains.map((drive) {
                              final selected = _drivetrain == drive;
                              return ChoiceChip(
                                label: Text(drive),
                                selected: selected,
                                selectedColor: AppColors.primaryLight,
                                onSelected: (val) {
                                  if (val) setState(() => _drivetrain = drive);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // TAB 3: LEGAL & MAINTENANCE
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _vinController,
                            decoration: const InputDecoration(
                              labelText: 'VIN Number',
                              hintText: '17-digit Vehicle Identification Number',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _oilTypeController,
                                  decoration: const InputDecoration(labelText: 'Oil Viscosity', hintText: '0W-20 Full Synth'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _tireSizeController,
                                  decoration: const InputDecoration(labelText: 'Tire Specification', hintText: '245/35 R20'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _insuranceProviderController,
                                  decoration: const InputDecoration(labelText: 'Insurance Co.', hintText: 'State Farm'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _policyNumberController,
                                  decoration: const InputDecoration(labelText: 'Policy Number', hintText: 'POL-12345'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _serviceCenterController,
                            decoration: const InputDecoration(labelText: 'Primary Service Center', hintText: 'Apex Hypercar Hub'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: const InputDecoration(labelText: 'Special Notes / Instructions', hintText: 'Custom tuning specs, warranty notes...'),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Set as Active Default Vehicle'),
                            thumbColor: WidgetStateProperty.all(AppColors.primaryLight),
                            value: _isDefault,
                            onChanged: (val) => setState(() => _isDefault = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          isEdit ? 'Save Changes' : 'Add Vehicle',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
