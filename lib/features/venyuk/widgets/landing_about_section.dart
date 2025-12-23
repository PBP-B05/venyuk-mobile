import 'package:flutter/material.dart';

class LandingAboutSection extends StatelessWidget {
  const LandingAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Container(
      color: Color(0xFFF5F5F5),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
        vertical: isDesktop ? 100 : 60,
      ),
      child: isDesktop
          ? _buildDesktopLayout()
          : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildWebsitePreview(),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 3,
          child: _buildAboutContent(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildAboutContent(),
        const SizedBox(height: 40),
        _buildWebsitePreview(),
      ],
    );
  }

  Widget _buildWebsitePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'images/landing_icon.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tentang VenYuk!',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8E1616),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Venyuk merupakan aplikasi berbasis web untuk melakukan berbagai hal yang berkaitan dengan olahraga, seperti sewa venue, sewa alat olahraga, beli alat olahraga, blog, bahkan bisa mencari teman buat olahraga bareng.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Aplikasi ini dibuat oleh tim PBB B05 dengan 6 anggota, yaitu, Andi, Ello, Bintoro, Rasyad, Clairine, dan Zaka.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.8,
          ),
        ),
      ],
    );
  }
}