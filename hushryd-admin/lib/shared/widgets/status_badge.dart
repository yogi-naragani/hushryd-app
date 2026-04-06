import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'paid':
      case 'success':
        return AppColors.statusActive;
      case 'pending':
      case 'scheduled':
        return AppColors.statusPending;
      case 'cancelled':
      case 'failed':
      case 'inactive':
      case 'banned':
        return AppColors.statusCancelled;
      case 'in_progress':
      case 'confirmed':
        return AppColors.statusInProgress;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withAlpha(100)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: _color,
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
