import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AdminLayout extends ConsumerWidget {
  final Widget child;
  final String title;

  const AdminLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final admin = authState.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (admin != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                avatar: const Icon(Icons.person, size: 18, color: Colors.white),
                label: Text(admin.fullName.isNotEmpty ? admin.fullName : 'Admin',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: AppColors.primaryDark,
                side: BorderSide.none,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      drawer: _AdminDrawer(currentRoute: GoRouterState.of(context).uri.path),
      body: child,
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const _AdminDrawer({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 48),
                const SizedBox(height: 8),
                Text('HushRyd Admin',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white)),
              ],
            ),
          ),
          _tile(context, Icons.dashboard, 'Dashboard', '/dashboard'),
          _tile(context, Icons.people, 'Users', '/users'),
          _tile(context, Icons.admin_panel_settings, 'Admins', '/admins'),
          _tile(context, Icons.directions_car, 'Rides', '/rides'),
          _tile(context, Icons.book_online, 'Bookings', '/bookings'),
          const Divider(),
          _tile(context, Icons.receipt_long, 'Transactions', '/transactions'),
          _tile(context, Icons.payments, 'Payouts', '/payouts'),
          _tile(context, Icons.analytics, 'Analytics', '/analytics'),
          _tile(context, Icons.account_balance, 'Finance', '/finance'),
          const Divider(),
          _tile(context, Icons.verified_user, 'Verifications', '/verifications'),
          _tile(context, Icons.report_problem, 'Complaints', '/complaints'),
          _tile(context, Icons.support_agent, 'Support', '/support'),
          _tile(context, Icons.confirmation_number, 'Tickets', '/tickets'),
          _tile(context, Icons.sos, 'SOS', '/sos'),
          const Divider(),
          _tile(context, Icons.local_offer, 'Offers', '/offers'),
          _tile(context, Icons.attach_money, 'Fares', '/fares'),
          _tile(context, Icons.security, 'Permissions', '/permissions'),
          _tile(context, Icons.settings, 'Settings', '/settings'),
          _tile(context, Icons.history, 'Sessions', '/sessions'),
          _tile(context, Icons.storage, 'Database', '/database'),
        ],
      ),
    );
  }

  Widget _tile(
      BuildContext context, IconData icon, String label, String route) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary),
      title: Text(label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          )),
      selected: isSelected,
      selectedTileColor: AppColors.primaryLight.withAlpha(50),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
