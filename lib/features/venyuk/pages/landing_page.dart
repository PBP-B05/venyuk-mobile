import 'package:flutter/material.dart';
import '../widgets/landing_hero.dart';
import '../widgets/landing_venue_section.dart';
import '../widgets/landing_about_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: const [
            LandingHero(),
            LandingVenueSection(),
            LandingAboutSection(),
          ],
        ),
      ),
    );
  }
}
