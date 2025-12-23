import 'dart:math';
import 'package:flutter/material.dart';
import '../models/venue_model.dart';
import '../services/venue_service.dart';

class LandingVenueSection extends StatefulWidget {
  const LandingVenueSection({super.key});

  @override
  State<LandingVenueSection> createState() => _LandingVenueSectionState();
}

class _LandingVenueSectionState extends State<LandingVenueSection> {
  List<Venue> _randomVenues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomVenues();
  }

  Future<void> _fetchRandomVenues() async {
    try {
      List<Venue> allVenues = await VenueService.fetchVenues();
      
      if (allVenues.isNotEmpty) {
        allVenues.shuffle(Random());
        List<Venue> selected = allVenues.take(4).toList();
        
        if (mounted) {
          setState(() {
            _randomVenues = selected;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Gagal load venue landing: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 80 : 60,
      ),
      child: isDesktop
          ? _buildDesktopLayout()
          : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildLeftContent(),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 3,
          child: _buildVenueGrid(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildLeftContent(),
        const SizedBox(height: 32),
        _buildVenueGrid(),
      ],
    );
  }

  Widget _buildLeftContent() {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sewa lapangan dengan mudah dan cepat.',
          style: TextStyle(
            fontSize: isDesktop ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8E1616),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Ada rencana olahraga tapi belum tahu venue? VenYuk solusinya.',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildVenueGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD84040),
        ),
      );
    }

    if (_randomVenues.isEmpty) {
      return _buildPlaceholderGrid();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: _randomVenues.length,
      itemBuilder: (context, index) {
        final venue = _randomVenues[index];
        return _buildVenueCard(venue);
      },
    );
  }

  Widget _buildVenueCard(Venue venue) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              venue.imageUrl.isNotEmpty
                  ? 'https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(venue.imageUrl)}'
                  : 'https://via.placeholder.com/300',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Color(0xFFD84040),
                    ),
                  ),
                );
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.sports_soccer,
            color: Colors.grey,
            size: 48,
          ),
        ),
      ),
    );
  }
}