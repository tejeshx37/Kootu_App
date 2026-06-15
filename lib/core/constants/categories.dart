import 'package:flutter/material.dart';

/// Ported from src/app/components/MainLayout.tsx (CATEGORIES). The slug
/// `id` is used as the Firestore `category` field; `label`, `emoji`,
/// `color`, `bg` drive UI tags.
class ItemCategory {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  final Color bg;

  const ItemCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
    required this.bg,
  });
}

class Categories {
  Categories._();

  static const List<ItemCategory> all = [
    ItemCategory(
      id: 'vegetables',
      label: 'Vegetables',
      emoji: '🥦',
      color: Color(0xFF16A34A),
      bg: Color(0xFFDCFCE7),
    ),
    ItemCategory(
      id: 'grains_dal',
      label: 'Grains & Dal',
      emoji: '🌾',
      color: Color(0xFFD97706),
      bg: Color(0xFFFEF3C7),
    ),
    ItemCategory(
      id: 'dairy',
      label: 'Dairy',
      emoji: '🥛',
      color: Color(0xFF2563EB),
      bg: Color(0xFFDBEAFE),
    ),
    ItemCategory(
      id: 'meat_fish',
      label: 'Fish & Meat',
      emoji: '🐟',
      color: Color(0xFFDC2626),
      bg: Color(0xFFFEE2E2),
    ),
    ItemCategory(
      id: 'spices',
      label: 'Spices',
      emoji: '🫙',
      color: Color(0xFF7C3AED),
      bg: Color(0xFFEDE9FE),
    ),
    ItemCategory(
      id: 'snacks',
      label: 'Snacks',
      emoji: '🍫',
      color: Color(0xFFDB2777),
      bg: Color(0xFFFCE7F3),
    ),
    ItemCategory(
      id: 'household',
      label: 'Household',
      emoji: '🧹',
      color: Color(0xFF0891B2),
      bg: Color(0xFFCFFAFE),
    ),
    ItemCategory(
      id: 'personal_care',
      label: 'Personal Care',
      emoji: '🧴',
      color: Color(0xFF059669),
      bg: Color(0xFFD1FAE5),
    ),
    ItemCategory(
      id: 'other',
      label: 'Other',
      emoji: '🛒',
      color: Color(0xFF6B7280),
      bg: Color(0xFFF3F4F6),
    ),
  ];

  static ItemCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.last);

  /// Ported from HomeScreen.tsx KEYWORDS map. Substring match, case-insensitive.
  static const Map<String, List<String>> _keywords = {
    'vegetables': [
      'tomato', 'onion', 'potato', 'carrot', 'brinjal', 'spinach',
      'beans', 'peas', 'cabbage', 'cauliflower', 'bitter', 'ladyfinger',
    ],
    'grains_dal': [
      'rice', 'dal', 'atta', 'wheat', 'maida', 'ragi', 'poha', 'oats',
    ],
    'dairy': [
      'milk', 'curd', 'butter', 'ghee', 'paneer', 'cheese', 'lassi', 'cream',
    ],
    'meat_fish': [
      'fish', 'chicken', 'mutton', 'egg', 'prawn', 'meat',
    ],
    'spices': [
      'salt', 'pepper', 'turmeric', 'chilli', 'masala', 'cumin',
      'coriander', 'garam', 'cardamom',
    ],
    'snacks': [
      'biscuit', 'chips', 'chocolate', 'namkeen', 'murukku',
      'mixture', 'candy',
    ],
    'household': [
      'soap', 'detergent', 'broom', 'mop', 'phenyl', 'floor', 'dish', 'trash',
    ],
    'personal_care': [
      'shampoo', 'toothpaste', 'lotion', 'deo', 'razor', 'sanitizer',
    ],
  };

  static ItemCategory categorizeByKeyword(String input) {
    final lower = input.toLowerCase();
    for (final entry in _keywords.entries) {
      if (entry.value.any(lower.contains)) return byId(entry.key);
    }
    return byId('other');
  }
}
