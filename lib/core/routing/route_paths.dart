class RoutePaths {
  RoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const dashboard = '/dashboard';
  static const vehicles = '/vehicles';
  static const profile = '/profile';

  static const vehicleDetail = '/vehicles/:vehicleId';
  static String vehicleDetailPath(String vehicleId) => '/vehicles/$vehicleId';

  static const documentViewer = '/vehicles/:vehicleId/documents/:documentIndex';
  static String documentViewerPath(String vehicleId, int documentIndex) =>
      '/vehicles/$vehicleId/documents/$documentIndex';

  static const addVehicleCapture = '/add-vehicle';
  static const addVehicleDetails = '/add-vehicle/details';
  static const addVehicleReview = '/add-vehicle/review';
}
