import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Shared geometry so the ruled lines, the rows that sit on them, and the
/// margin rule all use one coordinate system.
class NotebookMetrics {
  NotebookMetrics._();

  /// Height of a single ruled line / list row. Every home row (and the filler
  /// lines below the list) is exactly this tall, so everything lines up.
  static const double lineHeight = 56;

  /// Horizontal position of the red margin rule from the left edge.
  static const double marginX = 28;

  /// The ruling colour for the current brightness.
  static Color ruleColor(bool isDark) => isDark
      ? AppColors.paperRuleLight.withValues(alpha: 0.10)
      : AppColors.paperRuleLight;

  static Color marginColor(bool isDark) =>
      isDark ? AppColors.paperMarginDark : AppColors.paperMarginLight;

  static Color paperColor(bool isDark) =>
      isDark ? AppColors.paperDark : AppColors.paperLight;
}

/// Full-bleed paper backdrop: warm paper fill plus the single vertical margin
/// rule. Horizontal ruling is provided per-row by [RuledLine] so the lines
/// always scroll in lockstep with the content. Use this as the bottom layer
/// of a [Stack] behind a screen.
class NotebookBackground extends StatelessWidget {
  const NotebookBackground({super.key});

  // Back-compat aliases for callers that used the old API.
  static const double defaultMarginX = NotebookMetrics.marginX;
  static Color ruleColor(bool isDark) => NotebookMetrics.ruleColor(isDark);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _PaperPainter(isDark: isDark),
      child: const SizedBox.expand(),
    );
  }
}

class _PaperPainter extends CustomPainter {
  _PaperPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = NotebookMetrics.paperColor(isDark),
    );
    canvas.drawLine(
      const Offset(NotebookMetrics.marginX, 0),
      Offset(NotebookMetrics.marginX, size.height),
      Paint()
        ..color = NotebookMetrics.marginColor(isDark)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_PaperPainter old) => old.isDark != isDark;
}

/// One ruled line: a fixed-height ([NotebookMetrics.lineHeight]) cell with a
/// ruled bottom border. Wrap row content in it, or use it empty as filler to
/// rule the blank part of the page. Because every line is the same height and
/// contiguous, the ruling stays perfectly aligned.
class RuledLine extends StatelessWidget {
  const RuledLine({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: NotebookMetrics.lineHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: NotebookMetrics.ruleColor(isDark),
            width: 1,
          ),
        ),
      ),
      child: child,
    );
  }
}
