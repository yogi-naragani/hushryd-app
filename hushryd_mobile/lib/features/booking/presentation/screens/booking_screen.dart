import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String rideId;
  const BookingScreen({super.key, required this.rideId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _currentStep = 0;
  String _selectedPayment = 'upi';
  bool _isProcessing = false;
  bool _isConfirmed = false;

  final _ride = {
    'from': 'Hyderabad',
    'to': 'Vijayawada',
    'date': '06 Apr 2026',
    'time': '06:00 AM',
    'price': 450,
    'seats': 1,
    'distance': '275 km',
    'duration': '4h 30m',
    'driverName': 'Rajesh Kumar',
    'vehicleName': 'Maruti Suzuki Ertiga',
    'vehiclePlate': 'TS 09 AB 1234',
  };

  final _paymentMethods = [
    {'id': 'upi', 'name': 'UPI', 'icon': Icons.account_balance, 'subtitle': 'Pay via UPI ID'},
    {'id': 'wallet', 'name': 'HushRyd Wallet', 'icon': Icons.account_balance_wallet, 'subtitle': 'Balance: \u20B91,250'},
    {'id': 'card', 'name': 'Credit/Debit Card', 'icon': Icons.credit_card, 'subtitle': '**** **** **** 4532'},
    {'id': 'cod', 'name': 'Cash on Delivery', 'icon': Icons.money, 'subtitle': 'Pay driver directly'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isConfirmed ? 'Booking Confirmed' : 'Book Ride'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _isConfirmed ? context.go('/') : context.pop(),
        ),
      ),
      body: _isConfirmed ? _buildConfirmation() : _buildSteps(),
    );
  }

  Widget _buildSteps() {
    return Column(
      children: [
        // Step indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: List.generate(3, (i) {
              final labels = ['Details', 'Payment', 'Confirm'];
              final isActive = i <= _currentStep;
              final isComplete = i < _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isActive ? AppColors.primary : Colors.grey.shade300,
                        ),
                      ),
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isComplete
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : Text('${i + 1}',
                                    style: TextStyle(
                                        color: isActive ? Colors.white : Colors.grey,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(labels[i],
                            style: TextStyle(
                                fontSize: 11,
                                color: isActive ? AppColors.primary : Colors.grey,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
                      ],
                    ),
                    if (i < 2 && i == 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < _currentStep ? AppColors.primary : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _currentStep == 0
                ? _buildDetailsStep()
                : _currentStep == 1
                    ? _buildPaymentStep()
                    : _buildReviewStep(),
          ),
        ),

        // Bottom button
        Container(
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
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentStep == 2
                                ? 'Confirm & Pay \u20B9${_ride['price']}'
                                : 'Continue',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      setState(() => _isProcessing = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isConfirmed = true;
          });
        }
      });
    }
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ride Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle, size: 12, color: AppColors.secondary),
                      Container(width: 2, height: 30, color: Colors.grey.shade300),
                      const Icon(Icons.location_on, size: 16, color: AppColors.error),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_ride['from'] as String,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        Text(_ride['to'] as String,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _infoRow('Date', _ride['date'] as String),
              _infoRow('Time', _ride['time'] as String),
              _infoRow('Distance', _ride['distance'] as String),
              _infoRow('Duration', _ride['duration'] as String),
              _infoRow('Seats', '${_ride['seats']}'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Driver & Vehicle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _infoRow('Driver', _ride['driverName'] as String),
              _infoRow('Vehicle', _ride['vehicleName'] as String),
              _infoRow('Plate', _ride['vehiclePlate'] as String),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Price Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _priceRow('Base Fare', '\u20B9400'),
              _priceRow('Service Fee', '\u20B930'),
              _priceRow('GST (5%)', '\u20B920'),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\u20B9${_ride['price']}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...List.generate(_paymentMethods.length, (i) {
          final method = _paymentMethods[i];
          final isSelected = _selectedPayment == method['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedPayment = method['id'] as String),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(method['icon'] as IconData,
                        color: isSelected ? AppColors.primary : Colors.grey),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(method['name'] as String,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black87)),
                        const SizedBox(height: 2),
                        Text(method['subtitle'] as String,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 22),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        // Promo code
        const Text('Have a promo code?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Booking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(_ride['from'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      width: 2, height: 20, color: Colors.white54),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(_ride['to'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_ride['date']} \u2022 ${_ride['time']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('\u20B9${_ride['price']}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _infoRow('Driver', _ride['driverName'] as String),
              _infoRow('Vehicle', _ride['vehicleName'] as String),
              _infoRow('Payment', _paymentMethods
                  .firstWhere((m) => m['id'] == _selectedPayment)['name'] as String),
              _infoRow('Seats', '${_ride['seats']}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _priceRow('Base Fare', '\u20B9400'),
              _priceRow('Service Fee', '\u20B930'),
              _priceRow('GST (5%)', '\u20B920'),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\u20B9${_ride['price']}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'By confirming, you agree to the cancellation policy and terms of service.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.success, size: 64),
            ),
            const SizedBox(height: 24),
            const Text('Booking Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Booking ID: BK${widget.rideId.hashCode.abs().toString().substring(0, 6)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _confirmRow(Icons.location_on, '${_ride['from']} \u2192 ${_ride['to']}'),
                  const SizedBox(height: 12),
                  _confirmRow(Icons.calendar_today, _ride['date'] as String),
                  const SizedBox(height: 12),
                  _confirmRow(Icons.access_time, _ride['time'] as String),
                  const SizedBox(height: 12),
                  _confirmRow(Icons.person, _ride['driverName'] as String),
                  const SizedBox(height: 12),
                  _confirmRow(Icons.directions_car, _ride['vehicleName'] as String),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('\u20B9${_ride['price']}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/track/${widget.rideId}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Track Ride',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Home',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _confirmRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
