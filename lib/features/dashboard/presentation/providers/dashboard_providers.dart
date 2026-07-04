import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/watch_dashboard_summary.dart';

final dashboardSummaryProvider = StreamProvider<DashboardSummary>((ref) {
  return ref.watch(watchDashboardSummaryProvider)();
});
