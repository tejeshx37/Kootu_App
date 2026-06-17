import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A full-bleed paper backdrop that makes a screen feel like a real notebook
/// page: warm paper fill, faint horizontal ruled lines, and a single margin
/// rule down the left. Theme-aware so it reads correctly in dark mode.
///
/// Drop it as the bottom layer of a [Stack] behind the actual content:
/// ```dart
/// Stack(children: [const Positioned.fill(child: NotebookBackground()), content])
/// ```
class NotebookBackground extends StatelessWidget {
  const NotebookBackground({
    super.key,
    this.lineSpacing = 32,
    this.marginX = 28,
  });

  /// Vertical gap between ruled lines.
  final double lineSpacing;

  /// Distance of the vertical margin rule from the left edge.
  final double marginX;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _NotebookPainter(
        isDark: isDark,
        lineSpacing: lineSpacing,
        marginX: marginX,
      ),
      // Expand to fill whatever the Stack gives us.
      child: const SizedBox.expand(),
    );
  }
}

class _NotebookPainter extends CustomPainter {
  _NotebookPainter({
    required this.isDark,
    required this.lineSpacing,
    required this.marginX,
  });

  final bool isDark;
  final double lineSpacing;
  final double marginX;

  // Warm cream paper in light mode; a deep slate "page" in dark mode.
  Color get _paper =>
      isDark ? const Color(0xFF14141F) : const Color(0xFFFBF7EC);

  Color get _ruleLine =>
      isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD7E1EF);

  Color get _marginLine => isDark
      ? AppColors.accent.withValues(alpha: 0.18)
      : const Color(0xFFE9A8A0);

  @override
  void paint(Canvas canvas, Size size) {
    final paperPaint = Paint()..color = _paper;
    canvas.drawRect(Offset.zero & size, paperPaint);

    final rulePaint = Paint()
      ..color = _ruleLine
      ..strokeWidth = 1;

    // Horizontal ruled lines, starting a little below the top edge.
    for (var y = lineSpacing * 1.5; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rulePaint);
    }

    // Single vertical margin rule.
    final marginPaint = Paint()
      ..color = _marginLine
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(_NotebookPainter old) =>
      old.isDark != isDark ||
      old.lineSpacing != lineSpacing ||
      old.marginX != marginX;
}
