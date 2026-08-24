import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class SpineNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const SpineNav({super.key, required this.index, required this.onSelect});

  static const _labels = ['HALL', 'STACKS', 'PIN', 'LOG', 'CRYPT'];
  static const _stops = [0.08, 0.26, 0.48, 0.68, 0.86];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? const Color(0xFF1A1612) : const Color(0xFFE4D8C0),
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: 78,
          child: LayoutBuilder(
            builder: (context, box) {
              return Stack(
                children: [
                  Positioned(
                    left: 36,
                    top: 12,
                    bottom: 12,
                    child: Container(width: 2, color: VisualTheme.primaryColor),
                  ),
                  for (var i = 0; i < 5; i++)
                    Positioned(
                      top: box.maxHeight * _stops[i],
                      left: i.isEven ? 6 : 18,
                      child: GestureDetector(
                        onTap: () => onSelect(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(horizontal: i == index ? 8 : 6, vertical: i == index ? 8 : 5),
                          decoration: BoxDecoration(
                            color: i == index ? VisualTheme.primaryColor : VisualTheme.plaque,
                            border: Border.all(color: VisualTheme.secondaryColor, width: i == index ? 1.6 : 0.8),
                            boxShadow: i == index
                                ? const [BoxShadow(color: Color(0x33000000), offset: Offset(2, 2), blurRadius: 0)]
                                : null,
                          ),
                          child: Text(
                            _labels[i],
                            style: GoogleFonts.publicSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: i == index ? VisualTheme.parchment : VisualTheme.ink,
                            ),
                          ),
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

class GalleryWall extends StatelessWidget {
  final Widget child;
  const GalleryWall({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _WallPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _WallPainter extends CustomPainter {
  final bool dark;
  _WallPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = dark ? VisualTheme.night : VisualTheme.parchment);
    final rule = Paint()
      ..color = dark ? const Color(0x14C4A35A) : const Color(0x228B2E2E)
      ..strokeWidth = 1;
    for (double y = 48; y < size.height; y += 56) {
      canvas.drawLine(Offset(24, y), Offset(size.width - 24, y), rule);
    }
    final thread = Paint()
      ..color = dark ? const Color(0x44C4A35A) : const Color(0x338B2E2E)
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(size.width - 28, 20), Offset(size.width - 28, size.height - 20), thread);
  }

  @override
  bool shouldRepaint(covariant _WallPainter old) => old.dark != dark;
}

class ExhibitPlaque extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  final bool offsetRight;
  const ExhibitPlaque({
    super.key,
    required this.kind,
    required this.title,
    required this.meta,
    required this.accent,
    required this.onTap,
    this.offsetRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 16, left: offsetRight ? 28 : 0, right: offsetRight ? 0 : 28),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF221E1A) : VisualTheme.plaque,
            border: Border(left: BorderSide(color: accent, width: 4)),
            boxShadow: const [BoxShadow(color: Color(0x14000000), offset: Offset(2, 3), blurRadius: 0)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kind.toUpperCase(), style: GoogleFonts.publicSans(fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: accent)),
              const SizedBox(height: 6),
              Text(title, style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, height: 1.15)),
              const SizedBox(height: 6),
              Text(meta, style: GoogleFonts.publicSans(fontSize: 12, height: 1.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class AccessionLabel extends StatelessWidget {
  final String label;
  const AccessionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        children: [
          Container(width: 18, height: 2, color: VisualTheme.primaryColor),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.publicSans(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800, color: VisualTheme.primaryColor)),
        ],
      ),
    );
  }
}
