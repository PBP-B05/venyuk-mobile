import 'package:flutter/material.dart';
import '../models/venue_model.dart';
import '../widgets/booking_modal.dart';

class BookingPage extends StatelessWidget {
  final Venue venue;

  const BookingPage({
    super.key,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Venue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                venue.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            const SizedBox(height: 16),

            // NAME
            Text(
              venue.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // CATEGORIES
            Wrap(
              spacing: 8,
              children: venue.categories
                  .map(
                    (c) => Chip(
                      label: Text(c),
                      backgroundColor: Colors.red.shade50,
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 12),

            // PRICE
            Text(
              'Rp ${venue.price.toStringAsFixed(0)} / jam',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 24),

            // BOOK BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: venue.isAvailable
                    ? () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => BookingModal(venue: venue),
                        );
                      }
                    : null,
                child: Text(
                  venue.isAvailable
                      ? 'Lanjut Booking'
                      : 'Venue Tidak Tersedia',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
