import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _expandedFaq = <int>{};

  final _quickActions = [
    {'name': 'Phone', 'icon': Icons.phone, 'color': AppColors.success, 'action': 'tel:+911800123456'},
    {'name': 'Email', 'icon': Icons.email, 'color': AppColors.primary, 'action': 'mailto:support@hushryd.com'},
    {'name': 'Live Chat', 'icon': Icons.chat_bubble, 'color': AppColors.accent, 'action': 'chat'},
    {'name': 'Tickets', 'icon': Icons.confirmation_number, 'color': AppColors.secondary, 'action': 'tickets'},
  ];

  final _categories = [
    {'name': 'Booking Issues', 'icon': Icons.confirmation_number_outlined, 'count': 3},
    {'name': 'Payment Problems', 'icon': Icons.payment, 'count': 2},
    {'name': 'Account & Profile', 'icon': Icons.person_outline, 'count': 4},
    {'name': 'Driver Issues', 'icon': Icons.directions_car, 'count': 2},
    {'name': 'Technical Support', 'icon': Icons.build_outlined, 'count': 5},
  ];

  final _faqs = [
    {
      'q': 'How do I cancel a booking?',
      'a': 'Go to My Rides, find your booking, and tap the Cancel button. Cancellation charges may apply depending on the timing.',
    },
    {
      'q': 'How long does a refund take?',
      'a': 'Refunds are typically processed within 5-7 business days. The amount will be credited to your original payment method.',
    },
    {
      'q': 'How do I verify my account?',
      'a': 'Go to Profile > Settings > Verification. You will need to upload your ID proof and a selfie for verification.',
    },
    {
      'q': 'What if my driver does not show up?',
      'a': 'If your driver has not arrived within 15 minutes, you can cancel the ride for a full refund and rebook another ride.',
    },
    {
      'q': 'How do I change my payment method?',
      'a': 'Go to Profile > Payment Methods. You can add, remove, or set a default payment method from there.',
    },
    {
      'q': 'Is my ride insured?',
      'a': 'Yes, all rides booked through HushRyd are covered by our partner insurance for accidents and delays.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick actions
            const Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: _quickActions.map((action) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _handleAction(action['action'] as String),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(action['icon'] as IconData,
                              color: action['color'] as Color, size: 28),
                          const SizedBox(height: 8),
                          Text(action['name'] as String,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: action['color'] as Color)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Categories
            const Text('Support Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(_categories.length, (i) {
              final cat = _categories[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(cat['icon'] as IconData,
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text(cat['name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text('${cat['count']} articles',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500])),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {},
                ),
              );
            }),
            const SizedBox(height: 24),

            // FAQ
            const Text('Frequently Asked Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(_faqs.length, (i) {
              final faq = _faqs[i];
              final isExpanded = _expandedFaq.contains(i);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(faq['q'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.primary),
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedFaq.remove(i);
                          } else {
                            _expandedFaq.add(i);
                          }
                        });
                      },
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(faq['a'] as String,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
            // Contact card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent,
                      color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text('Still need help?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Our support team is available 24/7',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Contact Support',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(String action) async {
    if (action.startsWith('tel:') || action.startsWith('mailto:')) {
      final uri = Uri.parse(action);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else if (action == 'chat') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Live chat is connecting...'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (action == 'tickets') {
      context.push('/complaints');
    }
  }
}
