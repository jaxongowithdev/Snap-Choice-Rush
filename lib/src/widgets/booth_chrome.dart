import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class MarqueeBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const MarqueeBar({super.key, required this.index, required this.onSelect});

  static const _labels = ['HOUSE', 'SCRIPTS', 'CAST', 'CUE', 'LOBBY'];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VisualTheme.velvet,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == index ? VisualTheme.accentColor : const Color(0xFF3A1A22),
                            border: Border.all(
                              color: i == index ? VisualTheme.secondaryColor : const Color(0xFF6A4A28),
                              width: 1.4,
                            ),
                            boxShadow: i == index
                                ? [BoxShadow(color: VisualTheme.accentColor.withValues(alpha: 0.55), blurRadius: 10)]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _labels[i],
                          style: GoogleFonts.cinzel(
                            fontSize: 9,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700,
                            color: i == index ? VisualTheme.accentColor : VisualTheme.cream.withValues(alpha: 0.55),
                          ),
                        ),
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

class VelvetDrape extends StatelessWidget {
  final Widget child;
  const VelvetDrape({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _DrapePainter(dark: dark))),
        child,
      ],
    );
  }
}

class _DrapePainter extends CustomPainter {
  final bool dark;
  _DrapePainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final base = dark ? const Color(0xFF14080C) : const Color(0xFFF3E6C8);
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final fold = Paint()
      ..color = dark ? const Color(0x22D4AF37) : const Color(0x225C1228)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    for (double x = 22; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x + 8, size.height), fold);
    }
    final valance = Paint()..color = dark ? const Color(0x445C1228) : const Color(0x335C1228);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 18), valance);
  }

  @override
  bool shouldRepaint(covariant _DrapePainter old) => old.dark != dark;
}

class PlaybillBlock extends StatelessWidget {
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const PlaybillBlock({
    super.key,
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Container(height: 1, color: accent.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.8),
            ),
            const SizedBox(height: 6),
            Text(
              meta,
              textAlign: TextAlign.center,
              style: GoogleFonts.libreFranklin(fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: accent.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}

class BillLabel extends StatelessWidget {
  final String label;
  const BillLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 11,
            letterSpacing: 2.4,
            fontWeight: FontWeight.w700,
            color: VisualTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
