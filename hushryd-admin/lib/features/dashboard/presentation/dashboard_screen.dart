import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/widgets/stats_card.dart';
import '../../../core/constants/colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../presentation/providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardAsync = ref.watch(dashboardStatsProvider);

    return AdminLayout(
      title: 'Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.waving_hand, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${authState.admin?.fullName ?? 'Admin'}!',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Role: ${authState.admin?.role ?? 'admin'}',
                            style: TextStyle(
                                color: Colors.white.withAlpha(200)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats grid
            dashboardAsync.when(
              data: (stats) {
                final overview = stats['overview'] as Map<String, dynamic>? ?? {};
                return _buildStatsGrid(overview);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildStatsGrid({}),
            ),

            const SizedBox(height: 24),
            Text('Quick Actions',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> overview) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        StatsCard(
          title: 'Total Users',
          value: '${overview['totalUsers'] ?? 0}',
          icon: Icons.people,
          color: AppColors.primary,
        ),
        StatsCard(
          title: 'Total Rides',
          value: '${overview['totalRides'] ?? 0}',
          icon: Icons.directions_car,
          color: AppColors.secondary,
        ),
        StatsCard(
          title: 'Total Bookings',
          value: '${overview['totalBookings'] ?? 0}',
          icon: Icons.book_online,
          color: AppColors.accent,
        ),
        StatsCard(
          title: 'Revenue',
          value: '${overview['totalRevenue'] ?? 0}',
          icon: Icons.currency_rupee,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(Icons.people, 'Users', '/users', AppColors.primary),
      _QuickAction(Icons.directions_car, 'Rides', '/rides', AppColors.secondary),
      _QuickAction(Icons.book_online, 'Bookings', '/bookings', AppColors.accent),
      _QuickAction(Icons.admin_panel_settings, 'Admins', '/admins', AppColors.info),
      _QuickAction(Icons.local_offer, 'Offers', '/offers', AppColors.warning),
      _QuickAction(Icons.analytics, 'Analytics', '/analytics', AppColors.success),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: actions.map((a) {
        return Card(
          child: InkWell(
            onTap: () => context.go(a.route),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a.icon, color: a.color, size: 32),
                const SizedBox(height: 8),
                Text(a.label,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  _QuickAction(this.icon, this.label, this.route, this.color);
}
