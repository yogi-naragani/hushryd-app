import 'package:flutter/material.dart';
import 'admin_layout.dart';
import '../../core/constants/colors.dart';

/// Placeholder screen for admin sections that follow the same pattern.
/// Can be quickly replaced with full implementations.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.description = 'This section is ready for data integration.',
  });

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: title,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
