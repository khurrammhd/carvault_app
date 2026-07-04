import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../vehicles/presentation/vehicle_detail/providers/vehicle_detail_providers.dart';

class DocumentViewerScreen extends ConsumerWidget {
  const DocumentViewerScreen({required this.vehicleId, required this.initialDocumentIndex, super.key});

  final String vehicleId;
  final int initialDocumentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(vehicleId));

    return Scaffold(
      backgroundColor: AppColors.viewerBackground,
      body: vehicleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white))),
        data: (vehicle) {
          if (vehicle == null || vehicle.documents.isEmpty) {
            return const Center(child: Text('No document', style: TextStyle(color: Colors.white)));
          }
          final index = initialDocumentIndex.clamp(0, vehicle.documents.length - 1);
          final doc = vehicle.documents[index];

          return Column(
            children: [
              SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => context.pop()),
                    Expanded(child: Text(doc.type, style: const TextStyle(color: Colors.white))),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(doc.filePath),
                        errorBuilder: (context, error, stack) =>
                            const Text('Could not load image', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.viewerSheet,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metaRow('Document type', doc.type),
                    _metaRow('Uploaded', doc.uploadedAt.toLocal().toString().split('.').first),
                    _metaRow('Vehicle', vehicle.regNumber),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFFA69F99))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
