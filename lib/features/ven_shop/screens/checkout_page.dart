import 'dart:convert'; // Tambahkan ini untuk jsonEncode
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:venyuk_mobile/features/ven_shop/models/product.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/success_page.dart';
import 'package:venyuk_mobile/global/widget/venyuk_app_bar.dart';
import 'package:venyuk_mobile/theme/app_colors.dart';

class CheckoutPage extends StatefulWidget {
  final Product product;

  const CheckoutPage({super.key, required this.product});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller agar kita bisa ambil teks promo tanpa submit form
  final TextEditingController _promoController = TextEditingController();
  
  String _email = "";
  String _address = "";
  bool _isLoading = false;
  bool _isCheckingPromo = false;
  int? _discountedPrice; // Kalau null, berarti pakai harga asli
  String? _promoMessage;
  bool _isPromoValid = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // --- FUNGSI BARU: CEK PROMO ---
  Future<void> _handleCheckPromo(CookieRequest request) async {
    String code = _promoController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _promoMessage = "Isi kode promo dulu.";
        _isPromoValid = false;
        _discountedPrice = null;
      });
      return;
    }

    setState(() {
      _isCheckingPromo = true;
      _promoMessage = null;
    });

    try {
      // Ganti URL sesuai endpoint Django Anda
      final response = await request.postJson(
        "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/ven_shop/api/check-promo/${widget.product.id}/",
        jsonEncode(<String, String>{
          'promo_code': code,
          'category_context': 'shop',
        }),
      );

      if (response['status'] == 'success') {
        setState(() {
          _isPromoValid = true;
          _discountedPrice = response['final_price'];
          _promoMessage = response['message']; // "Promo Valid! Diskon 20%"
        });
      } else {
        setState(() {
          _isPromoValid = false;
          _discountedPrice = null;
          _promoMessage = response['message']; // Pesan error dari Django
        });
      }
    } catch (e) {
      setState(() {
        _isPromoValid = false;
        _promoMessage = "Gagal mengecek promo: $e";
      });
    } finally {
      setState(() {
        _isCheckingPromo = false;
      });
    }
  }

  // --- FUNGSI LAMA: CHECKOUT ---
  Future<void> _handleCheckout(CookieRequest request) async {
      if (!_formKey.currentState!.validate()) return;
      
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final response = await request.postJson(
          "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/ven_shop/checkout-flutter/${widget.product.id}/",
          jsonEncode(<String, String>{
            'promo_code': _promoController.text, // Ambil dari controller
            'category_context': 'shop',
          }),
        );

        if (response['status'] == 'success') {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessPage(product: widget.product),
            ),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Pembelian berhasil!"),
            ),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(response['message'] ?? "Gagal membeli"),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Terjadi kesalahan: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    // Tentukan harga yang ditampilkan (Diskon atau Normal)
    final int displayPrice = _discountedPrice ?? widget.product.price;
    final bool hasDiscount = _discountedPrice != null;

    return Scaffold(
      appBar: const VenyukAppBar(
        title: 'Checkout',
        showDrawerButton: false,
        showUserMenu: false,
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- DETAIL PRODUK ---
            Text(
              "Produk yang dibeli:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_bag, size: 40),
                title: Text(widget.product.title),
                subtitle: Text("Stok tersisa: ${widget.product.stock}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Tampilan Harga Coret jika ada diskon
                    if (hasDiscount)
                      Text(
                        "Rp ${widget.product.price}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      "Rp $displayPrice",
                      style: TextStyle(
                        color: hasDiscount ? Colors.red : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // --- FORM INPUT ---
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              onSaved: (value) => _email = value!,
              validator: (value) =>
                  value == null || value.isEmpty ? "Email tidak boleh kosong" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Alamat Pengiriman",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              onSaved: (value) => _address = value!,
              validator: (value) =>
                  value == null || value.isEmpty ? "Alamat tidak boleh kosong" : null,
            ),
            const SizedBox(height: 16),

            // --- BAGIAN KODE PROMO (Updated) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _promoController, // Pakai controller
                    decoration: const InputDecoration(
                      labelText: "Kode Promo (Opsional)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.discount),
                    ),
                    // Hapus onSaved _promoCode karena kita pakai controller langsung
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 55, // Samakan tinggi dengan textfield
                  child: ElevatedButton(
                    onPressed: _isCheckingPromo 
                      ? null 
                      : () => _handleCheckPromo(request),
                    style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.primaryRed,
                       foregroundColor: Colors.white
                    ),
                    child: _isCheckingPromo 
                      ? const SizedBox(
                          width: 20, height: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text("Cek"),
                  ),
                ),
              ],
            ),
            
            // --- PESAN VALIDASI PROMO ---
            if (_promoMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  _promoMessage!,
                  style: TextStyle(
                    color: _isPromoValid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // --- TOMBOL BAYAR ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _isLoading ? null : () => _handleCheckout(request),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      "Bayar Rp $displayPrice", // Tampilkan harga dinamis di tombol
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}