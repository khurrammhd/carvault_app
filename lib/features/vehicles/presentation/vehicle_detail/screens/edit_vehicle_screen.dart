import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/errors/result.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/buttons/category_segmented_control.dart';
import '../../../../../core/widgets/inputs/app_text_form_field.dart';
import '../../../domain/entities/add_vehicle_draft.dart';
import '../../../domain/entities/vehicle_entity.dart';
import '../../../domain/usecases/vehicle_usecases.dart';
import '../providers/vehicle_detail_providers.dart';

/// Editing an existing vehicle's details. Deliberately doesn't share
/// `addVehicleDraftProvider` with the Add Vehicle flow — that's global,
/// multi-step wizard state, and reusing it here would leak this screen's
/// edits into an in-progress add-vehicle flow (or vice versa). This screen
/// owns its own local form state instead.
class EditVehicleScreen extends ConsumerStatefulWidget {
  const EditVehicleScreen({required this.vehicleId, super.key});
  final String vehicleId;

  @override
  ConsumerState<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends ConsumerState<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _regNumberController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _notesController;
  VehicleCategory _category = VehicleCategory.buy;
  DateTime? _originalAddedAt;
  bool _isSaving = false;
  bool _initialized = false;

  void _initializeFrom(VehicleEntity vehicle) {
    if (_initialized) return;
    _initialized = true;
    _regNumberController = TextEditingController(text: vehicle.regNumber);
    _makeController = TextEditingController(text: vehicle.make);
    _modelController = TextEditingController(text: vehicle.model);
    _yearController = TextEditingController(text: vehicle.year);
    _notesController = TextEditingController(text: vehicle.notes ?? '');
    _category = vehicle.category;
    _originalAddedAt = vehicle.addedAt;
  }

  @override
  void dispose() {
    if (_initialized) {
      _regNumberController.dispose();
      _makeController.dispose();
      _modelController.dispose();
      _yearController.dispose();
      _notesController.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final draft = AddVehicleDraft(
      regNumber: _regNumberController.text,
      make: _makeController.text,
      model: _modelController.text,
      year: _yearController.text,
      category: _category,
      notes: _notesController.text,
    );

    final result = await ref.read(updateVehicleProvider)(
      vehicleId: widget.vehicleId,
      draft: draft,
      originalAddedAt: _originalAddedAt!,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      success: (_) => context.pop(),
      failure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(widget.vehicleId));

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop()), title: const Text('Edit Vehicle')),
      body: vehicleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load vehicle: $e')),
        data: (vehicle) {
          if (vehicle == null) return const Center(child: Text('Vehicle not found.'));
          _initializeFrom(vehicle);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppTextFormField(
                  label: 'Registration number',
                  isRequired: true,
                  controller: _regNumberController,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTextStyles.mono,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Registration number is required.' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: AppTextFormField(label: 'Make', controller: _makeController)),
                    const SizedBox(width: 12),
                    Expanded(child: AppTextFormField(label: 'Model', controller: _modelController)),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextFormField(
                  label: 'Year',
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                ),
                const SizedBox(height: 14),
                const Text('Category', style: AppTextStyles.label),
                const SizedBox(height: 6),
                CategorySegmentedControl(
                  selected: _category,
                  onChanged: (value) => setState(() => _category = value),
                ),
                const SizedBox(height: 14),
                AppTextFormField(label: 'Notes (optional)', controller: _notesController, maxLines: 3),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
