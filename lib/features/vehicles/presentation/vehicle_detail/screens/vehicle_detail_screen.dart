import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/route_paths.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/usecases/vehicle_usecases.dart';
import '../providers/vehicle_detail_providers.dart';

class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({required this.vehicleId, super.key});
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: vehicleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load vehicle: $e')),
        data: (vehicle) {
          if (vehicle == null) return const Center(child: Text('Vehicle not found.'));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(vehicle.regNumber, style: AppTextStyles.monoLarge),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.onPrimary, borderRadius: BorderRadius.circular(100)),
                          child: Text(
                            vehicle.category.name == 'buy' ? 'Buy' : 'Sell',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${vehicle.make} ${vehicle.model} · ${vehicle.year}',
                        style: const TextStyle(color: AppColors.primaryContainer, fontSize: 14.5)),
                    const SizedBox(height: 10),
                    Text('Added ${vehicle.addedAt.toLocal()}'.split('.').first,
                        style: const TextStyle(color: AppColors.primaryContainer, fontSize: 12.5)),
                  ],
                ),
              ),
              if (vehicle.notes != null && vehicle.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(vehicle.notes!, style: const TextStyle(color: AppColors.textMuted)),
              ],
              const SizedBox(height: 18),
              Text('Documents · ${vehicle.documentCount}', style: AppTextStyles.sectionHeader),
              const SizedBox(height: 10),
              for (final doc in vehicle.documents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      title: Text(doc.type),
                      subtitle: Text('${doc.fileName} · ${doc.uploadedAt.toLocal()}'.split('.').first),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textFaint),
                      onTap: () => context.push(
                        RoutePaths.documentViewerPath(vehicleId, vehicle.documents.indexOf(doc)),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: OutlinedButton(onPressed: null, child: Text('Share')),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: () async {
                        await ref.read(deleteVehicleProvider)(vehicleId);
                        if (context.mounted) context.go(RoutePaths.vehicles);
                      },
                      child: const Text('Delete Vehicle'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
