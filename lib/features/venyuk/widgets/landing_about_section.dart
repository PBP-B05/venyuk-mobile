import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class LandingAboutSection extends StatelessWidget {
  const LandingAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundGrey,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              'images/landing_icon.png',
              width: 280,
            ),
          ),
          const SizedBox(width: 32),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Tentang VenYuk!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'VenYuk adalah platform olahraga untuk sewa venue, alat, komunitas, dan teman olahraga.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
