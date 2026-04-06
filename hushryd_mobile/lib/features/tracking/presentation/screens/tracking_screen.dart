import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String rideId;
  const TrackingScreen({super.key, required this.rideId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _markerAnimController;
  Timer? _animationTimer;

  // Route: Hyderabad to Vijayawada (simplified waypoints)
  final _routePoints = const [
    LatLng(17.3850, 78.4867), // Hyderabad
    LatLng(17.3400, 78.5500),
    LatLng(17.2500, 78.7200),
    LatLng(17.1500, 79.0000),
    LatLng(17.0000, 79.3500),
    LatLng(16.8500, 79.6000),
    LatLng(16.7200, 79.8500),
    LatLng(16.6000, 80.1000),
    LatLng(16.5100, 80.4000),
    LatLng(16.5060, 80.6480), // Vijayawada
  ];

  int _currentPointIndex = 3; // Vehicle is ~30% through the journey
  double _progressFraction = 0.3;
  final bool _showDriverCard = true;

  final _rideInfo = {
    'from': 'Hyderabad',
    'to': 'Vijayawada',
    'date': '06 Apr 2026',
    'departureTime': '06:00 AM',
    'eta': '10:30 AM',
    'distance': '275 km',
    'duration': '4h 30m',
    'price': 450,
    'status': 'In Transit',
    'driverName': 'Rajesh Kumar',
    'driverRating': 4.8,
    'driverPhone': '+91 9876543210',
    'vehicleName': 'Maruti Suzuki Ertiga',
    'vehiclePlate': 'TS 09 AB 1234',
  };

  final _timeline = [
    {'label': 'Departed', 'time': '06:00 AM', 'location': 'Hyderabad', 'done': true},
    {'label': 'Stop 1', 'time': '07:15 AM', 'location': 'Nalgonda', 'done': true},
    {'label': 'Current', 'time': '08:30 AM', 'location': 'Suryapet', 'done': true},
    {'label': 'Stop 2', 'time': '09:15 AM', 'location': 'Kodad', 'done': false},
    {'label': 'Arrival', 'time': '10:30 AM', 'location': 'Vijayawada', 'done': false},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulate vehicle movement
    _animationTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_currentPointIndex < _routePoints.length - 1 && mounted) {
        setState(() {
          _currentPointIndex++;
          _progressFraction =
              _currentPointIndex / (_routePoints.length - 1);
        });
        _mapController.move(
            _routePoints[_currentPointIndex], _mapController.camera.zoom);
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _markerAnimController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _vehiclePosition => _routePoints[_currentPointIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _vehiclePosition,
              initialZoom: 10,
              minZoom: 6,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hushryd.mobile',
              ),
              // Route polyline
              PolylineLayer(
                polylines: [
                  // Completed portion (green)
                  Polyline(
                    points: _routePoints.sublist(0, _currentPointIndex + 1),
                    strokeWidth: 5,
                    color: AppColors.secondary,
                  ),
                  // Remaining portion (dashed blue)
                  Polyline(
                    points: _routePoints.sublist(_currentPointIndex),
                    strokeWidth: 4,
                    color: AppColors.primary.withValues(alpha: 0.5),
                    pattern: const StrokePattern.dotted(),
                  ),
                ],
              ),
              // Markers
              MarkerLayer(
                markers: [
                  // Origin marker
                  Marker(
                    point: _routePoints.first,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6),
                        ],
                      ),
                      child: const Icon(Icons.circle,
                          color: Colors.white, size: 14),
                    ),
                  ),
                  // Destination marker
                  Marker(
                    point: _routePoints.last,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6),
                        ],
                      ),
                      child: const Icon(Icons.location_on,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  // Animated vehicle marker
                  Marker(
                    point: _vehiclePosition,
                    width: 50,
                    height: 50,
                    child: AnimatedBuilder(
                      animation: _markerAnimController,
                      builder: (_, child) {
                        final pulseScale =
                            1.0 + sin(_markerAnimController.value * 2 * pi) * 0.1;
                        return Transform.scale(
                          scale: pulseScale,
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.directions_car,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('Live',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_rideInfo['from']} \u2192 ${_rideInfo['to']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppColors.error,
                    child: IconButton(
                      icon: const Icon(Icons.sos,
                          color: Colors.white, size: 20),
                      onPressed: () => context.push('/sos'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.15,
            maxChildSize: 0.85,
            builder: (_, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, -5)),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Progress bar
                    _buildProgressBar(),
                    const SizedBox(height: 20),

                    // Timeline
                    const Text('Journey Timeline',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildTimeline(),
                    const SizedBox(height: 20),

                    // Driver info card
                    if (_showDriverCard) _buildDriverCard(),
                    const SizedBox(height: 16),

                    // Ride details
                    _buildRideDetails(),
                    const SizedBox(height: 16),

                    // Emergency section
                    _buildEmergencySection(),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_progressFraction * 100).round();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_rideInfo['from'] as String,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text('ETA: ${_rideInfo['eta']}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary)),
            Text(_rideInfo['to'] as String,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: _progressFraction,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('$progress% completed',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_timeline.length, (i) {
        final item = _timeline[i];
        final isDone = item['done'] as bool;
        final isCurrent = item['label'] == 'Current';
        final isLast = i == _timeline.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary
                        : isDone
                            ? AppColors.success
                            : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCurrent
                        ? Icons.directions_car
                        : isDone
                            ? Icons.check
                            : Icons.circle,
                    color: Colors.white,
                    size: isCurrent ? 14 : 12,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: isDone
                        ? AppColors.success
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['label'] as String,
                            style: TextStyle(
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                                color: isCurrent
                                    ? AppColors.primary
                                    : null)),
                        Text(item['location'] as String,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    Text(item['time'] as String,
                        style: TextStyle(
                            fontSize: 13,
                            color: isCurrent
                                ? AppColors.primary
                                : Colors.grey[600],
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDriverCard() {
    return Container(
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
          const Text('Driver',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Text('RK',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ),
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
                          color: AppColors.primary, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_rideInfo['driverName'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${_rideInfo['driverRating']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(width: 8),
                        Text(_rideInfo['vehiclePlate'] as String,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final uri = Uri(
                      scheme: 'tel',
                      path: _rideInfo['driverPhone'] as String);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone,
                      color: AppColors.success, size: 20),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline,
                      color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.directions_car, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(_rideInfo['vehicleName'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ride Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _detailItem(Icons.calendar_today, 'Date',
                  _rideInfo['date'] as String),
              _detailItem(Icons.access_time, 'Departure',
                  _rideInfo['departureTime'] as String),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _detailItem(Icons.route, 'Distance',
                  _rideInfo['distance'] as String),
              _detailItem(Icons.timer, 'Duration',
                  _rideInfo['duration'] as String),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _detailItem(Icons.currency_rupee, 'Fare',
                  '\u20B9${_rideInfo['price']}'),
              _detailItem(Icons.schedule, 'ETA',
                  _rideInfo['eta'] as String),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emergency, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text('Emergency',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/sos'),
                  icon: const Icon(Icons.sos, size: 18),
                  label: const Text('SOS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri(scheme: 'tel', path: '100');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  icon: const Icon(Icons.local_police, size: 18),
                  label: const Text('Police'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
