import 'package:flutter/material.dart';

class MatchFilter extends StatefulWidget {
  final Function(String city, String category) onFilterChanged;

  const MatchFilter({super.key, required this.onFilterChanged});

  @override
  State<MatchFilter> createState() => _MatchFilterState();
}

class _MatchFilterState extends State<MatchFilter> {
  final TextEditingController _cityController = TextEditingController();
  String _selectedCategory = 'all';

  // List kategori sesuai venue/models.py kamu
  final List<String> _categories = ['all', 'Indoor', 'Outdoor', 'Futsal', 'Badminton']; 

  void _applyFilter() {
    widget.onFilterChanged(_cityController.text, _selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Input Search City
          TextField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: "Cari berdasarkan Kota",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            onChanged: (val) => _applyFilter(), // Auto search saat ketik
          ),
          const SizedBox(height: 12),
          
          // Dropdown Kategori
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Kategori Venue",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category == 'all' ? 'Semua Kategori' : category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
                _applyFilter();
              },
            ),
          ),
        ],
      ),
    );
  }
}