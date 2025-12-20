import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../services/venue_service.dart';
import '../widgets/venue_card.dart';

class VenuePage extends StatefulWidget {
  const VenuePage({super.key});

  @override
  State<VenuePage> createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  late Future<List<Venue>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _venuesFuture = VenueService.fetchVenues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Venue'),
      ),
      body: FutureBuilder<List<Venue>>(
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
              childAspectRatio: 0.75,
              mainAxisSpacing: 16,
            ),
            itemCount: venues.length,
            itemBuilder: (context, index) {
              final venue = venues[index];
              // return VenueCard(
              //   venue: venue,
              //   onBook: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => BookingPage(venue: venue),
              //       ),
              //     );
              //   },
              // );
            },
          );
        },
      ),
    );
  }
}
