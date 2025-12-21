import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/venue_model.dart';

class BookingModal extends StatefulWidget {
  final Venue venue;
  const BookingModal({super.key, required this.venue});

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> {
  DateTime? selectedDate;
  List<String> availableSlots = [];
  String? selectedStart;
  String? selectedEnd;
  bool loadingSlots = false;

  // ---------------- FETCH AVAILABILITY ----------------
  Future<void> fetchAvailability() async {
    if (selectedDate == null) return;

    setState(() {
      loadingSlots = true;
      availableSlots = [];
      selectedStart = null;
      selectedEnd = null;
    });

    final dateStr = selectedDate!.toIso8601String().split('T')[0];
    final url =
        'http://localhost:8000/api/availability/${widget.venue.id}/?date=$dateStr';

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      setState(() {
        availableSlots =
            List<String>.from(jsonData['available_slots']);
      });
    }

    setState(() => loadingSlots = false);
  }

  // ---------------- SUBMIT BOOKING ----------------
  Future<void> submitBooking() async {
    if (selectedDate == null || selectedStart == null || selectedEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi data booking')),
      );
      return;
    }

    final res = await http.post(
      Uri.parse(
          'http://localhost:8000/api/book/${widget.venue.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'booking_date':
            selectedDate!.toIso8601String().split('T')[0],
        'start_time': selectedStart,
        'end_time': selectedEnd,
      }),
    );

    final data = json.decode(res.body);

    if (!context.mounted) return;

    if (res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking berhasil')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Booking gagal')),
      );
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booking ${widget.venue.name}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // DATE PICKER
          ElevatedButton(
            onPressed: () async {
              selectedDate = await showDatePicker(
                context: context,
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (selectedDate != null) {
                await fetchAvailability();
              }
            },
            child: Text(
              selectedDate == null
                  ? 'Pilih Tanggal'
                  : selectedDate!.toIso8601String().split('T')[0],
            ),
          ),

          const SizedBox(height: 12),

          if (loadingSlots)
            const Center(child: CircularProgressIndicator()),

          if (!loadingSlots && availableSlots.isNotEmpty) ...[
            const Text('Jam Mulai'),
            DropdownButton<String>(
              value: selectedStart,
              isExpanded: true,
              hint: const Text('Pilih jam mulai'),
              items: availableSlots
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedStart = v;
                  selectedEnd = null;
                });
              },
            ),

            const SizedBox(height: 8),

            if (selectedStart != null)
              DropdownButton<String>(
                value: selectedEnd,
                isExpanded: true,
                hint: const Text('Pilih jam selesai'),
                items: availableSlots
                    .where((s) => s.compareTo(selectedStart!) > 0)
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  setState(() => selectedEnd = v);
                },
              ),
          ],

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitBooking,
              child: const Text('Booking Sekarang'),
            ),
          ),
        ],
      ),
    );
  }
}