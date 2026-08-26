import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class DomeStars extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const DomeStars({super.key, required this.index, required this.onSelect});

  static const _labels = ['DOME', 'ROOMS', 'PIN', 'LOG', 'DESK'];
  // Cassiopeia W — uneven heights, not a flat tab bar
  static const _y = [0.52, 0.18, 0.62, 0.22, 0.48];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VisualTheme.voidNavy,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 108,
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final h = box.maxHeight;
              final points = List.generate(5, (i) => Offset(w * (0.10 + i * 0.20), 12 + _y[i] * (h - 40)));
              return Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _ConstellationPainter(points: points, selected: index))),
                  for (var i = 0; i < 5; i++)
                    Positioned(
                      left: points[i].dx - 28,
                      top: points[i].dy - 8,
                      width: 56,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSelect(i),
                        child: Column(
                          children: [
                            const SizedBox(height: 18),
                            Text(
                              _labels[i],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                fontSize: 9,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                                color: i == index ? VisualTheme.secondaryColor : VisualTheme.chart.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  final List<Offset> points;
  final int selected;
  _ConstellationPainter({required this.points, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = VisualTheme.secondaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], line);
    }
    for (var i = 0; i < points.length; i++) {
      final on = i == selected;
      if (on) {
        canvas.drawCircle(points[i], 14, Paint()..color = VisualTheme.secondaryColor.withValues(alpha: 0.22));
      }
      canvas.drawCircle(points[i], on ? 6.5 : 4.2, Paint()..color = on ? VisualTheme.secondaryColor : VisualTheme.chart);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) => old.selected != selected || old.points.length != points.length;
}

class StarField extends StatelessWidget {
  final Widget child;
  const StarField({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _StarFieldPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final bool dark;
  _StarFieldPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = dark ? VisualTheme.night : VisualTheme.chart);
    final rnd = Random(42);
    final star = Paint()..color = dark ? VisualTheme.chart.withValues(alpha: 0.55) : VisualTheme.voidNavy.withValues(alpha: 0.18);
    for (var i = 0; i < 70; i++) {
      canvas.drawCircle(Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height), rnd.nextDouble() * 1.4 + 0.4, star);
    }
    final grid = Paint()
      ..color = dark ? const Color(0x14E8C547) : const Color(0x226B4C9A)
      ..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter old) => old.dark != dark;
}

class StarPlate extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const StarPlate({
    super.key,
    required this.kind,
    required this.title,
    required this.meta,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1A1630) : const Color(0xFFF4F0FA),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              CustomPaint(size: const Size(36, 36), painter: _MiniConstellation(color: accent)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kind.toUpperCase(), style: GoogleFonts.cinzel(fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w700, color: accent)),
                    const SizedBox(height: 4),
                    Text(title, style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, height: 1.2)),
                    const SizedBox(height: 4),
                    Text(meta, style: GoogleFonts.spaceGrotesk(fontSize: 13, height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniConstellation extends CustomPainter {
  final Color color;
  _MiniConstellation({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final pts = [
      Offset(size.width * 0.15, size.height * 0.55),
      Offset(size.width * 0.38, size.height * 0.22),
      Offset(size.width * 0.55, size.height * 0.62),
      Offset(size.width * 0.78, size.height * 0.28),
      Offset(size.width * 0.92, size.height * 0.58),
    ];
    final line = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var i = 0; i < pts.length - 1; i++) {
      canvas.drawLine(pts[i], pts[i + 1], line);
    }
    for (final p in pts) {
      canvas.drawCircle(p, 2.2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniConstellation old) => old.color != color;
}

class PlanetOrb extends StatelessWidget {
  final String title;
  final String meta;
  final Color accent;
  final double size;
  final bool ring;
  final VoidCallback onTap;
  const PlanetOrb({
    super.key,
    required this.title,
    required this.meta,
    required this.accent,
    required this.size,
    required this.ring,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + 8,
        child: Column(
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(painter: _OrbPainter(color: accent, ring: ring)),
            ),
            const SizedBox(height: 6),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: GoogleFonts.cinzel(fontSize: 11, fontWeight: FontWeight.w700)),
            Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final Color color;
  final bool ring;
  _OrbPainter({required this.color, required this.ring});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width * 0.36, Paint()..color = color);
    canvas.drawCircle(Offset(c.dx - size.width * 0.1, c.dy - size.height * 0.08), size.width * 0.08, Paint()..color = Colors.white.withValues(alpha: 0.28));
    if (ring) {
      final r = Paint()
        ..color = VisualTheme.secondaryColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(-0.35);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: size.width * 0.92, height: size.height * 0.28), r);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => old.color != color || old.ring != ring;
}

class SkyStamp extends StatelessWidget {
  final String label;
  const SkyStamp({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: VisualTheme.secondaryColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, style: GoogleFonts.cinzel(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700, color: VisualTheme.primaryColor)),
        ),
      ),
    );
  }
}
