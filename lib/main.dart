import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// Import screen utama kamu
// Pastikan path import ini sesuai dengan struktur foldermu
import 'features/match_up/screens/match_up_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Venyuk Mobile',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // Langsung arahkan home ke MatchUpScreen buatanmu
        home: const MatchUpScreen(),
      ),
    );
  }
}