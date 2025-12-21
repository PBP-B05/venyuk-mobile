import 'package:flutter/material.dart';
import '../models/venue_model.dart';
import '../services/venue_service.dart';
import '../widgets/venue_card.dart';
import 'booking_page.dart';

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
      appBar: AppBar(
        title: const Text('Booking Venue'),
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari venue...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                _searchQuery = value;
                _loadVenues();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedCategory,
                    hint: const Text('Kategori'),
                    items: const [
                      DropdownMenuItem<String?>(value: null, child: Text('All Category')),
                      DropdownMenuItem(value: 'futsal', child: Text('Futsal')),
                      DropdownMenuItem(value: 'basketball', child: Text('Basketball')),
                      DropdownMenuItem(value: 'badminton', child: Text('Badminton')),
                      DropdownMenuItem(value: 'mini soccer', child: Text('Mini Soccer')),
                      DropdownMenuItem(value: 'tennis', child: Text('Tennis')),
                      DropdownMenuItem(value: 'padel', child: Text('Padel')),
                      DropdownMenuItem(value: 'voli', child: Text('Voli')),
                      DropdownMenuItem(value: 'biliard', child: Text('Biliard')),
                      DropdownMenuItem(value: 'golf', child: Text('Golf')),
                      DropdownMenuItem(value: 'shooting', child: Text('Shooting')),
                      DropdownMenuItem(value: 'tennis meja', child: Text('Tennis Meja')),
                      DropdownMenuItem(value: 'sepak bola', child: Text('Sepak Bola')),
                      DropdownMenuItem(value: 'pickle ball', child: Text('Pickle Ball')),
                      DropdownMenuItem(value: 'squash', child: Text('Squash')),
                    ],
                    onChanged: (value) {
                      _selectedCategory = value;
                      _loadVenues();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Min Harga',
                    ),
                    onSubmitted: (value) {
                      _minPrice = int.tryParse(value);
                      _loadVenues();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Max Harga',
                    ),
                    onSubmitted: (value) {
                      _maxPrice = int.tryParse(value);
                      _loadVenues();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: FutureBuilder<List<Venue>>(
              future: _venuesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final venues = snapshot.data!;

                if (venues.isEmpty) {
                  return const Center(
                    child: Text('Belum ada venue tersedia'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 2.0,
                    mainAxisSpacing: 16,
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
            ),
          ),
        ],
      ),
    );
  }
}
