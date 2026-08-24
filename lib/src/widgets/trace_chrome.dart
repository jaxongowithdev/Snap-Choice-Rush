import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class BoardTools extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const BoardTools({super.key, required this.index, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VisualTheme.primaryColor,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 118,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: _tool(
                  selected: index == 0,
                  onTap: () => onSelect(0),
                  child: Container(
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index == 0 ? VisualTheme.cyan : const Color(0xFFD8D4CC),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: Text('SHEET', style: _label(index == 0)),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 34,
                child: _tool(
                  selected: index == 1,
                  onTap: () => onSelect(1),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      children: [
                        CustomPaint(size: const Size(72, 72), painter: _TrianglePainter(fill: index == 1 ? VisualTheme.cyan : const Color(0xFFC8C4B8))),
                        Positioned(left: 8, bottom: 6, child: Text('SETS', style: _label(index == 1))),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 86,
                bottom: 28,
                child: _tool(
                  selected: index == 2,
                  onTap: () => onSelect(2),
                  child: Transform.rotate(
                    angle: -0.35,
                    child: SizedBox(
                      width: 64,
                      height: 78,
                      child: Stack(
                        children: [
                          CustomPaint(size: const Size(64, 78), painter: _TrianglePainter(fill: index == 2 ? VisualTheme.accentColor : const Color(0xFFB8B4A8))),
                          Positioned(left: 6, bottom: 8, child: Text('PIN', style: _label(index == 2))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 78,
                bottom: 36,
                child: _tool(
                  selected: index == 3,
                  onTap: () => onSelect(3),
                  child: Transform.rotate(
                    angle: 0.18,
                    child: Container(
                      width: 92,
                      height: 20,
                      alignment: Alignment.center,
                      color: index == 3 ? VisualTheme.cyan : const Color(0xFFD0CCBE),
                      child: Text('LOG', style: _label(index == 3)),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 32,
                child: _tool(
                  selected: index == 4,
                  onTap: () => onSelect(4),
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: index == 4 ? VisualTheme.cyan : const Color(0xFFD0CCBE), width: 4),
                      color: VisualTheme.primaryColor,
                    ),
                    child: Text('DESK', style: _label(index == 4)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tool({required bool selected, required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(duration: const Duration(milliseconds: 160), opacity: selected ? 1 : 0.72, child: child),
    );
  }

  TextStyle _label(bool on) => GoogleFonts.barlowCondensed(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: on ? VisualTheme.ink : VisualTheme.primaryColor,
      );
}

class _TrianglePainter extends CustomPainter {
  final Color fill;
  _TrianglePainter({required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = VisualTheme.ink.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.fill != fill;
}

class Blueprint extends StatelessWidget {
  final Widget child;
  const Blueprint({super.key, required this.child});

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
    canvas.drawRect(Offset.zero & size, Paint()..color = dark ? VisualTheme.night : VisualTheme.vellum);
    final minor = Paint()
      ..color = dark ? const Color(0x227EC8E3) : const Color(0x220E3A6B)
      ..strokeWidth = 0.6;
    final major = Paint()
      ..color = dark ? const Color(0x447EC8E3) : const Color(0x330E3A6B)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), x % 60 == 0 ? major : minor);
    }
    for (double y = 0; y < size.height; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), y % 60 == 0 ? major : minor);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.dark != dark;
}

class DrawingPlate extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const DrawingPlate({
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
        child: CustomPaint(
          painter: _CropPainter(color: dark ? VisualTheme.cyan : VisualTheme.primaryColor),
          child: Container(
            margin: const EdgeInsets.all(6),
            color: dark ? const Color(0xFF102848) : VisualTheme.plate,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kind.toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700, color: accent)),
                const SizedBox(height: 6),
                Text(title, style: GoogleFonts.sourceSerif4(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15)),
                const SizedBox(height: 8),
                Container(height: 1, color: dark ? const Color(0x337EC8E3) : const Color(0x330E3A6B)),
                const SizedBox(height: 8),
                Text(meta, style: GoogleFonts.barlowCondensed(fontSize: 13, letterSpacing: 0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  final Color color;
  _CropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const l = 10.0;
    canvas.drawLine(const Offset(0, 0), const Offset(l, 0), p);
    canvas.drawLine(const Offset(0, 0), const Offset(0, l), p);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - l, 0), p);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, l), p);
    canvas.drawLine(Offset(0, size.height), Offset(l, size.height), p);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - l), p);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - l, size.height), p);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - l), p);
  }

  @override
  bool shouldRepaint(covariant _CropPainter old) => old.color != color;
}

class TitleBlock extends StatelessWidget {
  final String project;
  final String note;
  const TitleBlock({super.key, required this.project, required this.note});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: dark ? VisualTheme.cyan : VisualTheme.primaryColor, width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: dark ? VisualTheme.deep : VisualTheme.primaryColor,
            child: Text(project, style: GoogleFonts.barlowCondensed(fontSize: 18, letterSpacing: 1.6, fontWeight: FontWeight.w700, color: VisualTheme.vellum)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Text(note, style: GoogleFonts.sourceSerif4(fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class SheetStamp extends StatelessWidget {
  final String label;
  const SheetStamp({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.barlowCondensed(fontSize: 13, letterSpacing: 2.4, fontWeight: FontWeight.w700, color: VisualTheme.primaryColor),
      ),
    );
  }
}
