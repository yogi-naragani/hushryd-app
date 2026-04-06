import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/users/presentation/users_list_screen.dart';
import '../../features/admins/presentation/admins_list_screen.dart';
import '../../features/rides/presentation/rides_list_screen.dart';
import '../../features/rides/presentation/ride_tracking_screen.dart';
import '../../features/bookings/presentation/bookings_list_screen.dart';
import '../../features/offers/presentation/offers_list_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginPage = state.uri.path == '/login';

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/dashboard',
          builder: (_, __) => const DashboardScreen()),
      GoRoute(
          path: '/users', builder: (_, __) => const UsersListScreen()),
      GoRoute(
          path: '/admins',
          builder: (_, __) => const AdminsListScreen()),
      GoRoute(
          path: '/rides', builder: (_, __) => const RidesListScreen()),
      GoRoute(
        path: '/rides/:id/track',
        builder: (_, state) => RideTrackingScreen(
          rideId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
          path: '/bookings',
          builder: (_, __) => const BookingsListScreen()),
      GoRoute(
          path: '/offers',
          builder: (_, __) => const OffersListScreen()),

      // Placeholder screens for remaining sections
      GoRoute(
          path: '/transactions',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Transactions', icon: Icons.receipt_long)),
      GoRoute(
          path: '/payouts',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Payouts', icon: Icons.payments)),
      GoRoute(
          path: '/analytics',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Analytics', icon: Icons.analytics)),
      GoRoute(
          path: '/finance',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Finance', icon: Icons.account_balance)),
      GoRoute(
          path: '/verifications',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Verifications', icon: Icons.verified_user)),
      GoRoute(
          path: '/complaints',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Complaints', icon: Icons.report_problem)),
      GoRoute(
          path: '/support',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Support', icon: Icons.support_agent)),
      GoRoute(
          path: '/tickets',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Tickets', icon: Icons.confirmation_number)),
      GoRoute(
          path: '/sos',
          builder: (_, __) => const PlaceholderScreen(
              title: 'SOS', icon: Icons.sos)),
      GoRoute(
          path: '/fares',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Fares', icon: Icons.attach_money)),
      GoRoute(
          path: '/permissions',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Permissions', icon: Icons.security)),
      GoRoute(
          path: '/settings',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Settings', icon: Icons.settings)),
      GoRoute(
          path: '/sessions',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Sessions', icon: Icons.history)),
      GoRoute(
          path: '/database',
          builder: (_, __) => const PlaceholderScreen(
              title: 'Database', icon: Icons.storage)),
    ],
  );
});
