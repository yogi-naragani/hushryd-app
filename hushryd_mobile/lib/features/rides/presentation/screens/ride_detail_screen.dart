import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';

class RideDetailScreen extends ConsumerStatefulWidget {
  final String rideId;
  const RideDetailScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends ConsumerState<RideDetailScreen> {
  int _seats = 1;

  // Mock ride data
  Map<String, dynamic> get _ride => {
        'from': 'Hyderabad',
        'to': 'Vijayawada',
        'date': '06 Apr 2026',
        'time': '06:00 AM',
        'price': 450,
        'distance': '275 km',
        'duration': '4h 30m',
        'availableSeats': 3,
        'driverName': 'Rajesh Kumar',
        'driverRating': 4.8,
        'driverTrips': 234,
        'driverVerified': true,
        'vehicleName': 'Maruti Suzuki Ertiga',
        'vehicleColor': 'White',
        'vehiclePlate': 'TS 09 AB 1234',
        'vehicleType': 'SUV',
        'preferences': ['No Smoking', 'Music Allowed', 'Pets Allowed', 'AC'],
      };

  @override
  Widget build(BuildContext context) {
    final ride = _ride;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(
              icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: Icon(Icons.arrow_back, size: 20)),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradient),
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride['from'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(Icons.arrow_forward,
                                      color: Colors.white70, size: 18),
                                  SizedBox(width: 4),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(ride['to'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('\u20B9${ride['price']}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary)),
                              const Text('per seat',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Details grid
                  Row(
                    children: [
                      _detailTile(Icons.calendar_today, 'Date', ride['date']),
                      _detailTile(Icons.access_time, 'Time', ride['time']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _detailTile(Icons.route, 'Distance', ride['distance']),
                      _detailTile(Icons.timer, 'Duration', ride['duration']),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Driver card
                  const Text('Driver',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                ride['driverName']
                                    .toString()
                                    .split(' ')
                                    .map((e) => e[0])
                                    .join(),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              ),
                            ),
                            if (ride['driverVerified'])
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.verified,
                                      color: AppColors.primary, size: 18),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride['driverName'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${ride['driverRating']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text('  \u2022  ${ride['driverTrips']} trips',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline,
                              color: AppColors.primary),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_outlined,
                              color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vehicle info
                  const Text('Vehicle',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_car,
                              size: 30, color: Colors.grey),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride['vehicleName'],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                  '${ride['vehicleColor']}  \u2022  ${ride['vehicleType']}',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(ride['vehiclePlate'],
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ride preferences
                  const Text('Ride Preferences',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (ride['preferences'] as List<String>).map((p) {
                      IconData icon;
                      switch (p) {
                        case 'No Smoking':
                          icon = Icons.smoke_free;
                        case 'Music Allowed':
                          icon = Icons.music_note;
                        case 'Pets Allowed':
                          icon = Icons.pets;
                        case 'AC':
                          icon = Icons.ac_unit;
                        default:
                          icon = Icons.check;
                      }
                      return Chip(
                        avatar: Icon(icon, size: 18, color: AppColors.primary),
                        label: Text(p, style: const TextStyle(fontSize: 13)),
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.06),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Seat selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: _seats > 1
                          ? () => setState(() => _seats--)
                          : null,
                    ),
                    Text('$_seats',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: _seats < ride['availableSeats']
                          ? () => setState(() => _seats++)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/booking?rideId=${widget.rideId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Book Now  \u2022  \u20B9${ride['price'] * _seats}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
