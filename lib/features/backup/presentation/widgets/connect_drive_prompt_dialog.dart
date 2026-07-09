import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/backup_controller.dart';

/// Shown exactly once, right after a fresh sign-up (see
/// `DashboardScreen`'s `justRegisteredProvider` check) — never a recurring
/// nag. Declining just dismisses; Drive can still be connected later from
/// Settings.
class ConnectDrivePromptDialog extends ConsumerWidget {
  const ConnectDrivePromptDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Back up to Google Drive?', style: AppTextStyles.sectionHeader),
      content: const Text(
        "We'll keep a daily backup of your vehicles and documents in your own Google Drive, so you never lose them.",
        style: AppTextStyles.bodySecondary,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not now'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () => _connectAndEnable(context, ref),
          child: const Text('Back up my documents'),
        ),
      ],
    );
  }

  Future<void> _connectAndEnable(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    final controller = ref.read(backupControllerProvider.notifier);
    await controller.connectDrive();
    // Only turn backup on if connecting actually succeeded — otherwise the
    // toggle would show "on" with nothing behind it until the user
    // reconnects from Settings.
    if (!ref.read(backupControllerProvider).hasError) {
      await controller.toggleEnabled(true);
    }
  }
}
