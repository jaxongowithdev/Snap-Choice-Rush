import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class TrayDock extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const TrayDock({super.key, required this.index, required this.onSelect});

  static const _labels = ['GATE', 'TRAYS', 'HOLD', 'LOG', 'LAMP'];
  static const _liquids = [
    Color(0xFFE8943A),
    Color(0xFFC9B48A),
    Color(0xFF8FA3A8),
    Color(0xFF5A6A4A),
    Color(0xFF3A322C),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VisualTheme.fog,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 96,
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final trayW = w / 4.15;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < 5; i++)
                    Positioned(
                      left: 6.0 + i * ((w - trayW - 12) / 4),
                      bottom: i == index ? 14 : 6,
                      width: trayW,
                      child: GestureDetector(
                        onTap: () => onSelect(i),
                        child: _Tray(
                          label: _labels[i],
                          liquid: _liquids[i],
                          selected: i == index,
                          tilt: (i - 2) * 0.03,
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

class _Tray extends StatelessWidget {
  final String label;
  final Color liquid;
  final bool selected;
  final double tilt;
  const _Tray({required this.label, required this.liquid, required this.selected, required this.tilt});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: selected ? 78 : 62,
        decoration: BoxDecoration(
          color: const Color(0xFF6A6560),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: selected ? 0.5 : 0.28), offset: const Offset(0, 4), blurRadius: 6),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 6),
        child: Container(
          decoration: BoxDecoration(
            color: liquid.withValues(alpha: selected ? 0.95 : 0.72),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: selected ? VisualTheme.fog : VisualTheme.fog.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class Safelight extends StatelessWidget {
  final Widget child;
  const Safelight({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _GrainPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  final bool dark;
  _GrainPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = dark ? VisualTheme.fog : VisualTheme.paper);
    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.7, -0.85),
        radius: 1.15,
        colors: [
          dark ? const Color(0x55E8943A) : const Color(0x22E8943A),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glow);
    final rnd = math.Random(11);
    final speck = Paint()..color = dark ? const Color(0x14EDE8DC) : const Color(0x140C0A08);
    for (var i = 0; i < 90; i++) {
      canvas.drawCircle(Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height), 0.7, speck);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => old.dark != dark;
}

class ContactSheet extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const ContactSheet({
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
    final fg = accent.computeLuminance() > 0.55 ? VisualTheme.ink : VisualTheme.print;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: dark ? const Color(0xFF1A1612) : VisualTheme.print,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < 8; i++) ...[
                    Container(width: 7, height: 7, decoration: BoxDecoration(border: Border.all(color: VisualTheme.ink.withValues(alpha: 0.35)))),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        height: 44,
                        margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                        color: i == 1 ? accent.withValues(alpha: 0.85) : (dark ? const Color(0xFF2A2420) : const Color(0xFFD8D0C4)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(kind.toUpperCase(), style: GoogleFonts.ibmPlexMono(fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w600, color: VisualTheme.primaryColor)),
              const SizedBox(height: 4),
              Text(title, style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: fg == VisualTheme.print ? (dark ? VisualTheme.print : VisualTheme.ink) : VisualTheme.ink)),
              const SizedBox(height: 4),
              Text(meta, style: GoogleFonts.ibmPlexMono(fontSize: 11, height: 1.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class FilmFrame extends StatelessWidget {
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const FilmFrame({super.key, required this.title, required this.meta, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 132,
        margin: const EdgeInsets.only(right: 8),
        color: VisualTheme.fog,
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (_) => Container(width: 6, height: 6, color: const Color(0xFF3A342E))),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: accent,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8),
                child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.ibmPlexMono(fontSize: 11, fontWeight: FontWeight.w600, color: accent.computeLuminance() > 0.55 ? VisualTheme.ink : VisualTheme.print)),
              ),
            ),
            Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.ibmPlexMono(fontSize: 9, color: VisualTheme.hypo)),
          ],
        ),
      ),
    );
  }
}

class TimerStamp extends StatelessWidget {
  final String label;
  const TimerStamp({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 2.2, fontWeight: FontWeight.w600, color: VisualTheme.primaryColor),
      ),
    );
  }
}
