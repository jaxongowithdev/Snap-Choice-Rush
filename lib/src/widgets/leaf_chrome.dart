import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class RibbonRail extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const RibbonRail({super.key, required this.index, required this.onSelect});

  static const _labels = ['TRAIL', 'PRESSES', 'PIN', 'LOG', 'CAMP'];
  static const _colors = [
    Color(0xFF3D5A3A),
    Color(0xFFB85C38),
    Color(0xFFC6A45A),
    Color(0xFF8FA36A),
    Color(0xFF5A3A28),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VisualTheme.bark,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 10, color: const Color(0xFF4A3424)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < 5; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onSelect(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: i == index ? 64 : 46,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _colors[i],
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.22), offset: const Offset(0, 3), blurRadius: 3),
                            ],
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _labels[i],
                            style: GoogleFonts.nunitoSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: i == index ? Colors.white : Colors.white.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FieldPaper extends StatelessWidget {
  final Widget child;
  const FieldPaper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _LeafPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _LeafPainter extends CustomPainter {
  final bool dark;
  _LeafPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = dark ? VisualTheme.night : VisualTheme.cream);
    final vein = Paint()
      ..color = dark ? const Color(0x223D5A3A) : const Color(0x333D5A3A)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 6; i++) {
      final cx = size.width * (0.12 + (i % 3) * 0.32);
      final cy = 80.0 + i * 110;
      final path = Path()
        ..moveTo(cx, cy)
        ..quadraticBezierTo(cx + 28, cy + 18, cx + 8, cy + 52)
        ..quadraticBezierTo(cx - 18, cy + 22, cx, cy);
      canvas.drawPath(path, vein);
    }
    final dash = Paint()
      ..color = dark ? const Color(0x22B85C38) : const Color(0x22B85C38)
      ..strokeWidth = 0.8;
    for (double y = 48; y < size.height; y += 64) {
      var x = 16.0;
      while (x < size.width - 16) {
        canvas.drawLine(Offset(x, y), Offset(x + 8, y), dash);
        x += 16;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LeafPainter old) => old.dark != dark;
}

class SpecimenCard extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const SpecimenCard({
    super.key,
    required this.kind,
    required this.title,
    required this.meta,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xEE1C1812) : const Color(0xF2F7F1E4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              CustomPaint(
                size: const Size(36, 48),
                painter: _MiniLeafPainter(color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kind.toUpperCase(), style: GoogleFonts.nunitoSans(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800, color: accent)),
                    const SizedBox(height: 4),
                    Text(title, style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, height: 1.15)),
                    const SizedBox(height: 4),
                    Text(meta, style: GoogleFonts.nunitoSans(fontSize: 12, height: 1.35)),
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

class _MiniLeafPainter extends CustomPainter {
  final Color color;
  _MiniLeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, 2)
      ..quadraticBezierTo(size.width, size.height * 0.35, size.width * 0.55, size.height - 2)
      ..quadraticBezierTo(0, size.height * 0.35, size.width * 0.5, 2);
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.85));
    canvas.drawLine(
      Offset(size.width * 0.5, 4),
      Offset(size.width * 0.5, size.height - 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniLeafPainter old) => old.color != color;
}

class TrailLabel extends StatelessWidget {
  final String label;
  const TrailLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Transform.rotate(
            angle: math.pi / 10,
            child: Container(width: 10, height: 18, color: VisualTheme.secondaryColor),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.nunitoSans(fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: VisualTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}
