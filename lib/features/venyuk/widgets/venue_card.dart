import 'package:flutter/material.dart';
import '../models/venue_model.dart';
import '../../../theme/app_colors.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onBook;

  const VenueCard({
    super.key,
    required this.venue,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              venue.imageUrl.isNotEmpty
                  ? 'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(venue.imageUrl)}'
                  : 'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(
                      'https://cdn.antaranews.com/cache/1200x800/2025/09/10/1000017960.jpg',
                    )}',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.network(
                'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(
                  'https://cdn.antaranews.com/cache/1200x800/2025/09/10/1000017960.jpg',
                )}',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  children: venue.categories
                      .map(
                        (c) => Chip(
                          label: Text(c),
                          backgroundColor: Colors.red.shade50,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 6),

                Text(
                  venue.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(venue.rating.toStringAsFixed(1)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        venue.address,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${venue.price.toStringAsFixed(0)} / jam',
                      style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: venue.isAvailable ? onBook : null,
                      child: Text(
                        venue.isAvailable
                            ? 'Book Now'
                            : 'Not Available',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
