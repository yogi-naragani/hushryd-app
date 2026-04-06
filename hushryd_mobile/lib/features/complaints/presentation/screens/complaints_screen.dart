import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  String _selectedFilter = 'All';
  final _filters = ['All', 'Open', 'In Progress', 'Resolved'];

  final _complaints = [
    {
      'id': 'CMP001',
      'title': 'Driver was late by 30 minutes',
      'description': 'The driver arrived 30 minutes late causing me to miss my meeting.',
      'category': 'Driver',
      'status': 'Open',
      'priority': 'High',
      'date': '05 Apr 2026',
      'rideId': 'BK284710',
      'adminResponse': null,
    },
    {
      'id': 'CMP002',
      'title': 'Incorrect fare charged',
      'description': 'I was charged \u20B9200 extra for my ride from Hyderabad to Vijayawada.',
      'category': 'Payment',
      'status': 'In Progress',
      'priority': 'Medium',
      'date': '03 Apr 2026',
      'rideId': 'BK192384',
      'adminResponse': 'We are reviewing your fare details. Our team will get back within 24 hours.',
    },
    {
      'id': 'CMP003',
      'title': 'Vehicle condition was poor',
      'description': 'The vehicle was not clean and the AC was not working properly.',
      'category': 'Vehicle',
      'status': 'Resolved',
      'priority': 'Low',
      'date': '28 Mar 2026',
      'rideId': 'BK093847',
      'adminResponse': 'We apologize for the inconvenience. A \u20B950 credit has been added to your wallet as compensation. The driver has been notified to maintain vehicle standards.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredComplaints = _selectedFilter == 'All'
        ? _complaints
        : _complaints.where((c) => c['status'] == _selectedFilter).toList();

    final openCount =
        _complaints.where((c) => c['status'] == 'Open').length;
    final inProgressCount =
        _complaints.where((c) => c['status'] == 'In Progress').length;
    final resolvedCount =
        _complaints.where((c) => c['status'] == 'Resolved').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _summaryCard('Open', '$openCount', AppColors.warning),
                const SizedBox(width: 10),
                _summaryCard('In Progress', '$inProgressCount', AppColors.primary),
                const SizedBox(width: 10),
                _summaryCard('Resolved', '$resolvedCount', AppColors.success),
              ],
            ),
          ),

          // Filter buttons
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = _selectedFilter == _filters[i];
                return ChoiceChip(
                  label: Text(_filters[i]),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.grey[700],
                      fontSize: 13),
                  onSelected: (_) =>
                      setState(() => _selectedFilter = _filters[i]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Complaints list
          Expanded(
            child: filteredComplaints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No complaints found',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredComplaints.length,
                    itemBuilder: (_, i) =>
                        _complaintCard(filteredComplaints[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewComplaintSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
    );
  }

  Widget _summaryCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _complaintCard(Map<String, dynamic> complaint) {
    final status = complaint['status'] as String;
    final priority = complaint['priority'] as String;
    final adminResponse = complaint['adminResponse'] as String?;

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
              Text(complaint['id'] as String,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              _statusBadge(status),
              const SizedBox(width: 6),
              _priorityBadge(priority),
            ],
          ),
          const SizedBox(height: 10),
          Text(complaint['title'] as String,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          Text(complaint['description'] as String,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(complaint['category'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(width: 12),
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(complaint['date'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(width: 12),
              Icon(Icons.confirmation_number, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(complaint['rideId'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
          if (adminResponse != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.support_agent,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Admin Response',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(adminResponse,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Open':
        color = AppColors.warning;
      case 'In Progress':
        color = AppColors.primary;
      case 'Resolved':
        color = AppColors.success;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _priorityBadge(String priority) {
    Color color;
    switch (priority) {
      case 'High':
        color = AppColors.error;
      case 'Medium':
        color = AppColors.warning;
      case 'Low':
        color = AppColors.success;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(priority,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _showNewComplaintSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Booking';
    final categories = ['Booking', 'Payment', 'Driver', 'Vehicle', 'Account', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Submit Complaint',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setSheetState(() => selectedCategory = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your issue in detail...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Complaint submitted successfully!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
