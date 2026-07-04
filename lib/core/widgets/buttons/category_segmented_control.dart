import 'package:flutter/material.dart';

import '../../../features/vehicles/domain/entities/vehicle_entity.dart';
import '../../theme/app_colors.dart';

class CategorySegmentedControl extends StatelessWidget {
  const CategorySegmentedControl({required this.selected, required this.onChanged, super.key});
  final VehicleCategory selected;
  final ValueChanged<VehicleCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _segment('Buy', VehicleCategory.buy)),
        const SizedBox(width: 8),
        Expanded(child: _segment('Sell', VehicleCategory.sell)),
      ],
    );
  }

  Widget _segment(String label, VehicleCategory value) {
    final isSelected = selected == value;
    final colors = value == VehicleCategory.buy
        ? (bg: AppColors.buyBadgeBg, fg: AppColors.buyBadgeText)
        : (bg: AppColors.sellBadgeBg, fg: AppColors.sellBadgeText);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.bg : AppColors.surface,
            border: Border.all(color: isSelected ? colors.bg : AppColors.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? colors.fg : AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
