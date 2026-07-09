import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set to `true` by [AuthController] right after a fresh sign-up (email
/// registration, or a Google login where Firebase reports `isNewUser`).
/// The dashboard reads and immediately resets this to show the one-time
/// "back up to Google Drive?" prompt — never on a returning login.
final justRegisteredProvider = StateProvider<bool>((ref) => false);
