import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:venyuk_mobile/features/ven_shop/models/history_item.dart';
import 'package:venyuk_mobile/global/widget/venyuk_app_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  
  Future<List<HistoryItem>> fetchHistory(CookieRequest request) async {
    final response = await request.get('https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/ven_shop/history-json/');
    
    List<HistoryItem> listHistory = [];
    for (var d in response) {
      if (d != null) {
        listHistory.add(HistoryItem.fromJson(d));
      }
    }
    return listHistory;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: const VenyukAppBar(
        title: 'Riwayat Pembelian',
        showDrawerButton: false,
        showUserMenu: false,
        showBackButton: true,
        ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder(
        future: fetchHistory(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Belum ada riwayat pembelian.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  final item = snapshot.data![index];
                  
                  // history
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Thumbnail
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              image: item.productImage != null && item.productImage!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(item.productImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: item.productImage == null || item.productImage!.isEmpty
                                ? const Icon(Icons.shopping_bag, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          
                          // Detail
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rp${item.productPrice}",
                                  style: const TextStyle(
                                    color: Color(0xFFD84040),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.purchaseDate,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Text(
                              "Sukses",
                              style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}