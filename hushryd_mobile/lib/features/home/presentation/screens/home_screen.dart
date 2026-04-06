import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/hero_banner.dart';
import '../widgets/timeslot_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedType = 'all';
  String _selectedTimeslot = 'all';

  final _timeslots = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Morning', 'value': 'morning'},
    {'label': 'Afternoon', 'value': 'afternoon'},
    {'label': 'Evening', 'value': 'evening'},
    {'label': 'Night', 'value': 'night'},
  ];

  final _sampleRides = [
    {'id': '1', 'from': 'Hyderabad', 'to': 'Vijayawada', 'time': '06:00 AM', 'fare': 450, 'seats': 3},
    {'id': '2', 'from': 'Hyderabad', 'to': 'Chennai', 'time': '08:30 AM', 'fare': 1200, 'seats': 2},
    {'id': '3', 'from': 'Hyderabad', 'to': 'Bangalore', 'time': '10:00 AM', 'fare': 900, 'seats': 4},
    {'id': '4', 'from': 'Vijayawada', 'to': 'Visakhapatnam', 'time': '02:00 PM', 'fare': 600, 'seats': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: HeroBanner()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBarWidget(
                onSearch: (from, to, date, passengers) {
                  context.push('/search?from=$from&to=$to&date=$date&passengers=$passengers');
                },
              ),
            ),
          ),
          // Ride type selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _typeChip('All Rides', 'all'),
                  const SizedBox(width: 8),
                  _typeChip('Carpool', 'carpool'),
                  const SizedBox(width: 8),
                  _typeChip('Private', 'private'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Timeslot filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _timeslots.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _timeslots[i];
                  final selected = _selectedTimeslot == t['value'];
                  return ChoiceChip(
                    label: Text(t['label']!),
                    selected: selected,
                    selectedColor: AppColors.secondary,
                    labelStyle: TextStyle(color: selected ? Colors.white : null, fontSize: 13),
                    onSelected: (_) => setState(() => _selectedTimeslot = t['value']!),
                  );
                },
              ),
            ),
          ),
          // Popular rides
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Popular Rides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => context.push('/search?from=&to=&date=&passengers=1'),
                    child: const Text('View All')),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final ride = _sampleRides[i];
              return TimeslotCard(
                from: ride['from'] as String,
                to: ride['to'] as String,
                time: ride['time'] as String,
                fare: ride['fare'] as int,
                seats: ride['seats'] as int,
                onTap: () => context.push('/ride/${ride['id']}'),
              );
            }, childCount: _sampleRides.length),
          ),
          // Why HushRyd section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Why choose HushRyd?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _featureCard(Icons.verified_user, 'Verified Riders', 'All users are verified for safety'),
                  _featureCard(Icons.savings, 'Save Money', 'Share costs and save up to 80%'),
                  _featureCard(Icons.eco, 'Eco-Friendly', 'Reduce your carbon footprint'),
                  _featureCard(Icons.shield, 'Safe & Secure', 'SOS button and live tracking'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'sos',
            backgroundColor: AppColors.error,
            onPressed: () => context.push('/sos'),
            child: const Icon(Icons.sos, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String label, String value) {
    final selected = _selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
      onSelected: (_) => setState(() => _selectedType = value),
    );
  }

  Widget _featureCard(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primary)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
