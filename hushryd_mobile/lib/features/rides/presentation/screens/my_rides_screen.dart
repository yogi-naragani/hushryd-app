import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';

class MyRidesScreen extends ConsumerStatefulWidget {
  const MyRidesScreen({super.key});

  @override
  ConsumerState<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends ConsumerState<MyRidesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _statusFilter = 'All';

  final _filters = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  final _publishedRides = [
    {
      'id': 'p1',
      'from': 'Hyderabad',
      'to': 'Vijayawada',
      'date': '08 Apr 2026',
      'time': '06:00 AM',
      'price': 450,
      'seats': 3,
      'booked': 1,
      'status': 'Upcoming',
    },
    {
      'id': 'p2',
      'from': 'Hyderabad',
      'to': 'Chennai',
      'date': '02 Apr 2026',
      'time': '08:30 AM',
      'price': 1200,
      'seats': 2,
      'booked': 2,
      'status': 'Completed',
    },
  ];

  final _bookings = [
    {
      'id': 'b1',
      'from': 'Hyderabad',
      'to': 'Bangalore',
      'date': '10 Apr 2026',
      'time': '10:00 AM',
      'price': 900,
      'driverName': 'Rajesh Kumar',
      'status': 'Upcoming',
      'bookingId': 'BK284710',
    },
    {
      'id': 'b2',
      'from': 'Vijayawada',
      'to': 'Visakhapatnam',
      'date': '01 Apr 2026',
      'time': '02:00 PM',
      'price': 600,
      'driverName': 'Suresh Reddy',
      'status': 'Completed',
      'bookingId': 'BK192384',
    },
    {
      'id': 'b3',
      'from': 'Hyderabad',
      'to': 'Warangal',
      'date': '28 Mar 2026',
      'time': '07:00 AM',
      'price': 350,
      'driverName': 'Priya Sharma',
      'status': 'Cancelled',
      'bookingId': 'BK093847',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rides'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Published'),
            Tab(text: 'Bookings'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status filter
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = _statusFilter == _filters[i];
                return ChoiceChip(
                  label: Text(_filters[i]),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.grey[700],
                      fontSize: 13),
                  onSelected: (_) =>
                      setState(() => _statusFilter = _filters[i]),
                );
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPublishedList(),
                _buildBookingsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterByStatus(List<Map<String, dynamic>> list) {
    if (_statusFilter == 'All') return list;
    return list.where((r) => r['status'] == _statusFilter).toList();
  }

  Widget _buildPublishedList() {
    final rides = _filterByStatus(_publishedRides);
    if (rides.isEmpty) return _emptyState('No published rides');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length,
      itemBuilder: (_, i) => _publishedRideCard(rides[i]),
    );
  }

  Widget _buildBookingsList() {
    final bookings = _filterByStatus(_bookings);
    if (bookings.isEmpty) return _emptyState('No bookings found');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _bookingCard(bookings[i]),
    );
  }

  Widget _publishedRideCard(Map<String, dynamic> ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(ride['from'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                    ),
                    Text(ride['to'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
              _statusBadge(ride['status'] as String),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('${ride['date']} \u2022 ${ride['time']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const Spacer(),
              Text('\u20B9${ride['price']}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary)),
              Text('/seat',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.event_seat, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('${ride['booked']}/${ride['seats']} seats booked',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (ride['status'] == 'Upcoming') ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${booking['from']} \u2192 ${booking['to']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Booking: ${booking['bookingId']}',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              _statusBadge(booking['status'] as String),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('${booking['date']} \u2022 ${booking['time']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const Spacer(),
              Text('\u20B9${booking['price']}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('Driver: ${booking['driverName']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (booking['status'] == 'Upcoming') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.push('/track/${booking['id']}'),
                    icon: const Icon(Icons.location_on, size: 16),
                    label: const Text('Track'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ] else if (booking['status'] == 'Completed') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.star, size: 16),
                    label: const Text('Rate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                        '/search?from=${booking['from']}&to=${booking['to']}&date=&passengers=1'),
                    icon: const Icon(Icons.replay, size: 16),
                    label: const Text('Rebook'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ] else if (booking['status'] == 'Cancelled') ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                        '/search?from=${booking['from']}&to=${booking['to']}&date=&passengers=1'),
                    icon: const Icon(Icons.replay, size: 16),
                    label: const Text('Rebook'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Upcoming':
        color = AppColors.primary;
      case 'Completed':
        color = AppColors.success;
      case 'Cancelled':
        color = AppColors.error;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
