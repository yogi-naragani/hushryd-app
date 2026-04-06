import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constants/colors.dart';
import 'providers/offers_provider.dart';

class OffersListScreen extends ConsumerWidget {
  const OffersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersProvider);

    return AdminLayout(
      title: 'Offers',
      child: offersAsync.when(
        data: (offers) {
          if (offers.isEmpty) {
            return const EmptyStateWidget(
                message: 'No offers found', icon: Icons.local_offer_outlined);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final o = offers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.warning.withAlpha(50),
                    child: const Icon(Icons.local_offer, color: AppColors.warning),
                  ),
                  title: Text(o['title'] ?? 'N/A'),
                  subtitle: Text(
                      'Code: ${o['code'] ?? 'N/A'} | ${o['discountType'] == 'percentage' ? '${o['discountValue']}%' : '${o['discountValue']}'}'),
                  trailing: StatusBadge(
                      status: o['isActive'] == true ? 'active' : 'inactive'),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading offers...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(offersProvider),
        ),
      ),
    );
  }
}
