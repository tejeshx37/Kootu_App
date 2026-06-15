import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProfileNicknamesScreen extends StatefulWidget {
  const ProfileNicknamesScreen({super.key});
  @override
  State<ProfileNicknamesScreen> createState() =>
      _ProfileNicknamesScreenState();
}

class _ProfileNicknamesScreenState extends State<ProfileNicknamesScreen> {
  final _contacts = const [
    ('Priya Subramaniam', '+91 98765 12345', '👩'),
    ('Rajan Subramaniam', '+91 98765 12346', '👨'),
    ('Kavya Subramaniam', '+91 98765 12347', '👧'),
    ('Anand Kumar', '+91 98765 12348', '👦'),
    ('Meena Kumar', '+91 98765 12349', '👩‍🦰'),
  ];

  final Map<String, String> _nicknames = {};
  String? _editing;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Nicknames')),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: const Text(
              'Nicknames are private to you and shown in your shopping rooms.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          for (final (name, phone, emoji) in _contacts)
            ListTile(
              leading: CircleAvatar(child: Text(emoji)),
              title: _editing == name
                  ? TextField(
                      controller: _ctrl,
                      autofocus: true,
                      onSubmitted: (_) => _save(name),
                      decoration: const InputDecoration(
                        hintText: 'Nickname',
                      ),
                    )
                  : Text(_nicknames[name] == null
                      ? name
                      : '${_nicknames[name]} ($name)'),
              subtitle: Text(phone),
              trailing: _editing == name
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _editing = null),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check,
                              color: AppColors.primary),
                          onPressed: () => _save(name),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        setState(() {
                          _editing = name;
                          _ctrl.text = _nicknames[name] ?? '';
                        });
                      },
                    ),
            ),
        ],
      ),
    );
  }

  void _save(String name) {
    setState(() {
      final v = _ctrl.text.trim();
      if (v.isEmpty) {
        _nicknames.remove(name);
      } else {
        _nicknames[name] = v;
      }
      _editing = null;
    });
  }
}
