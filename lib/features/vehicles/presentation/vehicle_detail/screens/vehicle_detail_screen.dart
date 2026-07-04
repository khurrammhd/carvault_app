import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/errors/result.dart';
import '../../../../../core/routing/route_paths.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/usecases/vehicle_usecases.dart';
import '../providers/vehicle_detail_providers.dart';

class VehicleDetailScreen extends ConsumerStatefulWidget {
  const VehicleDetailScreen({required this.vehicleId, super.key});
  final String vehicleId;

  @override
  ConsumerState<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  bool _isAddingDocument = false;

  Future<void> _addDocument(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file == null) return; // user cancelled — not an error

    setState(() => _isAddingDocument = true);
    final result = await ref.read(addDocumentProvider)(
      vehicleId: widget.vehicleId,
      documentType: 'Other',
      sourceImagePath: file.path,
    );
    if (!mounted) return;
    setState(() => _isAddingDocument = false);

    result.when(
      success: (_) {},
      failure: (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  void _showAddDocumentOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _addDocument(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _addDocument(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(widget.vehicleId));

    return Scaffold(
      appBar: AppBar(
        // Explicitly goes to Vehicle List (matches the design spec) rather
        // than relying on context.pop() — this screen can be reached
        // either by a genuine push (tapping a card) or by a full
        // navigation reset (landing here right after saving a new
        // vehicle), and pop() isn't reliable in the second case.
        leading: BackButton(onPressed: () => context.go(RoutePaths.vehicles)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(RoutePaths.vehicleEditPath(widget.vehicleId)),
          ),
        ],
      ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Documents · ${vehicle.documentCount}', style: AppTextStyles.sectionHeader),
                  TextButton.icon(
                    onPressed: _isAddingDocument ? null : _showAddDocumentOptions,
                    icon: _isAddingDocument
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add, size: 18),
                    label: const Text('Add Document'),
                  ),
                ],
              ),
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
                        RoutePaths.documentViewerPath(widget.vehicleId, vehicle.documents.indexOf(doc)),
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
                        await ref.read(deleteVehicleProvider)(widget.vehicleId);
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
