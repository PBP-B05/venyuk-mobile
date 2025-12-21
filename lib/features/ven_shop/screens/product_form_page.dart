import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:venyuk_mobile/features/ven_shop/models/product.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product; 

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  String _category = "Badminton"; 

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _titleController.text = widget.product!.title;
      _brandController.text = widget.product!.brand;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _descController.text = widget.product!.content; 
      _imageController.text = widget.product!.thumbnail ?? ""; 

      List<String> categories = ["Badminton", "Basketball", "Tennis", "Football", "Swimming", "Running", "Volleyball"];
      if (categories.contains(widget.product!.category)) {
        _category = widget.product!.category;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Produk" : "Tambah Produk"),
        backgroundColor: const Color(0xFFD84040),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nama
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Nama Produk", border: OutlineInputBorder()),
              validator: (val) => val == null || val.isEmpty ? "Nama produk tidak boleh kosong!" : null,
            ),
            const SizedBox(height: 12),

            // Merek
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: "Brand", border: OutlineInputBorder()),
              validator: (val) => val == null || val.isEmpty ? "Brand tidak boleh kosong!" : null,
            ),
            const SizedBox(height: 12),

            // price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Harga", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return "Harga tidak boleh kosong!";
                if (int.tryParse(val) == null) return "Harga harus berupa angka!";
                return null;
              },
            ),
            const SizedBox(height: 12),

            // stok
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: "Stok", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return "Stok tidak boleh kosong!";
                if (int.tryParse(val) == null) return "Stok harus berupa angka!";
                return null;
              },
            ),
            const SizedBox(height: 12),

            // category
            DropdownButtonFormField<String>(
              value: _category,
              items: ["Badminton", "Basketball", "Tennis", "Football", "Swimming", "Running", "Volleyball"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: "Kategori", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // deskripsi
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder()),
              maxLines: 3,
              validator: (val) => val == null || val.isEmpty ? "Deskripsi tidak boleh kosong!" : null,
            ),
            const SizedBox(height: 12),

            // Thumbnail
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: "URL Gambar (Opsional)",
                hintText: "Kosongkan untuk pakai gambar default",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // bombol save
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD84040),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  
                  String url = isEdit 
                    ? "http://127.0.0.1:8000/ven_shop/edit-flutter/${widget.product!.id}/"
                    : "http://127.0.0.1:8000/ven_shop/create-flutter/";
                  
                  String finalImage = _imageController.text.trim();
                  if (finalImage.isEmpty) {
                    finalImage = "https://github.com/PBP-B05/venyuk/blob/master/static/images/logo_venyuk.png?raw=true";
                  }

                  try {
                    final response = await request.postJson(url, jsonEncode({
                      "title": _titleController.text,
                      "brand": _brandController.text,
                      "price": int.parse(_priceController.text),
                      "stock": int.parse(_stockController.text),
                      "category": _category,
                      "content": _descController.text,
                      "thumbnail": finalImage, 
                    }));

                    if (context.mounted) {
                      if (response['status'] == 'success') {
                        Navigator.pop(context); 
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Berhasil disimpan!"),
                          backgroundColor: Colors.green,
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Gagal menyimpan."),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error: $e"),
                       ));
                    }
                  }
                }
              },
              child: Text(
                isEdit ? "Simpan Perubahan" : "Buat Produk", 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
              ),
            )
          ],
        ),
      ),
    );
  }
}