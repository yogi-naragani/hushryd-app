import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constants/colors.dart';
import 'providers/users_provider.dart';

class UsersListScreen extends ConsumerWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return AdminLayout(
      title: 'Users',
      child: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const EmptyStateWidget(
                message: 'No users found', icon: Icons.people_outline);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(usersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        '${(user['firstName'] ?? 'U')[0]}'.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                            .trim()),
                    subtitle: Text(user['email'] ?? 'No email'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(
                            status: user['isActive'] == true
                                ? 'active'
                                : 'inactive'),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(user['role'] ?? 'user',
                              style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading users...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(usersProvider),
        ),
      ),
    );
  }
}
