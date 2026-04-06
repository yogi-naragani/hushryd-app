import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _rideAlerts = true;
  bool _promotionalEmails = false;
  bool _darkMode = false;
  bool _locationEnabled = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Text('AK',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Arun Kumar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(height: 2),
                        Text('arun.kumar@email.com',
                            style:
                                TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),

            // Account section
            _sectionHeader('Account'),
            _navItem(Icons.person_outline, 'Personal Information',
                () => context.go('/profile')),
            _navItem(Icons.verified_user_outlined, 'Verification',
                () {}),
            _navItem(Icons.lock_outline, 'Change Password', () {}),
            _navItem(Icons.security, 'Two-Factor Authentication',
                () {}),

            // Preferences section
            _sectionHeader('Preferences'),
            _switchItem(
              Icons.notifications_outlined,
              'Push Notifications',
              'Receive ride updates and alerts',
              _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v),
            ),
            _switchItem(
              Icons.notifications_active_outlined,
              'Ride Alerts',
              'Get notified about matching rides',
              _rideAlerts,
              (v) => setState(() => _rideAlerts = v),
            ),
            _switchItem(
              Icons.email_outlined,
              'Promotional Emails',
              'Receive offers and promotions',
              _promotionalEmails,
              (v) => setState(() => _promotionalEmails = v),
            ),
            _switchItem(
              Icons.dark_mode_outlined,
              'Dark Mode',
              'Switch to dark theme',
              _darkMode,
              (v) => setState(() => _darkMode = v),
            ),
            _switchItem(
              Icons.location_on_outlined,
              'Location Services',
              'Allow app to access location',
              _locationEnabled,
              (v) => setState(() => _locationEnabled = v),
            ),
            // Language selector
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.language,
                    color: AppColors.primary, size: 20),
              ),
              title: const Text('Language',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              trailing: DropdownButton<String>(
                value: _language,
                underline: const SizedBox(),
                items: ['English', 'Hindi', 'Telugu', 'Tamil']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _language = v);
                },
              ),
            ),

            // Payment section
            _sectionHeader('Payment'),
            _navItem(Icons.payment_outlined, 'Payment Methods',
                () => context.push('/payment')),
            _navItem(Icons.account_balance_wallet_outlined, 'Wallet',
                () => context.push('/payment')),

            // App Settings section
            _sectionHeader('App Settings'),
            _navItem(Icons.info_outline, 'About HushRyd', () {}),
            _navItem(Icons.description_outlined, 'Terms of Service',
                () {}),
            _navItem(Icons.privacy_tip_outlined, 'Privacy Policy',
                () {}),
            _navItem(Icons.star_outline, 'Rate the App', () {}),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child:
                    Icon(Icons.info, color: Colors.grey[500], size: 20),
              ),
              title: const Text('App Version',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              trailing: Text('1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ),

            // Danger zone
            _sectionHeader('Danger Zone'),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                child: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
              ),
              title: const Text('Delete Account',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: AppColors.error)),
              subtitle: const Text('Permanently delete your account and data',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                        'This action is irreversible. All your data will be permanently deleted.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/login');
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.5)),
    );
  }

  Widget _navItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing:
          const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
      onTap: onTap,
    );
  }

  Widget _switchItem(IconData icon, String title, String subtitle,
      bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
