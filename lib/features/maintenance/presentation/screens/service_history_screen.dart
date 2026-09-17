import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/maintenance_provider.dart';
import '../widgets/maintenance_card.dart';
import 'edit_maintenance_screen.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Oil Change', 'Tire Rotation', 'Brake'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<MaintenanceProvider>();

    final records = provider.records.where((r) {
      if (_selectedCategory == 'All') return true;
      return r.serviceType.toLowerCase().contains(_selectedCategory.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service History'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Horizontal Filter Chips (Matching Image 2 Screen 8)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLight,
                      backgroundColor: isDark ? AppColors.darkCard : AppColors.mintBackground,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Records list view
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: Text(
                        'No history for $_selectedCategory',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return MaintenanceCard(
                          record: record,
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditMaintenanceScreen(record: record),
                            ),
                          ),
                          onDelete: () => provider.deleteRecord(record.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
