class ApiEndpoints {
  static const baseUrl = 'http://10.0.2.2:3000/api';

  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const adminLogin = '/auth/admin/login';
  static const sendOtp = '/auth/send-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const verifyToken = '/auth/verify';
  static const logout = '/auth/logout';
  static const changePassword = '/auth/change-password';

  // Users
  static const users = '/users';
  static const userMe = '/users/me';
  static const userStats = '/users/stats/overview';

  // Rides
  static const rides = '/rides';
  static const rideStats = '/rides/stats/overview';
  static const userRides = '/rides/user';

  // Bookings
  static const bookings = '/bookings';
  static const bookingStats = '/bookings/stats/overview';

  // Offers
  static const offers = '/offers';
  static const activeOffers = '/offers/active';
  static const verifyOffer = '/offers/verify';

  // Dashboard
  static const dashboardStats = '/dashboard/stats';

  // Safety
  static const sos = '/safety/sos';
  static const emergencyContacts = '/safety/emergency-contacts';

  // Payment
  static const paymentMethods = '/payment/methods';
  static const transactions = '/payment/transactions';

  // Notifications
  static const notifications = '/notifications';

  // Referral
  static const referral = '/referral';

  // Complaints
  static const complaints = '/complaints';

  // Sessions
  static const sessions = '/sessions';
}
