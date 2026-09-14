import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vehicles/presentation/providers/vehicle_provider.dart';
import '../../data/models/reminder_model.dart';
import '../providers/reminder_provider.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    final dateController = TextEditingController(text: '2025-05-20');
    final mileageController = TextEditingController(text: '50,000 km');
    String selectedCategory = 'Oil Change';

    final categories = ['Oil Change', 'Tire Rotation', 'Brake Service', 'Engine Check', 'Battery', 'General Inspection'];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Maintenance Reminder'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Reminder Title',
                      hintText: 'e.g. 50,000 km Major Service',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      hintText: '2025-05-20',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: mileageController,
                    decoration: const InputDecoration(
                      labelText: 'Target Mileage',
                      hintText: '50,000 km',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;

                  final activeCar = context.read<VehicleProvider>().activeVehicle;
                  final reminder = ReminderModel(
                    id: '',
                    vehicleId: activeCar?.id ?? 'v1',
                    carName: activeCar?.displayName ?? 'Toyota Corolla',
                    title: titleController.text.trim(),
                    dueDate: dateController.text.trim(),
                    dueMileage: mileageController.text.trim(),
                    serviceCategory: selectedCategory,
                  );

                  context.read<ReminderProvider>().addReminder(reminder);
                  Navigator.pop(dialogCtx);
                },
                child: const Text('Save Reminder'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reminderProvider = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Reminders'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryLight,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: [
            Tab(text: 'Upcoming (${reminderProvider.upcomingReminders.length})'),
            Tab(text: 'Completed (${reminderProvider.completedReminders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReminderList(context, reminderProvider.upcomingReminders, isDark, false),
          _buildReminderList(context, reminderProvider.completedReminders, isDark, true),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderDialog(context),
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        icon: const Icon(Icons.alarm_add, color: Colors.white),
        label: const Text('Add Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReminderList(
    BuildContext context,
    List<ReminderModel> list,
    bool isDark,
    bool isCompletedTab,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompletedTab ? Icons.check_circle_outline : Icons.notifications_off_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              isCompletedTab ? 'No completed reminders yet' : 'No upcoming reminders scheduled',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isCompletedTab
                  ? 'Completed tasks will appear here.'
                  : 'Tap + to set a reminder for your next oil change or inspection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Checkbox(
              value: item.isCompleted,
              activeColor: AppColors.primaryLight,
              onChanged: (_) {
                context.read<ReminderProvider>().toggleReminderComplete(item.id);
              },
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                color: item.isCompleted
                    ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${item.carName} • ${item.serviceCategory}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 14, color: AppColors.primaryLight),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${item.dueDate} (${item.dueMileage})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
              onPressed: () {
                context.read<ReminderProvider>().deleteReminder(item.id);
              },
            ),
          ),
        );
      },
    );
  }
}
