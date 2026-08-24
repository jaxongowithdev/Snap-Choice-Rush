import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class TrackLanes extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const TrackLanes({super.key, required this.index, required this.onSelect});

  static const _labels = ['YARD', 'CAGES', 'STAR', 'LOG', 'DESK'];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? const Color(0xFF6E2422) : VisualTheme.track,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 86,
          child: Row(
            children: [
              for (var i = 0; i < 5; i++) ...[
                if (i > 0) Container(width: 3, color: Colors.white.withValues(alpha: 0.85)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      color: i == index ? const Color(0xFF9C2E2A) : Colors.transparent,
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          CustomPaint(
                            size: const Size(18, 10),
                            painter: _BlockPainter(on: i == index),
                          ),
                          Text(
                            '${i + 1}',
                            style: GoogleFonts.oswald(fontSize: 18, height: 1, fontWeight: FontWeight.w700, color: i == index ? VisualTheme.accentColor : Colors.white),
                          ),
                          Text(
                            _labels[i],
                            style: GoogleFonts.oswald(fontSize: 11, letterSpacing: 0.8, color: Colors.white.withValues(alpha: i == index ? 1 : 0.75)),
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
    );
  }
}

class _BlockPainter extends CustomPainter {
  final bool on;
  _BlockPainter({required this.on});

  @override
  void paint(Canvas canvas, Size size) {
    if (!on) return;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.28, 0)
      ..lineTo(size.width * 0.72, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = VisualTheme.accentColor);
  }

  @override
  bool shouldRepaint(covariant _BlockPainter old) => old.on != on;
}

class GymFloor extends StatelessWidget {
  final Widget child;
  const GymFloor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _CourtPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _CourtPainter extends CustomPainter {
  final bool dark;
  _CourtPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = dark ? VisualTheme.night : VisualTheme.maple);
    final plank = Paint()..color = dark ? const Color(0x14C4D63A) : const Color(0x33C9924A);
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.4), plank);
    }
    final line = Paint()
      ..color = dark ? const Color(0x55FFFFFF) : Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(size.width * 0.82, 88), 54, line);
    canvas.drawLine(Offset(size.width * 0.82 - 54, 88), Offset(size.width * 0.82 + 54, 88), line);
    canvas.drawRect(Rect.fromLTWH(12, 12, size.width - 24, size.height - 24), line);
  }

  @override
  bool shouldRepaint(covariant _CourtPainter old) => old.dark != dark;
}

class ClipboardCard extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const ClipboardCard({
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
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1C2836) : const Color(0xFFF7F1E4),
                borderRadius: const BorderRadius.only(topRight: Radius.circular(22), bottomLeft: Radius.circular(22)),
                border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kind.toUpperCase(), style: GoogleFonts.oswald(fontSize: 12, letterSpacing: 1.8, color: accent)),
                  const SizedBox(height: 6),
                  Text(title, style: GoogleFonts.oswald(fontSize: 22, height: 1.15)),
                  const SizedBox(height: 4),
                  Text(meta, style: GoogleFonts.karla(fontSize: 13, height: 1.35)),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 28,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF8A8F96),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StationCone extends StatelessWidget {
  final String title;
  final String meta;
  final Color accent;
  final double height;
  final VoidCallback onTap;
  const StationCone({
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
      child: SizedBox(
        width: 64,
        height: height + 28,
        child: Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: Size(54, height),
                painter: _ConePainter(color: accent),
              ),
            ),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.oswald(fontSize: 11, letterSpacing: 0.4)),
            Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.karla(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ConePainter extends CustomPainter {
  final Color color;
  _ConePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, 4)
      ..lineTo(size.width - 2, size.height)
      ..lineTo(2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.18, size.height * 0.42, size.width * 0.64, 8), Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(covariant _ConePainter old) => old.color != color;
}

class LaneStamp extends StatelessWidget {
  final String label;
  const LaneStamp({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: const BoxDecoration(
            color: VisualTheme.primaryColor,
            borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
          ),
          child: Text(label, style: GoogleFonts.oswald(fontSize: 12, letterSpacing: 1.8, color: VisualTheme.court)),
        ),
      ),
    );
  }
}
