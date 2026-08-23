import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class BenchRail extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const BenchRail({super.key, required this.index, required this.onSelect});

  static const _items = [
    (Icons.science_outlined, 'BENCH'),
    (Icons.grid_view_outlined, 'RACKS'),
    (Icons.push_pin_outlined, 'PIN'),
    (Icons.swap_horiz, 'LOG'),
    (Icons.tune, 'LAB'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VisualTheme.graphite,
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 22, height: 22, decoration: BoxDecoration(border: Border.all(color: VisualTheme.secondaryColor, width: 2))),
              const Spacer(),
              for (var i = 0; i < _items.length; i++) ...[
                InkWell(
                  onTap: () => onSelect(i),
                  child: SizedBox(
                    width: 68,
                    height: 64,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_items[i].$1, size: 20, color: i == index ? VisualTheme.secondaryColor : Colors.white54),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].$2,
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 8,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w600,
                            color: i == index ? VisualTheme.secondaryColor : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphPaper extends StatelessWidget {
  final Widget child;
  const GraphPaper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final bool dark;
  _GridPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final fine = Paint()
      ..color = dark ? const Color(0x14FFFFFF) : const Color(0x1416181D)
      ..strokeWidth = 0.8;
    final bold = Paint()
      ..color = dark ? const Color(0x22FFFFFF) : const Color(0x2216181D)
      ..strokeWidth = 1;
    const step = 16.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), x % (step * 5) == 0 ? bold : fine);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), y % (step * 5) == 0 ? bold : fine);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.dark != dark;
}

class WellTile extends StatelessWidget {
  final String code;
  final String title;
  final String meta;
  final double fill;
  final VoidCallback onTap;
  const WellTile({
    super.key,
    required this.code,
    required this.title,
    required this.meta,
    required this.fill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Theme.of(context).dividerColor)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(code, style: GoogleFonts.ibmPlexMono(fontSize: 10, color: VisualTheme.primaryColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, height: 1.15)),
              const Spacer(),
              LinearProgressIndicator(value: fill.clamp(0, 1), minHeight: 3, backgroundColor: Theme.of(context).dividerColor, color: VisualTheme.secondaryColor),
              const SizedBox(height: 4),
              Text(meta, style: GoogleFonts.ibmPlexMono(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class LaneChip extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const LaneChip({super.key, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 3)),
          color: Theme.of(context).cardTheme.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.ibmPlexMono(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class SpecLabel extends StatelessWidget {
  final String label;
  const SpecLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(label, style: GoogleFonts.ibmPlexMono(fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w600, color: VisualTheme.primaryColor)),
    );
  }
}
