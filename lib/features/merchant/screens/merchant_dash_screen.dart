import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MerchantDashScreen extends StatefulWidget {
  const MerchantDashScreen({super.key});
  @override
  State<MerchantDashScreen> createState() => _MerchantDashScreenState();
}

class _MerchantDashScreenState extends State<MerchantDashScreen> {
  final _itemCtrl = TextEditingController(text: 'Basmati Rice');
  double _discount = 10;
  double _radiusKm = 2;
  String _validity = '4 hours';

  static const _demand = [
    ('Rice', 143, 0.95),
    ('Toor Dal', 102, 0.7),
    ('Tomatoes', 88, 0.6),
    ('Milk (2L)', 71, 0.5),
  ];

  static const _activeOffers = [
    ('10% off Basmati Rice', 412, 28, 5840),
    ('Flat ₹15 off Milk (2L)', 318, 16, 2160),
    ('20% off Garam Masala', 207, 9, 1450),
  ];

  @override
  void dispose() {
    _itemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats
          Row(
            children: const [
              _StatTile(label: 'Views Today', value: '1,284'),
              SizedBox(width: 10),
              _StatTile(label: 'Claims', value: '128'),
              SizedBox(width: 10),
              _StatTile(label: 'New Customers', value: '42'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Demand near you',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: scheme.outline),
            ),
            child: Column(
              children: [
                for (final (name, count, ratio) in _demand)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: ratio,
                              backgroundColor: AppColors.primarySoft,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: Text('$count people',
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Post Offer for Rice →'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Quick post offer',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: scheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _itemCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Item or service'),
                ),
                const SizedBox(height: 12),
                Text('Discount: ${_discount.round()}%'),
                Slider(
                  value: _discount,
                  min: 0,
                  max: 50,
                  divisions: 10,
                  onChanged: (v) => setState(() => _discount = v),
                ),
                const SizedBox(height: 4),
                Text('Radius: ${_radiusKm.toStringAsFixed(1)} km'),
                Slider(
                  value: _radiusKm,
                  min: 0.5,
                  max: 5,
                  divisions: 9,
                  onChanged: (v) => setState(() => _radiusKm = v),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _validity,
                  decoration: const InputDecoration(labelText: 'Validity'),
                  items: const [
                    DropdownMenuItem(
                        value: '1 hour', child: Text('1 hour')),
                    DropdownMenuItem(
                        value: '4 hours', child: Text('4 hours')),
                    DropdownMenuItem(
                        value: '1 day', child: Text('1 day')),
                    DropdownMenuItem(
                        value: '3 days', child: Text('3 days')),
                  ],
                  onChanged: (v) => setState(() => _validity = v!),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Post offer'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Active offers',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final (title, views, claims, revenue) in _activeOffers)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: scheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MetricChip(label: '$views views'),
                      const SizedBox(width: 6),
                      _MetricChip(label: '$claims claims'),
                      const SizedBox(width: 6),
                      _MetricChip(label: '₹$revenue revenue'),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.lightTextSecondary)),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
