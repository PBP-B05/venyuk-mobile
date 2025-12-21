// booking/booking_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/venue_model.dart';

class BookingModal extends StatefulWidget {
  final Venue venue;
  const BookingModal({super.key, required this.venue});

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> {
  DateTime? date;
  String? startTime;
  String? endTime;

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Booking ${widget.venue.name}",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () async {
              date = await showDatePicker(
                context: context,
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              setState(() {});
            },
            child: Text(date == null
                ? "Pilih Tanggal"
                : date!.toIso8601String().split("T")[0]),
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () async {
              final response = await request.postJson(
                "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/venue/book/${widget.venue.id}/",
                {
                  "booking_date": date!.toIso8601String().split("T")[0],
                  "start_time": "08:00",
                  "end_time": "10:00",
                },
              );

              if (!context.mounted) return;

              if (response['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Booking berhasil")),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'])),
                );
              }
            },
            child: const Text("Booking Sekarang"),
          ),
        ],
      ),
    );
  }
}
