import 'package:flutter/material.dart';
import 'versus_list_page.dart';
import 'community_list_page.dart';

class VersusHomePage extends StatelessWidget {
  const VersusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Versus'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Matchups'),
              Tab(text: 'Communities'),
            ],
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
