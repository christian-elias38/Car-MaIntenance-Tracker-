import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MaintenanceTip {
  final String title;
  final String content;
  final String category;
  final IconData icon;
  final Color accentColor;

  const MaintenanceTip({
    required this.title,
    required this.content,
    required this.category,
    required this.icon,
    required this.accentColor,
  });
}

class MaintenanceTipCard extends StatefulWidget {
  const MaintenanceTipCard({super.key});

  @override
  State<MaintenanceTipCard> createState() => _MaintenanceTipCardState();
}

class _MaintenanceTipCardState extends State<MaintenanceTipCard> {
  int _currentTipIndex = 0;

  static const List<MaintenanceTip> _tips = [
    MaintenanceTip(
      category: 'Pro Maintenance Tip',
      title: 'Tire Pressure & Fuel Economy',
      content: 'Checking tire pressure monthly can improve fuel efficiency by up to 3% and significantly prolong tread lifespan.',
      icon: Icons.tire_repair_rounded,
      accentColor: AppColors.primaryLight,
    ),
    MaintenanceTip(
      category: 'Engine Health Insight',
      title: 'Synthetic Oil Viscosity',
      content: 'Full synthetic oil withstands extreme engine temperatures up to 2x better than conventional oil, preventing sludge buildup.',
      icon: Icons.oil_barrel_rounded,
      accentColor: AppColors.statBlue,
    ),
    MaintenanceTip(
      category: 'Brake Safety Note',
      title: 'Brake Fluid Flush Schedule',
      content: 'Brake fluid absorbs moisture over time. Flushing every 2 years prevents pedal softness and internal brake line corrosion.',
      icon: Icons.disc_full_rounded,
      accentColor: AppColors.statAmber,
    ),
    MaintenanceTip(
      category: 'Battery Care Advisory',
      title: 'Terminal Corrosion Defense',
      content: 'Clean white corrosion deposits from battery terminals using baking soda & water to maintain peak starter power.',
      icon: Icons.battery_charging_full_rounded,
      accentColor: AppColors.statPurple,
    ),
  ];

  void _nextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tip = _tips[_currentTipIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : tip.accentColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : tip.accentColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Chip + Tip Navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: tip.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(tip.icon, size: 18, color: tip.accentColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tip.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: tip.accentColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _nextTip,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Next Tip',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            tip.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Content Text Card Body
          Text(
            tip.content,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Dot indicator bar
          Row(
            children: List.generate(_tips.length, (index) {
              final isSelected = index == _currentTipIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 6),
                width: isSelected ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? tip.accentColor
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
