import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.divider),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}
