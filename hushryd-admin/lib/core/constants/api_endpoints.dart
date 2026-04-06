class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String adminLogin = '/auth/admin/login';
  static const String adminCreate = '/auth/admin/create';
  static const String verify = '/auth/verify';
  static const String changePassword = '/auth/change-password';
  static const String logout = '/auth/logout';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String profile = '/auth/profile';

  // Users
  static const String users = '/users';
  static const String userMe = '/users/me';
  static const String userStats = '/users/stats/overview';
  static String userId(String id) => '/users/$id';

  // Admins
  static const String admins = '/admins';
  static const String adminStats = '/admins/stats/overview';
  static String adminId(String id) => '/admins/$id';

  // Rides
  static const String rides = '/rides';
  static const String rideStats = '/rides/stats/overview';
  static String rideId(String id) => '/rides/$id';

  // Bookings
  static const String bookings = '/bookings';
  static const String bookingStats = '/bookings/stats/overview';
  static String bookingId(String id) => '/bookings/$id';
  static String bookingCancel(String id) => '/bookings/$id/cancel';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardAnalytics = '/dashboard/analytics';
  static const String recentActivity = '/dashboard/recent-activity';

  // Offers
  static const String offers = '/offers';
  static const String offersActive = '/offers/active';
  static const String offersVerify = '/offers/verify';
  static String offerId(String id) => '/offers/$id';

  // SMS Gateway
  static const String smsSettings = '/sms-gateway/settings';
  static const String smsBalance = '/sms-gateway/balance';
  static const String smsUsage = '/sms-gateway/usage';
  static const String smsTest = '/sms-gateway/test';

  // Database
  static const String dbSeed = '/database/seed';
  static const String dbClear = '/database/clear';
  static const String dbStats = '/database/stats';
  static const String dbMigrate = '/database/migrate';
}
