import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/status_badge.dart';

class RideTrackingScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideTrackingScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideTrackingScreen> createState() =>
      _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _pollTimer;

  // Default coordinates (Mumbai)
  static const _defaultCenter = LatLng(19.0760, 72.8777);
  LatLng _currentPosition = _defaultCenter;

  // Sample route points (Mumbai to Pune)
  final _routePoints = const [
    LatLng(19.0760, 72.8777),
    LatLng(19.0330, 73.0297),
    LatLng(18.8500, 73.2800),
    LatLng(18.6500, 73.5000),
    LatLng(18.5204, 73.8567),
  ];

  final String _rideStatus = 'in_progress';

  @override
  void initState() {
    super.initState();
    // Poll for location updates every 10 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _simulateMovement();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _simulateMovement() {
    // In production, this would call the API for real-time location
    setState(() {
      _currentPosition = LatLng(
        _currentPosition.latitude - 0.005,
        _currentPosition.longitude + 0.01,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride #${widget.rideId.substring(0, 8)}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 9,
            ),
            children: [
              // OSM Tile Layer
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hushryd.admin',
              ),

              // Route polyline
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ],
              ),

              // Markers
              MarkerLayer(
                markers: [
                  // Start marker
                  Marker(
                    point: _routePoints.first,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.trip_origin,
                        color: AppColors.success, size: 30),
                  ),
                  // End marker
                  Marker(
                    point: _routePoints.last,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on,
                        color: AppColors.error, size: 36),
                  ),
                  // Current position (vehicle)
                  Marker(
                    point: _currentPosition,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(100),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.directions_car,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Info panel at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, -2)),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ride info
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mumbai Central',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Icon(Icons.arrow_downward,
                                size: 16, color: AppColors.textSecondary),
                            Text('Pune Station',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      StatusBadge(status: _rideStatus),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Journey Progress',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                          Text('45%',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.45,
                        backgroundColor: AppColors.divider,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Driver info and actions
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jane Smith',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('MH01AB1234',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: AppColors.success),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.sos, color: AppColors.error),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Center on vehicle button
          Positioned(
            right: 16,
            bottom: 280,
            child: FloatingActionButton.small(
              onPressed: () {
                _mapController.move(_currentPosition, 12);
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
