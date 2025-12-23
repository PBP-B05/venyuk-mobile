import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../auth/login.dart';
import '../pages/venue_page.dart';

class LandingHero extends StatelessWidget {
  const LandingHero({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Container(
      height: isDesktop ? 700 : (isTablet ? 600 : 500),
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/landing/landing_banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1D1616).withOpacity(0.9),
              Color(0xFF8E1616).withOpacity(0.8),
              Color(0xFFD84040).withOpacity(0.6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
            vertical: 40,
          ),
          child: isDesktop
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildContent(context),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 2,
          child: _buildRonaldoImage(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
            children: const [
              TextSpan(text: 'Selamat Datang di\n'),
              TextSpan(
                text: 'VenYuk!',
                style: TextStyle(
                  color: Color(0xFFD84040),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Platform yang menyediakan kebutuhan olahraga mulai dari venue, alat, teman, dan komunitas.',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD84040),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 32,
              vertical: isDesktop ? 18 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: 3,
          ),
          onPressed: () {
            final request = context.read<CookieRequest>();
            
            if (request.loggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VenuePage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Yuk Pesan Venue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRonaldoImage() {
    return Image.asset(
      'images/landing/ronaldo.png',
      height: 500,
      fit: BoxFit.contain,
    );
  }
}