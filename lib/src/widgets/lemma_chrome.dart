import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class CardFanDock extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const CardFanDock({super.key, required this.index, required this.onSelect});

  static const _labels = ['DECK', 'BOXES', 'PIN', 'SHIFT', 'LID'];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? VisualTheme.night : const Color(0xFFE8D9A8),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 102,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 5; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onSelect(i),
                      child: Transform.rotate(
                        angle: (i - 2) * 0.07,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: i == index ? 90 : 72,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == index
                                ? (dark ? VisualTheme.primaryColor : VisualTheme.paper)
                                : (dark ? const Color(0xFF243040) : VisualTheme.manila),
                            border: Border(
                              left: BorderSide(color: VisualTheme.secondaryColor, width: i == index ? 4 : 3),
                              top: BorderSide(color: VisualTheme.ink.withValues(alpha: 0.12)),
                              right: BorderSide(color: VisualTheme.ink.withValues(alpha: 0.12)),
                              bottom: BorderSide(color: VisualTheme.ink.withValues(alpha: 0.12)),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                offset: const Offset(1, 3),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _labels[i],
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: i == index
                                  ? (dark ? VisualTheme.paper : VisualTheme.primaryColor)
                                  : VisualTheme.ink.withValues(alpha: dark ? 0.75 : 0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IndexPaper extends StatelessWidget {
  final Widget child;
  const IndexPaper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _IndexPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _IndexPainter extends CustomPainter {
  final bool dark;
  _IndexPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = dark ? VisualTheme.night : VisualTheme.manila);
    final rules = Paint()
      ..color = dark ? const Color(0x337BA3C9) : const Color(0x667BA3C9)
      ..strokeWidth = 1;
    for (double y = 36; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rules);
    }
    final margin = Paint()
      ..color = dark ? const Color(0x66C44536) : const Color(0xAAC44536)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(28, 0), Offset(28, size.height), margin);
  }

  @override
  bool shouldRepaint(covariant _IndexPainter old) => old.dark != dark;
}

class FlashTile extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const FlashTile({
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
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: dark ? const Color(0xEE243040) : VisualTheme.paper,
            border: Border(
              left: BorderSide(color: accent, width: 4),
              top: BorderSide(color: VisualTheme.ink.withValues(alpha: 0.08)),
              right: BorderSide(color: VisualTheme.ink.withValues(alpha: 0.08)),
              bottom: BorderSide(color: VisualTheme.ink.withValues(alpha: 0.08)),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), offset: const Offset(2, 3), blurRadius: 2),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kind.toUpperCase(), style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: accent)),
              const SizedBox(height: 6),
              Text(title, style: GoogleFonts.literata(fontSize: 24, fontWeight: FontWeight.w700, height: 1.15)),
              const SizedBox(height: 6),
              Text(meta, style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, height: 1.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class DeckLabel extends StatelessWidget {
  final String label;
  const DeckLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8),
      child: Text(
        label,
        style: GoogleFonts.atkinsonHyperlegible(
          fontSize: 12,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w800,
          color: VisualTheme.primaryColor,
        ),
      ),
    );
  }
}
