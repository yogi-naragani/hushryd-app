import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _sosActivated = false;

  final _emergencyServices = [
    {'name': 'Police', 'number': '100', 'icon': Icons.local_police, 'color': Colors.blue},
    {'name': 'Ambulance', 'number': '108', 'icon': Icons.local_hospital, 'color': Colors.red},
    {'name': 'Fire', 'number': '101', 'icon': Icons.local_fire_department, 'color': Colors.orange},
    {'name': 'Roadside', 'number': '1800-123-456', 'icon': Icons.car_repair, 'color': Colors.teal},
  ];

  final _emergencyContacts = [
    {'name': 'Priya Kumar (Spouse)', 'phone': '+91 9876543211'},
    {'name': 'Suresh Kumar (Father)', 'phone': '+91 9876543212'},
  ];

  final _safetyTips = [
    'Share your ride details with a trusted person',
    'Keep your phone charged during the trip',
    'Always verify the driver and vehicle details',
    'Sit in the back seat when riding alone',
    'Trust your instincts - if something feels wrong, act',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SOS Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: AppColors.error.withValues(alpha: 0.05),
              child: Column(
                children: [
                  GestureDetector(
                    onLongPress: _activateSos,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, child) {
                        final scale = _sosActivated
                            ? 1.0 + _pulseController.value * 0.05
                            : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _sosActivated
                              ? AppColors.error
                              : AppColors.error.withValues(alpha: 0.9),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sos,
                                color: Colors.white, size: 48),
                            const SizedBox(height: 4),
                            Text(
                              _sosActivated ? 'ACTIVATED' : 'SOS',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _sosActivated
                        ? 'Help is on the way!'
                        : 'Long press to activate SOS',
                    style: TextStyle(
                        fontSize: 14,
                        color: _sosActivated
                            ? AppColors.error
                            : Colors.grey[600],
                        fontWeight:
                            _sosActivated ? FontWeight.w600 : FontWeight.normal),
                  ),
                  if (_sosActivated) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(() => _sosActivated = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Cancel SOS'),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emergency services grid
                  const Text('Emergency Services',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: _emergencyServices.map((service) {
                      return GestureDetector(
                        onTap: () => _callNumber(service['number'] as String),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (service['color'] as Color)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: (service['color'] as Color)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(service['icon'] as IconData,
                                  color: service['color'] as Color, size: 28),
                              const SizedBox(height: 8),
                              Text(service['name'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              Text(service['number'] as String,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: service['color'] as Color,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Location display
                  const Text('Your Location',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.my_location,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Banjara Hills, Road No. 12',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('Hyderabad, Telangana 500034',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600])),
                              const SizedBox(height: 2),
                              Text('Lat: 17.4260, Lng: 78.4480',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Emergency contacts
                  const Text('Emergency Contacts',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...List.generate(_emergencyContacts.length, (i) {
                    final contact = _emergencyContacts[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              (contact['name'] as String)[0],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(contact['name'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text(contact['phone'] as String,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _callNumber(contact['phone'] as String),
                            icon: const Icon(Icons.phone,
                                color: AppColors.success),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Safety tips
                  const Text('Safety Tips',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: _safetyTips
                          .map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.shield_outlined,
                                        size: 18,
                                        color: AppColors.primary),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(tip,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700])),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _activateSos() {
    setState(() => _sosActivated = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('SOS Activated! Alerting emergency contacts...'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
