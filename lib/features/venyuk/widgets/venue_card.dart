import 'package:flutter/material.dart';
import '../models/venue_model.dart';
// Sesuaikan import warna ini dengan struktur projek kamu
// import '../../../theme/app_colors.dart'; 

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
    // Gunakan LayoutBuilder jika ingin mengubah ukuran font berdasarkan lebar kartu (opsional)
    // Tapi untuk struktur utama, Expanded pada gambar adalah kuncinya.
    return Card(
      elevation: 4,
      // clipBehavior ini memastikan gambar terpotong mengikuti sudut rounded card
      clipBehavior: Clip.antiAlias, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BAGIAN GAMBAR (Gunakan Expanded)
          // Expanded membuat gambar mengisi seluruh ruang vertikal yang tersisa
          // setelah dikurangi ruang untuk teks di bawah.
          Expanded(
            child: Image.network(
              venue.imageUrl.isNotEmpty
                  ? 'https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(venue.imageUrl)}'
                  : 'https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(
                      'https://cdn.antaranews.com/cache/1200x800/2025/09/10/1000017960.jpg',
                    )}',
              width: double.infinity, // Lebar mengikuti kartu
              fit: BoxFit.cover,      // Gambar di-crop agar tidak gepeng
              
              // Tambahkan loading builder agar user tahu gambar sedang dimuat
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              
              // Error builder jika gambar rusak/gagal load
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),

          // 2. BAGIAN INFO TEXT
          Padding(
            padding: const EdgeInsets.all(12.0), // Padding sedikit dikecilkan agar muat
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Kategori & Rating)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        venue.categories[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          "4.8", // Rating dummy (sesuaikan jika ada di model)
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Judul Venue
                Text(
                  venue.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Alamat
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12), // Jarak sebelum tombol

                // Harga & Tombol
                // Kita bungkus Column atau Row tergantung lebar? 
                // Untuk aman di grid sempit, kita stack ke bawah atau Row biasa.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Rp ${venue.price.toStringAsFixed(0)} / jam',
                        style: const TextStyle(
                          // color: AppColors.primaryRed, // Ganti manual jika file warna error
                          color: Color(0xFFB83A3A), 
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                SizedBox(
                  width: double.infinity,
                  height: 36, // Tombol agak tipis agar proporsional
                  child: ElevatedButton(
                    onPressed: venue.isAvailable ? onBook : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB83A3A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero, // Reset padding bawaan
                    ),
                    child: Text(
                      venue.isAvailable ? 'Book Now' : 'Full',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}