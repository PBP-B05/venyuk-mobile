import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venyuk_mobile/features/promo/models/promo.dart';
import 'package:venyuk_mobile/features/promo/services/auth_service.dart';
import 'package:venyuk_mobile/features/promo/services/promo_service.dart';
import 'package:venyuk_mobile/features/promo/screens/promo_create_page.dart';
import 'package:venyuk_mobile/global/widget/venyuk_app_bar.dart';


class DateFormatter { static String formatDate(DateTime d) => "${d.day}-${d.month}-${d.year}"; }

class PromoDetailPage extends StatefulWidget {
  final PromoElement promo; // Sesuaikan dengan nama class model kamu (Promo/PromoElement)

  const PromoDetailPage({
    Key? key,
    required this.promo,
  }) : super(key: key);

  @override
  State<PromoDetailPage> createState() => _PromoDetailPageState();
}

class _PromoDetailPageState extends State<PromoDetailPage> {
  final PromoService _promoService = PromoService();
  bool isDeleting = false;

  void _copyPromoCode() {
    Clipboard.setData(ClipboardData(text: widget.promo.code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode promo berhasil disalin!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromoCreatePage(promoToEdit: widget.promo),
      ),
    ).then((result) {
      if (result == true) Navigator.pop(context, true);
    });
  }

  Future<void> _deletePromo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Promo'),
        content: Text('Apakah Anda yakin ingin menghapus promo "${widget.promo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        isDeleting = true;
      });

      try {
        final result = await _promoService.deletePromo(widget.promo.code);
        
        if (mounted) {
          if (result['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Promo berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return to list and refresh
          } else {
            throw Exception(result['status'] ?? 'Delete failed');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const VenyukAppBar(
        title: 'Detail Promo',
        showBackButton: true,
        showUserMenu: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroBanner(),
            // -------------------------------------------------------------
            // RESPONSIVE BUILDER
            // Mendeteksi lebar layar untuk menentukan layout
            // -------------------------------------------------------------
            LayoutBuilder(
              builder: (context, constraints) {
                // Jika lebar > 800px (Tablet/Desktop), pakai layout Row (Samping-sampingan)
                if (constraints.maxWidth > 800) {
                  return _buildWideContent();
                } 
                // Jika layar sempit (HP), pakai layout Column (Atas-Bawah)
                else {
                  return _buildMobileContent();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B3A3A), Color(0xFF1A1A2E)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.promo.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox( // Agar teks diskon mengecil otomatis jika layar sangat sempit
            fit: BoxFit.scaleDown,
            child: Text(
              'DISKON ${widget.promo.amountDiscount}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LAYOUT UNTUK LAYAR LEBAR (DESKTOP) ---
  Widget _buildWideContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildPromoInfo()),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: _buildPromoDetails()), // Bagian kanan lebih lebar
        ],
      ),
    );
  }

  // --- LAYOUT UNTUK HP (MOBILE) ---
  Widget _buildMobileContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildPromoInfo(), // Info di atas
          const SizedBox(height: 20),
          _buildPromoDetails(), // Detail di bawah
        ],
      ),
    );
  }

  Widget _buildPromoInfo() {
    return Container(
      width: double.infinity, // Pastikan mengisi lebar container
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.promo.title,
            style: const TextStyle(
              fontSize: 24, // Sedikit dikecilkan untuk mobile
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.promo.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoDetails() {
    final isSuperuser = AuthService.isSuperuser;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Promo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailSection('Kode Promo', widget.promo.code, isCode: true),
          const SizedBox(height: 16),
          // Menggunakan Safe Detail Row agar tidak overflow
          _buildDetailRow('Kategori:', widget.promo.categoryDisplay),
          const SizedBox(height: 12),
          _buildDetailRow('Mulai Berlaku:', DateFormatter.formatDate(widget.promo.startDate)),
          const SizedBox(height: 12),
          _buildDetailRow('Berakhir Pada:', DateFormatter.formatDate(widget.promo.endDate)),
          const SizedBox(height: 12),
          _buildDetailRow('Maks. Penggunaan:', '${widget.promo.maxUses} kali'),
          
          if (isSuperuser) ...[
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, {bool isCode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isCode ? _copyPromoCode : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF8B3A3A), width: 1.5),
              borderRadius: BorderRadius.circular(8),
              color: Colors.red[50], // Sedikit warna background biar jelas bisa diklik
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flexible mencegah kode yang sangat panjang menabrak icon
                Flexible(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis, // Potong jika kepanjangan
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B3A3A),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (isCode) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.copy, size: 18, color: Color(0xFF8B3A3A)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget Row yang sudah diperbaiki dengan Expanded
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // Label tetap di atas
        children: [
          // Label (kiri)
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          
          const SizedBox(width: 16), // Jarak aman

          // Value (kanan) - DIBERI EXPANDED AGAR TIDAK OVERFLOW
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right, // Rata kanan
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon( // Pakai .icon biar lebih cantik
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Promo'),
            onPressed: isDeleting ? null : _navigateToEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B6FE8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: isDeleting 
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.delete, size: 18),
            label: Text(isDeleting ? 'Menghapus...' : 'Hapus Promo'),
            onPressed: isDeleting ? null : _deletePromo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB83A3A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}