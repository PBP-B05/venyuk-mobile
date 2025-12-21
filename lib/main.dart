// import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// Import screen utama kamu
// Pastikan path import ini sesuai dengan struktur foldermu
import 'features/match_up/screens/match_up_screen.dart'; 
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'features/venyuk/pages/landing_page.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(
    Provider(
      create: (_) => CookieRequest(),
      child: const VenYukApp(),
    ),
  );
}

class VenYukApp extends StatelessWidget {
  const VenYukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VenYuk!',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          primary: AppColors.primaryRed,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),

      home: const LandingPage(),
    );
  }
}