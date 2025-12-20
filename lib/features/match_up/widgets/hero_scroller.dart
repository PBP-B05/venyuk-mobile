import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../screens/match_detail_screen.dart'; 

class HeroScroller extends StatelessWidget {
  final List<Match> matches;

  const HeroScroller({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();

    // Ambil max 5 match
    final displayMatches = matches.take(5).toList();

    return SizedBox(
      height: 220, // Tinggi area carousel
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9), // Biar kelihatan card sebelah dikit
        itemCount: displayMatches.length,
        itemBuilder: (context, index) {
          return _buildCard(context, displayMatches[index]);
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, Match match) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MatchDetailScreen(matchId: match.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200], // Warna dasar kalau gambar belum load
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. LOGIC GAMBAR
              if (match.venueImage.isNotEmpty)
                Image.network(
                  match.venueImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Kalau gambar error/gagal load, tampilkan placeholder icon
                    return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                  },
                )
              else
                // Kalau tidak ada URL gambar
                const Center(child: Icon(Icons.sports_soccer, size: 48, color: Colors.grey)),

              // 2. GRADIENT GELAP (Biar teks terbaca)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),

              // 3. TEKS JUDUL
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Difficulty
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        match.difficultyLevel,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.venueName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
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