import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/usecases/search_vehicles.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({required this.selected, required this.onSelected, super.key});
  final VehicleCategoryFilter selected;
  final ValueChanged<VehicleCategoryFilter> onSelected;

  static const _options = [
    (value: VehicleCategoryFilter.all, label: 'All'),
    (value: VehicleCategoryFilter.buy, label: 'Buy'),
    (value: VehicleCategoryFilter.sell, label: 'Sell'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in _options) ...[
          _Chip(label: option.label, isActive: selected == option.value, onTap: () => onSelected(option.value)),
          if (option != _options.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.chipInactiveBg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? AppColors.onPrimary : AppColors.textMedium),
        ),
      ),
    );
  }
}
