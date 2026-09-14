import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> categoryCosts;
  final String currency;

  const ExpenseChart({
    super.key,
    required this.categoryCosts,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = categoryCosts.values.fold(0.0, (sum, val) => sum + val);

    final categoryColors = {
      'Oil Change': const Color(0xFF0EA5E9),
      'Tire Rotation': const Color(0xFF8B5CF6),
      'Brake Service': const Color(0xFFF59E0B),
      'Engine Check': const Color(0xFFEF4444),
      'Battery': const Color(0xFF10B981),
      'Other': const Color(0xFF64748B),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                '$currency${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Multi-color progress bar
          if (total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: categoryCosts.entries.map((entry) {
                    final percent = entry.value / total;
                    if (percent <= 0) return const SizedBox.shrink();
                    final color = categoryColors[entry.key] ?? AppColors.primaryLight;
                    return Expanded(
                      flex: (percent * 100).round().clamp(1, 100),
                      child: Container(color: color),
                    );
                  }).toList(),
                ),
              ),
            )
          else
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),

          const SizedBox(height: 20),

          // Breakdown items list
          ...categoryCosts.entries.map((entry) {
            final percent = total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : '0';
            final color = categoryColors[entry.key] ?? AppColors.primaryLight;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$currency${entry.value.toStringAsFixed(0)} ($percent%)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
