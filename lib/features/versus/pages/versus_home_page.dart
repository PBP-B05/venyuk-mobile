import 'package:flutter/material.dart';
import 'versus_list_page.dart';
import 'community_list_page.dart';

class VersusHomePage extends StatelessWidget {
  const VersusHomePage({super.key});

  static const Color kPrimary = Color(0xFFD84040);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          title: const Text('Versus'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: _VersusTabBar(),
          ),
        ),
        body: const TabBarView(
          children: [
            VersusListPage(),
            CommunityListPage(),
          ],
        ),
      ),
    );
  }
}

class _VersusTabBar extends StatelessWidget {
  const _VersusTabBar();

  static const Color kPrimary = Color(0xFFD84040);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: TabBar(
        indicatorColor: kPrimary,
        indicatorWeight: 3,
        labelColor: kPrimary,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: 'Versus Matches'),
          Tab(text: 'Communities'),
        ],
      ),
    );
  }
}
