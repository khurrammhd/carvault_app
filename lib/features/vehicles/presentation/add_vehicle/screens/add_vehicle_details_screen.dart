import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/buttons/category_segmented_control.dart';
import '../../../../../core/widgets/inputs/app_text_form_field.dart';
import '../providers/add_vehicle_draft_provider.dart';

class AddVehicleDetailsScreen extends ConsumerStatefulWidget {
  const AddVehicleDetailsScreen({super.key});

  @override
  ConsumerState<AddVehicleDetailsScreen> createState() => _AddVehicleDetailsScreenState();
}

class _AddVehicleDetailsScreenState extends ConsumerState<AddVehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _regNumberController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _notesController;
  final _makeFocus = FocusNode();
  final _modelFocus = FocusNode();
  final _yearFocus = FocusNode();
  final _notesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(addVehicleDraftProvider);
    _regNumberController = TextEditingController(text: draft.regNumber);
    _makeController = TextEditingController(text: draft.make);
    _modelController = TextEditingController(text: draft.model);
    _yearController = TextEditingController(text: draft.year);
    _notesController = TextEditingController(text: draft.notes ?? '');
  }

  @override
  void dispose() {
    _regNumberController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _notesController.dispose();
    _makeFocus.dispose();
    _modelFocus.dispose();
    _yearFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.push('/add-vehicle/review');
  }

  @override
  Widget build(BuildContext context) {
    final draftNotifier = ref.read(addVehicleDraftProvider.notifier);
    final canContinue = ref.watch(addVehicleDraftProvider.select((d) => d.canContinue));

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop()), title: const Text('Add Vehicle · Step 2 of 3')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextFormField(
              label: 'Registration number',
              isRequired: true,
              controller: _regNumberController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              hintText: 'e.g. MH12 AB 1234',
              style: AppTextStyles.mono,
              onChanged: draftNotifier.setRegNumber,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_makeFocus),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Registration number is required.' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppTextFormField(
                    label: 'Make',
                    controller: _makeController,
                    focusNode: _makeFocus,
                    textInputAction: TextInputAction.next,
                    hintText: 'Honda',
                    onChanged: draftNotifier.setMake,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_modelFocus),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextFormField(
                    label: 'Model',
                    controller: _modelController,
                    focusNode: _modelFocus,
                    textInputAction: TextInputAction.next,
                    hintText: 'City',
                    onChanged: draftNotifier.setModel,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_yearFocus),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              label: 'Year',
              controller: _yearController,
              focusNode: _yearFocus,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
              textInputAction: TextInputAction.next,
              hintText: '2021',
              onChanged: draftNotifier.setYear,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_notesFocus),
            ),
            const SizedBox(height: 14),
            const Text('Category', style: AppTextStyles.label),
            const SizedBox(height: 6),
            Consumer(
              builder: (context, ref, _) {
                final category = ref.watch(addVehicleDraftProvider.select((d) => d.category));
                return CategorySegmentedControl(selected: category, onChanged: draftNotifier.setCategory);
              },
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              label: 'Notes (optional)',
              controller: _notesController,
              focusNode: _notesFocus,
              textInputAction: TextInputAction.done,
              maxLines: 3,
              hintText: 'Anything worth remembering about this vehicle',
              onChanged: draftNotifier.setNotes,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: canContinue ? _submit : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: canContinue ? AppColors.primary : AppColors.disabledFill,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
