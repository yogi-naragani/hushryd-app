import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constants/colors.dart';
import 'providers/admins_provider.dart';

class AdminsListScreen extends ConsumerWidget {
  const AdminsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(adminsProvider);

    return AdminLayout(
      title: 'Admins',
      child: adminsAsync.when(
        data: (admins) {
          if (admins.isEmpty) {
            return const EmptyStateWidget(
                message: 'No admins found',
                icon: Icons.admin_panel_settings_outlined);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: admins.length,
            itemBuilder: (context, index) {
              final a = admins[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                        '${(a['firstName'] ?? 'A')[0]}'.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(
                      '${a['firstName'] ?? ''} ${a['lastName'] ?? ''}'.trim()),
                  subtitle: Text(a['email'] ?? 'No email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(
                          status: a['isActive'] == true ? 'active' : 'inactive'),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(a['role'] ?? 'admin',
                            style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading admins...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(adminsProvider),
        ),
      ),
    );
  }
}
