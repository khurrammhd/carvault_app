import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({required this.user, super.key});
  final UserEntity? user;

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String _displayName(UserEntity? user) {
    if (user == null) return '';
    final displayName = user.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) return displayName;
    final localPart = user.email.split('@').first;
    if (localPart.isEmpty) return user.email;
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 46),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting(), style: const TextStyle(fontSize: 13, color: AppColors.primaryContainer)),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.onPrimary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go(RoutePaths.profile),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.25), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(_initials(name), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
