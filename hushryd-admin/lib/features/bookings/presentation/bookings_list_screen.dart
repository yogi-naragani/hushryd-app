import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constants/colors.dart';
import 'providers/bookings_provider.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return AdminLayout(
      title: 'Bookings',
      child: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const EmptyStateWidget(
                message: 'No bookings found', icon: Icons.book_online_outlined);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.book_online, color: AppColors.primary),
                  ),
                  title: Text(b['passengerName'] ?? 'N/A'),
                  subtitle: Text(
                      '${b['from'] ?? 'N/A'} -> ${b['to'] ?? 'N/A'}\nAmount: ${b['totalAmount'] ?? 0}'),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusBadge(status: b['status'] ?? 'pending'),
                      const SizedBox(height: 4),
                      StatusBadge(status: b['paymentStatus'] ?? 'pending', fontSize: 9),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading bookings...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(bookingsProvider),
        ),
      ),
    );
  }
}
