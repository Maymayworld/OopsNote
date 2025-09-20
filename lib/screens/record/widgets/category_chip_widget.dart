// 
import 'package:flutter/material.dart';
import 'package:misslog/themes/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey[300]!,
            width: 1,
          ),
          color: isSelected ? primaryBlue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            categoryName,
            style: TextStyle(
              color: isSelected ? primaryBlue : textSecondaryGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
