import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/errors/result.dart';
import '../../../../../core/routing/route_paths.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/vehicle_entity.dart';
import '../../../domain/usecases/vehicle_usecases.dart';
import '../providers/add_vehicle_draft_provider.dart';

class AddVehicleReviewScreen extends ConsumerStatefulWidget {
  const AddVehicleReviewScreen({super.key});

  @override
  ConsumerState<AddVehicleReviewScreen> createState() => _AddVehicleReviewScreenState();
}

class _AddVehicleReviewScreenState extends ConsumerState<AddVehicleReviewScreen> {
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final draft = ref.read(addVehicleDraftProvider);

    final vehicleResult = await ref.read(addVehicleProvider)(draft);
    await vehicleResult.when(
      success: (vehicle) async {
        if (draft.photoPath != null) {
          await ref.read(addDocumentProvider)(
            vehicleId: vehicle.id,
            documentType: 'Registration Certificate',
            sourceImagePath: draft.photoPath!,
          );
        }
        if (!mounted) return;
        ref.read(addVehicleDraftProvider.notifier).reset();
        context.go(RoutePaths.vehicleDetailPath(vehicle.id));
      },
      failure: (f) async {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message)));
      },
    );

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(addVehicleDraftProvider);

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop()), title: const Text('Add Vehicle · Step 3 of 3')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Review before saving', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.outlineFaint),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _row('Reg. number', draft.regNumber, mono: true),
                _row('Make & model', '${draft.make} ${draft.model}'),
                _row('Year', draft.year),
                _row('Category', draft.category == VehicleCategory.buy ? 'Buy' : 'Sell'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(onPressed: () => context.pop(), child: const Text('Edit details')),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
                : const Text('Save Vehicle'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          Text(value, style: mono ? AppTextStyles.mono : AppTextStyles.bodyPrimary),
        ],
      ),
    );
  }
}
