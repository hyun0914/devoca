import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool small;

  const CategoryChip({super.key, required this.category, this.small = false});

  static const Map<String, Color> _palette = {
    'Git': Color(0xFFF97316),
    'OOP': Color(0xFF8B5CF6),
    'Architecture': Color(0xFF3B82F6),
    'DevOps': Color(0xFF14B8A6),
    'Testing': Color(0xFF22C55E),
    'Network': Color(0xFF6366F1),
    'Database': Color(0xFF92400E),
    'Security': Color(0xFFEF4444),
    'Frontend': Color(0xFFEC4899),
    'Config': Color(0xFF64748B),
    'Naming': Color(0xFF0891B2),
  };

  static Color colorFor(String category) =>
      _palette[category] ?? const Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final color = colorFor(category);
    final fontSize = small ? 10.0 : 11.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
