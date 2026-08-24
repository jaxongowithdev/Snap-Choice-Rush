import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class CatalogDrawers extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const CatalogDrawers({super.key, required this.index, required this.onSelect});

  static const _labels = ['NOOK', 'BINS', 'FLAG', 'LOG', 'DESK'];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? const Color(0xFF3A2E22) : const Color(0xFF8A6A42),
      child: SafeArea(
        left: false,
        child: SizedBox(
          width: 86,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 10, 8, 10),
            child: Column(
              children: [
                for (var i = 0; i < 5; i++) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onSelect(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: EdgeInsets.only(right: i == index ? 10 : 0, bottom: 6),
                        decoration: BoxDecoration(
                          color: i == index ? VisualTheme.manila : const Color(0xFF2C4A3C),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.28), offset: Offset(i == index ? -3 : 0, 2), blurRadius: 2),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 8,
                              right: 8,
                              top: 8,
                              child: Text(
                                _labels[i],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: i == index ? VisualTheme.ink : VisualTheme.paper),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == index ? VisualTheme.accentColor : const Color(0xFFC4A574),
                                  border: Border.all(color: const Color(0xFF5A3F28), width: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryWall extends StatelessWidget {
  final Widget child;
  const LibraryWall({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _SlatPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _SlatPainter extends CustomPainter {
  final bool dark;
  _SlatPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = dark ? VisualTheme.night : VisualTheme.paper);
    final slat = Paint()..color = dark ? const Color(0x14C4A35A) : const Color(0x22C4A574);
    for (double y = 0; y < size.height; y += 18) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.2), slat);
    }
  }

  @override
  bool shouldRepaint(covariant _SlatPainter old) => old.dark != dark;
}

class CheckoutCard extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const CheckoutCard({
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
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: dark ? const Color(0xFF2A241C) : VisualTheme.manila,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, color: accent),
                  const SizedBox(width: 8),
                  Text(kind.toUpperCase(), style: GoogleFonts.outfit(fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w800, color: VisualTheme.secondaryColor)),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(3, (i) => Container(height: 1, margin: const EdgeInsets.only(bottom: 7), color: VisualTheme.ink.withValues(alpha: 0.12))),
              Text(title, style: GoogleFonts.libreBaskerville(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2)),
              const SizedBox(height: 6),
              Text(meta, style: GoogleFonts.outfit(fontSize: 12, height: 1.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class BookSpine extends StatelessWidget {
  final String title;
  final String meta;
  final Color accent;
  final double height;
  final VoidCallback onTap;
  const BookSpine({
    super.key,
    required this.title,
    required this.meta,
    required this.accent,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: height,
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        decoration: BoxDecoration(
          color: accent,
          boxShadow: const [BoxShadow(color: Color(0x33000000), offset: Offset(1, 1), blurRadius: 0)],
        ),
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            meta.isEmpty ? title : '$title  ·  $meta',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.libreBaskerville(fontSize: 11, fontWeight: FontWeight.w700, color: accent.computeLuminance() > 0.5 ? VisualTheme.ink : VisualTheme.paper),
          ),
        ),
      ),
    );
  }
}

class PocketLabel extends StatelessWidget {
  final String label;
  const PocketLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          color: VisualTheme.secondaryColor,
          child: Text(label, style: GoogleFonts.outfit(fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w800, color: VisualTheme.paper)),
        ),
      ),
    );
  }
}
