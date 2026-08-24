import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class TanzakuRail extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const TanzakuRail({super.key, required this.index, required this.onSelect});

  static const _labels = ['ROOM', 'FOLIO', 'SEAL', 'PASS', 'DESK'];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? const Color(0xFF2A241C) : VisualTheme.rod,
      child: SafeArea(
        left: false,
        child: SizedBox(
          width: 58,
          child: Column(
            children: [
              Container(
                height: 12,
                margin: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF8A7058) : const Color(0xFF9A7A58),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
                  child: Column(
                    children: [
                      for (var i = 0; i < 5; i++) ...[
                        if (i > 0) const SizedBox(height: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onSelect(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: double.infinity,
                              transform: Matrix4.translationValues(i == index ? -4 : 0, 0, 0),
                              decoration: BoxDecoration(
                                color: i == index
                                    ? (dark ? VisualTheme.primaryColor : VisualTheme.washi)
                                    : (dark ? const Color(0xFF3A3228) : const Color(0xFFF7F2E8)),
                                border: Border.all(color: VisualTheme.ink.withValues(alpha: 0.18)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    offset: const Offset(1, 2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (final ch in _labels[i].split(''))
                                      Text(
                                        ch,
                                        style: GoogleFonts.figtree(
                                          fontSize: 10,
                                          height: 1.15,
                                          fontWeight: FontWeight.w800,
                                          color: i == index
                                              ? (dark ? VisualTheme.washi : VisualTheme.primaryColor)
                                              : VisualTheme.ink.withValues(alpha: dark ? 0.7 : 0.72),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WashiPaper extends StatelessWidget {
  final Widget child;
  const WashiPaper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _WashiPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _WashiPainter extends CustomPainter {
  final bool dark;
  _WashiPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(11);
    final fiber = Paint()
      ..color = dark ? const Color(0x18F4EFE4) : const Color(0x221B1814)
      ..strokeWidth = 0.7;
    for (var i = 0; i < 90; i++) {
      final y = rnd.nextDouble() * size.height;
      final x = rnd.nextDouble() * size.width;
      final len = 18 + rnd.nextDouble() * 48;
      canvas.drawLine(Offset(x, y), Offset(x + len, y + (rnd.nextDouble() - 0.5) * 4), fiber);
    }
    final wash = Paint()
      ..color = dark ? const Color(0x08C23A2C) : const Color(0x0AC23A2C)
      ..strokeWidth = 1.1;
    for (double y = 40; y < size.height; y += 72) {
      canvas.drawLine(Offset(12, y), Offset(size.width * 0.72, y), wash);
    }
  }

  @override
  bool shouldRepaint(covariant _WashiPainter old) => old.dark != dark;
}

class CoupletCard extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const CoupletCard({
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
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: VisualTheme.washi.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.08 : 0.72),
            border: Border(left: BorderSide(color: accent, width: 3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kind.toUpperCase(), style: GoogleFonts.figtree(fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w700, color: accent)),
                    const SizedBox(height: 4),
                    Text(title, style: GoogleFonts.spectral(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15)),
                    const SizedBox(height: 4),
                    Text(meta, style: GoogleFonts.figtree(fontSize: 12, height: 1.35)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: VisualTheme.primaryColor, width: 1.4),
                ),
                child: Text('印', style: GoogleFonts.spectral(fontSize: 11, color: VisualTheme.primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SealLabel extends StatelessWidget {
  final String label;
  const SealLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: VisualTheme.primaryColor.withValues(alpha: 0.12),
              border: Border.all(color: VisualTheme.primaryColor),
            ),
            child: Text('印', style: GoogleFonts.spectral(fontSize: 8, color: VisualTheme.primaryColor)),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.figtree(fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w700, color: VisualTheme.secondaryColor),
          ),
        ],
      ),
    );
  }
}
