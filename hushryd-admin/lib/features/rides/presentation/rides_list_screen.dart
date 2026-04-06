import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constants/colors.dart';
import 'providers/rides_provider.dart';

class RidesListScreen extends ConsumerWidget {
  const RidesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(ridesProvider);

    return AdminLayout(
      title: 'Rides',
      child: ridesAsync.when(
        data: (rides) {
          if (rides.isEmpty) {
            return const EmptyStateWidget(
                message: 'No rides found', icon: Icons.directions_car_outlined);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.directions_car, color: AppColors.primary),
                  ),
                  title: Text(
                      '${ride['fromLocation'] ?? 'N/A'} -> ${ride['toLocation'] ?? 'N/A'}',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                      '${ride['pickupDate'] ?? ''} | Fare: ${ride['fare'] ?? 0}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(status: ride['status'] ?? 'pending'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.map, color: AppColors.secondary),
                        tooltip: 'Track on Map',
                        onPressed: () =>
                            context.go('/rides/${ride['id']}/track'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading rides...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(ridesProvider),
        ),
      ),
    );
  }
}
