import 'package:flutter/material.dart';
import 'package:venyuk_mobile/theme/app_colors.dart';
import '../models/venue_model.dart';
import '../services/venue_service.dart';
import '../widgets/venue_card.dart';
import '../widgets/left_drawer.dart';
import 'booking_page.dart';
import 'my_bookings_page.dart';

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
      
      appBar: AppBar(
        title: const Text('Booking Venue'),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Tooltip(
              message: 'My Bookings',
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyBookingsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark),
                color: AppColors.primaryRed,
              ),
            ),
          ),
        ],
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 2,
                  ),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Category'),
                      ),
                      DropdownMenuItem(
                        value: 'futsal',
                        child: Text('Futsal'),
                      ),
                      DropdownMenuItem(
                        value: 'basketball',
                        child: Text('Basketball'),
                      ),
                      DropdownMenuItem(
                        value: 'badminton',
                        child: Text('Badminton'),
                      ),
                      DropdownMenuItem(
                        value: 'mini soccer',
                        child: Text('Mini Soccer'),
                      ),
                      DropdownMenuItem(
                        value: 'tennis',
                        child: Text('Tennis'),
                      ),
                      DropdownMenuItem(
                        value: 'padel',
                        child: Text('Padel'),
                      ),
                      DropdownMenuItem(
                        value: 'voli',
                        child: Text('Voli'),
                      ),
                      DropdownMenuItem(
                        value: 'biliard',
                        child: Text('Biliard'),
                      ),
                      DropdownMenuItem(
                        value: 'golf',
                        child: Text('Golf'),
                      ),
                      DropdownMenuItem(
                        value: 'shooting',
                        child: Text('Shooting'),
                      ),
                      DropdownMenuItem(
                        value: 'tennis meja',
                        child: Text('Tennis Meja'),
                      ),
                      DropdownMenuItem(
                        value: 'sepak bola',
                        child: Text('Sepak Bola'),
                      ),
                      DropdownMenuItem(
                        value: 'pickle ball',
                        child: Text('Pickle Ball'),
                      ),
                      DropdownMenuItem(
                        value: 'squash',
                        child: Text('Squash'),
                      ),
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
                    decoration: InputDecoration(
                      hintText: 'Min Harga',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                    decoration: InputDecoration(
                      hintText: 'Max Harga',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryRed,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi Kesalahan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                final venues = snapshot.data!;

                if (venues.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada venue tersedia',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coba ubah filter pencarian Anda',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1.8,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
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