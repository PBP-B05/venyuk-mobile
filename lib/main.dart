import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
// PENTING: Pastikan baris import ini tidak merah.
// 1. Cek 'venyuk' atau 'venyuk_mobile' (sesuai pubspec.yaml kamu)
// 2. Cek apakah nama file kamu 'article_list_page.dart' atau 'blog_list_page.dart'
import 'package:venyuk_mobile/features/article/screens/blog_list_page.dart';

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
          // Menggunakan warna merah maroon sesuai request kamu
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB71C1C)),
          useMaterial3: true,
        ),
        // BAGIAN INI KUNCINYA!
        // Kita ganti 'MyHomePage' menjadi 'ArticleListPage'
        home: const BlogListPage(),
      ),
    );
  }
}