import 'package:flutter/material.dart';
import '../models/venue_model.dart';
import '../services/venue_service.dart';
import '../widgets/venue_card.dart';
import 'booking_page.dart';
import '../../venyuk/widgets/left_drawer.dart';
import '../../../global/widget/venyuk_app_bar.dart';

class VenuePage extends StatefulWidget {
  const VenuePage({super.key});

  @override
  State<VenuePage> createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  late Future<List<Venue>> _venuesFuture;

  String _searchQuery = '';
  String? _selectedCategory;
  int? _minPrice;
  int? _maxPrice;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  void _loadVenues() {
    setState(() {
      _venuesFuture = VenueService.fetchVenues(
        query: _searchQuery,
        category: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: const VenyukAppBar(
        title: 'Daftar Venue',
        showDrawerButton: true,
        showUserMenu: true,
        ),
      body: Column(
        children: [
          // Bagian Search & Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari venue...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      // Tambahkan debounce jika perlu
                    },
                    onSubmitted: (_) => _loadVenues(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Logika filter popup
                  },
                ),
              ],
            ),
          ),

          // Bagian List Venue (RESPONSIVE GRID)
          Expanded(
            child: FutureBuilder<List<Venue>>(
              future: _venuesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final venues = snapshot.data!;

                if (venues.isEmpty) {
                  return const Center(
                    child: Text('Belum ada venue tersedia'),
                  );
                }

                // --- LOGIKA RESPONSIVE DIMULAI DI SINI ---
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int gridCount = 1;
                    if (constraints.maxWidth > 1200) {
                      gridCount = 4;
                    } else if (constraints.maxWidth > 800) {
                      gridCount = 3; 
                    } else if (constraints.maxWidth > 600) {
                      gridCount = 2; 
                    } else {
                      gridCount = 1;
                    }

                    double aspectRatio;
  
                    if (gridCount == 1) {
                      aspectRatio = 0.9; 
                    } else {
                      aspectRatio = 0.75; 
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount,
                        childAspectRatio: aspectRatio,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16, // Jarak antar kolom
                      ),
                      itemCount: venues.length,
                      itemBuilder: (context, index) {
                        final venue = venues[index];
                        return VenueCard(
                          venue: venue,
                          onBook: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingPage(venue: venue),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
                // --- AKHIR LOGIKA RESPONSIVE ---
              },
            ),
          ),
        ],
      ),
    );
  }
}