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

  /// Default horizontal position of the margin rule, shared with list rows so
  /// written items start just to the right of it.
  static const double defaultMarginX = 28;

  /// The ruling colour for the current brightness — used by row underlines so
  /// the lines under items match the page's ruled lines exactly.
  static Color ruleColor(bool isDark) =>
      isDark ? AppColors.paperRuleDark : AppColors.paperRuleLight;

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
  Color get _paper => isDark ? AppColors.paperDark : AppColors.paperLight;

  Color get _ruleLine =>
      isDark ? AppColors.paperRuleDark : AppColors.paperRuleLight;

  Color get _marginLine =>
      isDark ? AppColors.paperMarginDark : AppColors.paperMarginLight;

  @override
  void paint(Canvas canvas, Size size) {
    final paperPaint = Paint()..color = _paper;
    canvas.drawRect(Offset.zero & size, paperPaint);

    // Background ruling is kept lighter than the row underlines so it reads as
    // page texture and doesn't fight with the lines under written items.
    final rulePaint = Paint()
      ..color = _ruleLine.withValues(alpha: _ruleLine.a * 0.55)
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
