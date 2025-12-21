// =====================================
// FILE: lib/screens/promo_create_page.dart
// =====================================

import 'package:flutter/material.dart';
import '../models/promo.dart';
import '../services/promo_service.dart';

class PromoCreatePage extends StatefulWidget {
  final PromoElement? promoToEdit;

  const PromoCreatePage({
    Key? key,
    this.promoToEdit,
  }) : super(key: key);

  @override
  State<PromoCreatePage> createState() => _PromoCreatePageState();
}

class _PromoCreatePageState extends State<PromoCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final PromoService _promoService = PromoService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountDiscountController;
  late TextEditingController _maxUsesController;

  String _selectedCategory = 'venue';
  DateTime? _startDate;
  DateTime? _endDate;
  bool isLoading = false;

  bool get isEditMode => widget.promoToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.promoToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.promoToEdit?.description ?? '');
    _amountDiscountController = TextEditingController(
      text: widget.promoToEdit?.amountDiscount.toString() ?? '',
    );
    _maxUsesController = TextEditingController(
      text: widget.promoToEdit?.maxUses.toString() ?? '',
    );

    if (widget.promoToEdit != null) {
      _selectedCategory = widget.promoToEdit!.category;
      _startDate = widget.promoToEdit!.startDate;
      _endDate = widget.promoToEdit!.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountDiscountController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan berakhir')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal berakhir harus setelah tanggal mulai')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final promoData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'amount_discount': int.parse(_amountDiscountController.text),
        'category': _selectedCategory,
        'max_uses': int.parse(_maxUsesController.text),
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _endDate!.toIso8601String().split('T')[0],
        'is_active': true,
      };

      if (isEditMode) {
        await _promoService.updatePromo(widget.promoToEdit!.code, promoData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Promo berhasil diupdate')),
          );
        }
      } else {
        await _promoService.createPromo(promoData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Promo berhasil dibuat')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Edit Promo' : 'Buat Promo Baru',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Judul Promo',
                hint: 'Masukkan judul promo',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul promo tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hint: 'Masukkan deskripsi promo',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _amountDiscountController,
                label: 'Diskon (%)',
                hint: 'Masukkan persentase diskon',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Diskon tidak boleh kosong';
                  }
                  final discount = int.tryParse(value);
                  if (discount == null || discount < 1 || discount > 100) {
                    return 'Diskon harus antara 1-100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _maxUsesController,
                label: 'Maksimal Penggunaan',
                hint: 'Masukkan maksimal penggunaan',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Maksimal penggunaan tidak boleh kosong';
                  }
                  final maxUses = int.tryParse(value);
                  if (maxUses == null || maxUses < 1) {
                    return 'Maksimal penggunaan harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildDatePicker('Tanggal Mulai', _startDate, true),
              const SizedBox(height: 20),
              _buildDatePicker('Tanggal Berakhir', _endDate, false),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B3A3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditMode ? 'Update Promo' : 'Buat Promo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8B3A3A)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8B3A3A)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: const [
            DropdownMenuItem(value: 'venue', child: Text('Venue')),
            DropdownMenuItem(value: 'shop', child: Text('Shop')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, bool isStartDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isStartDate),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Pilih tanggal',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? Colors.black : Colors.grey[500],
                  ),
                ),
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}