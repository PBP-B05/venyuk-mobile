import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../../auth/login.dart';
import '../pages/venue_page.dart';


class LandingHero extends StatelessWidget {
  const LandingHero({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: width < 768 ? 520 : 650,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/landing/landing_banner.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(29, 22, 22, 0.9),
                  Color.fromRGBO(142, 22, 22, 0.8),
                  Color.fromRGBO(216, 64, 64, 0.6),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: AppColors.lightText,
                          ),
                          children: [
                            TextSpan(text: 'Selamat Datang di\n'),
                            TextSpan(
                              text: 'VenYuk!',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Platform yang menyediakan kebutuhan olahraga mulai dari venue, alat, teman, dan komunitas.',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                        ),
                        onPressed: () {
                          final request = context.read<CookieRequest>();

                          if (request.loggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VenuePage(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(), //Easier to debug
                              ),
                            );
                          }
                        },
                        child: const Text('Yuk Pesan Venue →', style: TextStyle(color: AppColors.lightText)),
                      ),
                    ],
                  ),
                ),

                if (width > 900)
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'images/landing/ronaldo.png',
                      height: 450,
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
