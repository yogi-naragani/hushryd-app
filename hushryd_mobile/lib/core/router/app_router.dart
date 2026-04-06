import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/rides/presentation/screens/my_rides_screen.dart';
import '../../features/publish/presentation/screens/publish_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_results_screen.dart';
import '../../features/rides/presentation/screens/ride_detail_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../../features/vehicles/presentation/screens/vehicles_screen.dart';
import '../../features/vehicles/presentation/screens/add_vehicle_screen.dart';
import '../../features/sos/presentation/screens/sos_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/referral/presentation/screens/referral_screen.dart';
import '../../features/complaints/presentation/screens/complaints_screen.dart';
import '../../features/tracking/presentation/screens/tracking_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Main shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/my-rides', builder: (_, __) => const MyRidesScreen()),
          GoRoute(path: '/publish', builder: (_, __) => const PublishScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Detail routes
      GoRoute(path: '/search', builder: (_, state) => SearchResultsScreen(
        from: state.uri.queryParameters['from'] ?? '',
        to: state.uri.queryParameters['to'] ?? '',
        date: state.uri.queryParameters['date'] ?? '',
        passengers: int.tryParse(state.uri.queryParameters['passengers'] ?? '') ?? 1,
      )),
      GoRoute(path: '/ride/:id', builder: (_, state) =>
          RideDetailScreen(rideId: state.pathParameters['id']!)),
      GoRoute(path: '/booking', builder: (_, state) => BookingScreen(
        rideId: state.uri.queryParameters['rideId'] ?? '',
      )),
      GoRoute(path: '/track/:id', builder: (_, state) =>
          TrackingScreen(rideId: state.pathParameters['id']!)),
      GoRoute(path: '/payment', builder: (_, __) => const PaymentScreen()),
      GoRoute(path: '/vehicles', builder: (_, __) => const VehiclesScreen()),
      GoRoute(path: '/vehicles/add', builder: (_, __) => const AddVehicleScreen()),
      GoRoute(path: '/sos', builder: (_, __) => const SosScreen()),
      GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/referral', builder: (_, __) => const ReferralScreen()),
      GoRoute(path: '/complaints', builder: (_, __) => const ComplaintsScreen()),
    ],
  );
});
