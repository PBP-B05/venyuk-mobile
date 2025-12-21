import 'package:flutter/material.dart';

class PromoFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const PromoFilterTabs({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterChip('Semua'),
          const SizedBox(width: 12),
          _buildFilterChip('Shop'),
          const SizedBox(width: 12),
          _buildFilterChip('Venue'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onFilterChanged(label),
      selectedColor: Color(0xFF8B3A3A),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}