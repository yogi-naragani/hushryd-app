import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class TimeslotCard extends StatelessWidget {
  final String from, to, time;
  final int fare, seats;
  final VoidCallback onTap;

  const TimeslotCard({super.key, required this.from, required this.to,
    required this.time, required this.fare, required this.seats, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Time
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(time, style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              // Route
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.trip_origin, size: 12, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(from, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Container(width: 1, height: 10, color: Colors.grey[300]),
                    ),
                    Row(children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(to, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ),
              ),
              // Price & seats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\u20B9$fare', style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Text('$seats seats', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
