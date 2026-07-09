import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/backup_settings_entity.dart';
import '../providers/backup_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(backupControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error is Failure ? error.message : 'Something went wrong.')),
        ),
      );
    });

    final controller = ref.watch(backupControllerProvider.notifier);
    final isBusy = ref.watch(backupControllerProvider).isLoading;
    // Re-read fresh on every rebuild — cheap synchronous AppPreferences
    // reads under the hood, and `backupControllerProvider`'s state change
    // after every action is exactly what triggers this rebuild.
    final settings = controller.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionCard(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Back up to Google Drive', style: AppTextStyles.bodyPrimary),
                subtitle: const Text(
                  'Daily backup of your vehicles and documents',
                  style: AppTextStyles.bodySecondary,
                ),
                value: settings.enabled,
                activeThumbColor: AppColors.primary,
                onChanged: isBusy ? null : (value) => controller.toggleEnabled(value),
              ),
              const Divider(height: 24, color: AppColors.divider),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Google account', style: AppTextStyles.bodyPrimary),
                subtitle: Text(
                  settings.isDriveConnected ? settings.connectedDriveAccountEmail! : 'Not connected',
                  style: AppTextStyles.bodySecondary,
                ),
                trailing: TextButton(
                  onPressed: isBusy
                      ? null
                      : () => settings.isDriveConnected ? controller.disconnectDrive() : controller.connectDrive(),
                  child: Text(settings.isDriveConnected ? 'Disconnect' : 'Connect'),
                ),
              ),
              if (!settings.isDriveConnected)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    "Signing out of CarVault may also disconnect Drive if you didn't sign in with Google — "
                    "you'll be asked to reconnect.",
                    style: TextStyle(fontSize: 11.5, color: AppColors.textFaint),
                  ),
                ),
              const Divider(height: 24, color: AppColors.divider),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Backup time', style: AppTextStyles.bodyPrimary),
                subtitle: Text(
                  TimeOfDay(hour: settings.hour, minute: settings.minute).format(context),
                  style: AppTextStyles.bodySecondary,
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textFaint),
                onTap: isBusy ? null : () => _pickTime(context, controller, settings),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Last backup', style: AppTextStyles.bodyPrimary),
                subtitle: Text(_lastBackupLabel(context, settings), style: AppTextStyles.bodySecondary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isBusy ? null : () => controller.backupNow(),
                  child: isBusy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Back up now'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: isBusy ? null : () => _confirmRestore(context, controller),
                  child: const Text('Restore latest backup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, BackupController controller, BackupSettingsEntity settings) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
    );
    if (picked != null) await controller.setTime(picked);
  }

  String _lastBackupLabel(BuildContext context, BackupSettingsEntity settings) {
    final at = settings.lastBackupAt;
    if (at == null) return 'Never backed up yet';
    final date = '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')}';
    final time = TimeOfDay.fromDateTime(at).format(context);
    final status = settings.lastBackupSucceeded == false ? ' — last attempt failed' : '';
    return '$date at $time$status';
  }

  Future<void> _confirmRestore(BuildContext context, BackupController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore latest backup?'),
        content: const Text(
          "This replaces every vehicle and document currently on this device with what's in your Google Drive "
          'backup. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.restoreNow();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
