/// Plain, storage-agnostic view of the backup feature's current state —
/// assembled from [AppPreferences] by the data layer, read synchronously
/// by the Settings screen.
class BackupSettingsEntity {
  const BackupSettingsEntity({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.connectedDriveAccountEmail,
    required this.lastBackupAt,
    required this.lastBackupSucceeded,
  });

  final bool enabled;
  final int hour;
  final int minute;
  final String? connectedDriveAccountEmail;
  final DateTime? lastBackupAt;
  final bool? lastBackupSucceeded;

  bool get isDriveConnected => connectedDriveAccountEmail != null;
}
