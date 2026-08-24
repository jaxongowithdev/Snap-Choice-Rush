import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class CompassWheel extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const CompassWheel({super.key, required this.index, required this.onSelect});

  static const _labels = ['TRUE', 'MAPS', 'STAR', 'LOG', 'CABIN'];

  void _onTap(Offset local, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final v = local - c;
    if (v.distance < 18) {
      onSelect(0);
      return;
    }
    var angle = math.atan2(v.dy, v.dx);
    angle = (angle + math.pi / 2) % (math.pi * 2);
    if (angle < 0) angle += math.pi * 2;
    onSelect((angle / (math.pi * 2 / 5)).floor() % 5);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Center(
            child: SizedBox(
              width: 196,
              height: 196,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    onTapDown: (d) => _onTap(d.localPosition, size),
                    child: CustomPaint(
                      painter: _CompassPainter(index: index, dark: dark),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final int index;
  final bool dark;
  _CompassPainter({required this.index, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 - 4;
    final sea = dark ? const Color(0xFF122830) : VisualTheme.primaryColor;
    final sand = dark ? const Color(0xFFF4E6CE) : VisualTheme.sand;
    final brass = VisualTheme.accentColor;

    canvas.drawCircle(c, r, Paint()..color = sea);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = brass
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    for (var i = 0; i < 5; i++) {
      final start = -math.pi / 2 + i * (math.pi * 2 / 5);
      final sweep = math.pi * 2 / 5;
      if (i == index) {
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r - 6),
          start,
          sweep,
          true,
          Paint()..color = VisualTheme.secondaryColor.withValues(alpha: 0.92),
        );
      }
      final mid = start + sweep / 2;
      final labelAt = Offset(c.dx + math.cos(mid) * (r * 0.62), c.dy + math.sin(mid) * (r * 0.62));
      final tp = TextPainter(
        text: TextSpan(
          text: CompassWheel._labels[i],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: i == index ? sand : sand.withValues(alpha: 0.78),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelAt - Offset(tp.width / 2, tp.height / 2));
    }

    canvas.drawCircle(c, 16, Paint()..color = sand);
    canvas.drawCircle(c, 16, Paint()..color = brass..style = PaintingStyle.stroke..strokeWidth = 1.4);
    final needle = Path()
      ..moveTo(c.dx, c.dy - 12)
      ..lineTo(c.dx + 5, c.dy + 4)
      ..lineTo(c.dx, c.dy + 1)
      ..lineTo(c.dx - 5, c.dy + 4)
      ..close();
    canvas.drawPath(needle, Paint()..color = VisualTheme.secondaryColor);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) => old.index != index || old.dark != dark;
}

class GraticulePaper extends StatelessWidget {
  final Widget child;
  const GraticulePaper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _GraticulePainter(dark: dark))),
        child,
      ],
    );
  }
}

class _GraticulePainter extends CustomPainter {
  final bool dark;
  _GraticulePainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dark ? const Color(0x22F4E6CE) : const Color(0x220E4A5A)
      ..strokeWidth = 0.8;
    const step = 28.0;
    for (double x = 18; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 22; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final equator = Paint()
      ..color = dark ? const Color(0x44E07A5F) : const Color(0x33E07A5F)
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(0, size.height * 0.42), Offset(size.width, size.height * 0.42), equator);
  }

  @override
  bool shouldRepaint(covariant _GraticulePainter old) => old.dark != dark;
}

class BearingRow extends StatelessWidget {
  final String bearing;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const BearingRow({
    super.key,
    required this.bearing,
    required this.title,
    required this.meta,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                border: Border.all(color: accent, width: 1.1),
              ),
              child: Text(
                bearing,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: VisualTheme.primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.1)),
                  const SizedBox(height: 2),
                  Text(meta, style: GoogleFonts.outfit(fontSize: 12, height: 1.3)),
                  const SizedBox(height: 8),
                  Container(height: 1, color: accent.withValues(alpha: 0.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LegendLabel extends StatelessWidget {
  final String label;
  const LegendLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: VisualTheme.secondaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: VisualTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
