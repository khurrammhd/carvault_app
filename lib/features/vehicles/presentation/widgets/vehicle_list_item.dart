import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Shared vehicle row shape used by both the Dashboard's recent-vehicles
/// list and the Vehicle List screen — identical everywhere except subtitle.
class VehicleListItem extends StatelessWidget {
  const VehicleListItem({
    required this.vehicle,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final VehicleEntity vehicle;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBuy = vehicle.category == VehicleCategory.buy;
    final badgeBg = isBuy ? AppColors.buyBadgeBg : AppColors.sellBadgeBg;
    final badgeText = isBuy ? AppColors.buyBadgeText : AppColors.sellBadgeText;
    final monogram = vehicle.make.isNotEmpty ? vehicle.make[0].toUpperCase() : '?';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.outlineFaint),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(monogram, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vehicle.regNumber, style: AppTextStyles.mono, overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textMuted), overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(100)),
              child: Text(isBuy ? 'Buy' : 'Sell', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeText)),
            ),
          ],
        ),
      ),
    );
  }
}
