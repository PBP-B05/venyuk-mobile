// =====================================
// FILE: lib/screens/promo_page.dart
// =====================================

import 'package:flutter/material.dart';
import 'package:venyuk_mobile/features/promo/models/promo.dart';
import 'package:venyuk_mobile/features/promo/services/promo_service.dart';
import 'package:venyuk_mobile/features/promo/widgets/promo_card.dart';
import 'package:venyuk_mobile/features/promo/widgets/promo_filter_tabs.dart';
import 'package:venyuk_mobile/features/promo/widgets/promo_hero_section.dart';
import 'package:venyuk_mobile/features/promo/widgets/promo_action_bar.dart';
import 'package:venyuk_mobile/features/promo/screens/promo_detail_page.dart';
import 'package:venyuk_mobile/features/promo/screens/promo_create_page.dart';
import 'package:venyuk_mobile/features/venyuk/widgets/left_drawer.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({Key? key}) : super(key: key);

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  final PromoService _promoService = PromoService();
  List<PromoElement> allPromos = [];
  List<PromoElement> filteredPromos = [];
  bool isLoading = true;
  String selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    fetchPromos();
  }

  Future<void> fetchPromos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final promos = await _promoService.fetchPromos();
      setState(() {
        allPromos = promos;
        filteredPromos = promos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void filterPromos(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Semua') {
        filteredPromos = allPromos;
      } else if (filter == 'Shop') {
        filteredPromos = allPromos.where((p) => p.category == 'shop').toList();
      } else if (filter == 'Venue') {
        filteredPromos = allPromos.where((p) => p.category == 'venue').toList();
      }
    });
  }

  void navigateToCreatePromo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PromoCreatePage()),
    ).then((result) {
      if (result == true) {
        fetchPromos(); // Refresh list after create
      }
    });
  }

  void navigateToPromoDetail(PromoElement promo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromoDetailPage(promo: promo),
      ),
    ).then((result) {
      if (result == true) {
        fetchPromos(); // Refresh list after edit/delete
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const LeftDrawer(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const PromoHeroSection(),
          PromoActionBar(onCreatePromo: navigateToCreatePromo),
          PromoFilterTabs(
            selectedFilter: selectedFilter,
            onFilterChanged: filterPromos,
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildPromoList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Image.asset(
        'assets/images/logo_venyuk.png',
        height: 40,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF4A90E2),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'pbpb05',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredPromos.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada promo tersedia',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchPromos,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filteredPromos.length,
        itemBuilder: (context, index) {
          final promo = filteredPromos[index];
          return PromoCard(
            promo: promo,
            onTap: () => navigateToPromoDetail(promo),
          );
        },
      ),
    );
  }
}