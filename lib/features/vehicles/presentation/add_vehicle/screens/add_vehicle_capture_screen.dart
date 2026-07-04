import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/add_vehicle_draft_provider.dart';

class AddVehicleCaptureScreen extends ConsumerWidget {
  const AddVehicleCaptureScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file == null) return; // user cancelled — not an error
    ref.read(addVehicleDraftProvider.notifier).setPhotoPath(file.path);
    if (context.mounted) context.push('/add-vehicle/details');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Add Vehicle · Step 1 of 3'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 48),
              const SizedBox(height: 12),
              const Text('Capture the registration certificate', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _pickImage(context, ref, ImageSource.camera),
                  child: const Text('Take Photo'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _pickImage(context, ref, ImageSource.gallery),
                  child: const Text('Choose from Gallery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
