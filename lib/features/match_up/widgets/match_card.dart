import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../models/match_model.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Format Tanggal & Jam
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(match.startTime);
    final timeStr = "${DateFormat('HH:mm').format(match.startTime)} - ${DateFormat('HH:mm').format(match.endTime)}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. GAMBAR VENUE (KIRI)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: match.venueImage.isNotEmpty
                      ? Image.network(
                          match.venueImage,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.sports_tennis, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.orange[100], // Placeholder warna
                          child: const Icon(Icons.sports_tennis, color: Colors.orange, size: 40),
                        ),
                ),
              ),
              
              const SizedBox(width: 16),

              // 2. INFORMASI MATCH (KANAN)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Venue
                    Text(
                      match.venueName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Creator
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.purple),
                        const SizedBox(width: 4),
                        Text(
                          "Dibuat oleh:\n${match.creatorUsername}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tanggal
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dateStr,
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Jam
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}