import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _i = 0;

  static const _slides = [
    _Slide(
      emoji: '👨‍👩‍👧',
      title: 'Shop together as a family',
      subtitle: 'Build shared lists with the people you live with.',
      gradient: [Color(0xFF1D9E75), Color(0xFF34D399)],
    ),
    _Slide(
      emoji: '🛍️',
      title: 'Nearby offers, hand-picked for you',
      subtitle: 'See deals from local kiranas that match your list.',
      gradient: [Color(0xFFFF6B35), Color(0xFFFFB088)],
    ),
    _Slide(
      emoji: '💰',
      title: 'Save more, together',
      subtitle: 'Track savings as a family — every rupee counts.',
      gradient: [Color(0xFF1D9E75), Color(0xFFFF6B35)],
    ),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _i == _slides.length - 1;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (ctx, i) {
              final s = _slides[i];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: s.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child:
                        Text(s.emoji, style: const TextStyle(fontSize: 90)),
                  ),
                ),
              );
            },
          ),
          // Bottom white card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadii.sheet)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _slides[_i].title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _slides[_i].subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          width: _i == i ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _i == i
                                ? AppColors.primary
                                : AppColors.lightMuted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (last) {
                          context.go('/auth');
                        } else {
                          _pc.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      child: Text(last ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final String emoji, title, subtitle;
  final List<Color> gradient;
  const _Slide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
