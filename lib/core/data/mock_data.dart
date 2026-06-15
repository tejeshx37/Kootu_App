import '../constants/categories.dart';
import '../models/list_item.dart';
import '../models/offer.dart';
import '../models/room.dart';

/// Mock fixtures ported from MainLayout.tsx, OffersScreen.tsx and
/// MapExploreScreen.tsx. Used as seed data + as a fallback when Firestore
/// returns empty so screens are never blank during development.
class MockData {
  MockData._();

  static final List<Room> rooms = [
    Room(
      id: '1',
      name: 'Family Room',
      emoji: '🏠',
      createdBy: 'priya',
      memberIds: const ['priya', 'rajan', 'kavya'],
      memberAvatars: const ['👩', '👨', '👧'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      itemCount: 8,
      neededCount: 3,
      budget: const RoomBudget(spent: 2340, total: 3500),
    ),
    Room(
      id: '2',
      name: 'Work Lunch',
      emoji: '🍱',
      createdBy: 'anand',
      memberIds: const ['anand', 'meena'],
      memberAvatars: const ['👩', '👦'],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      itemCount: 5,
      neededCount: 1,
    ),
    Room(
      id: '3',
      name: 'Weekend BBQ',
      emoji: '🍖',
      createdBy: 'rajan',
      memberIds: const ['rajan', 'priya', 'arun', 'kavya'],
      memberAvatars: const ['👨', '👩', '👦', '👧'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      itemCount: 12,
      neededCount: 5,
      budget: const RoomBudget(spent: 850, total: 2000),
    ),
  ];

  static final Map<String, List<ListItem>> itemsByRoom = {
    '1': [
      _item('101', 'Basmati Rice', 'grains_dal', 'Priya', daysAgo: 3),
      _item('102', 'Toor Dal', 'grains_dal', 'Priya', daysAgo: 3),
      _item('103', 'Tomatoes', 'vegetables', 'Rajan',
          daysAgo: 2, bought: true, boughtBy: 'Priya'),
      _item('104', 'Milk (2L)', 'dairy', 'Kavya', daysAgo: 1),
      _item('105', 'Ghee', 'dairy', 'Priya', hoursAgo: 1),
      _item('106', 'Vim Bar', 'household', 'Rajan', minutesAgo: 30),
    ],
    '2': [
      _item('201', 'Sandwich Bread', 'grains_dal', 'Anand', hoursAgo: 1),
      _item('202', 'Curd', 'dairy', 'Meena', hoursAgo: 2),
      _item('203', 'Chips', 'snacks', 'Anand',
          daysAgo: 1, bought: true, boughtBy: 'Meena'),
    ],
    '3': [
      _item('301', 'Chicken', 'meat_fish', 'Rajan', daysAgo: 1),
      _item('302', 'Paneer', 'dairy', 'Priya', daysAgo: 1),
      _item('303', 'Tomatoes', 'vegetables', 'Rajan', hoursAgo: 12),
      _item('304', 'Garam Masala', 'spices', 'Priya', hoursAgo: 12),
      _item('305', 'Charcoal', 'other', 'Rajan',
          daysAgo: 2, bought: true, boughtBy: 'Rajan'),
    ],
  };

  static final List<Offer> offers = [
    Offer(
      id: 'o1',
      merchantId: 'm1',
      merchantName: 'FreshMart Velachery',
      description: '10% off on Basmati Rice & Toor Dal',
      categoryId: 'grains_dal',
      discountType: DiscountType.percent,
      discountValue: 10,
      savings: 120,
      distanceKm: 0.18,
      rating: 4.6,
      validUntil: DateTime.now().add(const Duration(hours: 4, minutes: 23)),
      matchedItemNames: const ['Basmati Rice', 'Toor Dal'],
      nearby: true,
    ),
    Offer(
      id: 'o2',
      merchantId: 'm2',
      merchantName: 'Aavin Booth',
      description: 'Flat ₹15 off on Milk (2L pack)',
      categoryId: 'dairy',
      discountType: DiscountType.flat,
      discountValue: 15,
      savings: 30,
      distanceKm: 0.42,
      rating: 4.4,
      validUntil: DateTime.now().add(const Duration(hours: 8)),
      matchedItemNames: const ['Milk (2L)'],
    ),
    Offer(
      id: 'o3',
      merchantId: 'm3',
      merchantName: 'Subbu Stores',
      description: 'BOGO on Tomatoes (1kg)',
      categoryId: 'vegetables',
      discountType: DiscountType.bogo,
      discountValue: 1,
      savings: 40,
      distanceKm: 0.9,
      rating: 4.2,
      validUntil: DateTime.now().add(const Duration(hours: 2)),
      matchedItemNames: const ['Tomatoes'],
    ),
    Offer(
      id: 'o4',
      merchantId: 'm4',
      merchantName: 'Saravana Spices',
      description: '20% off on Garam Masala range',
      categoryId: 'spices',
      discountType: DiscountType.percent,
      discountValue: 20,
      savings: 60,
      distanceKm: 1.4,
      rating: 4.7,
      validUntil: DateTime.now().add(const Duration(hours: 12)),
    ),
    Offer(
      id: 'o5',
      merchantId: 'm5',
      merchantName: 'KK Snacks Mart',
      description: 'Buy 2 get 1 on chips',
      categoryId: 'snacks',
      discountType: DiscountType.bogo,
      discountValue: 1,
      savings: 25,
      distanceKm: 1.8,
      rating: 4.0,
      validUntil: DateTime.now().add(const Duration(hours: 5)),
    ),
  ];

  static const List<ServiceCategory> serviceCategories = [
    ServiceCategory('Home Services', '🛠️', 0xFFFEF3C7),
    ServiceCategory('Delivery', '🛵', 0xFFDBEAFE),
    ServiceCategory('Health', '🩺', 0xFFFEE2E2),
    ServiceCategory('Beauty', '💅', 0xFFFCE7F3),
    ServiceCategory('Education', '📚', 0xFFEDE9FE),
    ServiceCategory('Repairs', '🔧', 0xFFCFFAFE),
    ServiceCategory('Food & Cook', '🍳', 0xFFFEE2E2),
    ServiceCategory('Packers & Movers', '📦', 0xFFFEF3C7),
    ServiceCategory('Cleaning', '🧹', 0xFFDCFCE7),
    ServiceCategory('Pay Bills', '💸', 0xFFE0E7FF),
    ServiceCategory('Shopping', '🛍️', 0xFFFFE4E6),
    ServiceCategory('More', '➕', 0xFFF3F4F6),
  ];

  static ListItem _item(
    String id,
    String name,
    String categoryId,
    String by, {
    int daysAgo = 0,
    int hoursAgo = 0,
    int minutesAgo = 0,
    bool bought = false,
    String? boughtBy,
  }) {
    final now = DateTime.now();
    final addedAt = now.subtract(Duration(
      days: daysAgo,
      hours: hoursAgo,
      minutes: minutesAgo,
    ));
    return ListItem(
      id: id,
      name: name,
      categoryId: Categories.byId(categoryId).id,
      addedBy: by.toLowerCase(),
      addedByName: by,
      addedAt: addedAt,
      bought: bought,
      boughtAt: bought ? now.subtract(const Duration(hours: 6)) : null,
      boughtBy: boughtBy,
    );
  }
}

class ServiceCategory {
  final String label;
  final String emoji;
  final int bgArgb;
  const ServiceCategory(this.label, this.emoji, this.bgArgb);
}
