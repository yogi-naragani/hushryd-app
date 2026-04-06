import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class SearchBarWidget extends StatefulWidget {
  final void Function(String from, String to, String date, int passengers) onSearch;
  const SearchBarWidget({super.key, required this.onSearch});
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _from = TextEditingController(text: 'Hyderabad');
  final _to = TextEditingController(text: 'Vijayawada');
  DateTime _date = DateTime.now();
  int _passengers = 1;

  @override
  void dispose() { _from.dispose(); _to.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _from,
              decoration: const InputDecoration(
                labelText: 'From', prefixIcon: Icon(Icons.trip_origin, color: AppColors.secondary),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _to,
              decoration: const InputDecoration(
                labelText: 'To', prefixIcon: Icon(Icons.location_on, color: AppColors.error),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context, initialDate: _date,
                        firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date', prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text('${_date.day}/${_date.month}/${_date.year}'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Seats', border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () { if (_passengers > 1) setState(() => _passengers--); },
                          child: const Icon(Icons.remove_circle_outline, size: 22),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('$_passengers', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        InkWell(
                          onTap: () { if (_passengers < 8) setState(() => _passengers++); },
                          child: const Icon(Icons.add_circle_outline, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => widget.onSearch(
                  _from.text, _to.text,
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                  _passengers,
                ),
                icon: const Icon(Icons.search),
                label: const Text('Search Rides'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
