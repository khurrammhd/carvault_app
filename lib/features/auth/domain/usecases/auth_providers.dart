import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import 'login_with_email.dart';
import 'login_with_google.dart';
import 'logout.dart';
import 'register_with_email.dart';
import 'send_password_reset_email.dart';

final loginWithEmailProvider = Provider((ref) => LoginWithEmail(ref.watch(authRepositoryProvider)));
final registerWithEmailProvider = Provider((ref) => RegisterWithEmail(ref.watch(authRepositoryProvider)));
final loginWithGoogleProvider = Provider((ref) => LoginWithGoogle(ref.watch(authRepositoryProvider)));
final sendPasswordResetEmailProvider = Provider((ref) => SendPasswordResetEmail(ref.watch(authRepositoryProvider)));
final logoutProvider = Provider((ref) => Logout(ref.watch(authRepositoryProvider)));
