import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class CubbyNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const CubbyNav({super.key, required this.index, required this.onSelect});

  static const _labels = ['RUG', 'BINS', 'STAR', 'LOG', 'OFFICE'];
  static const _colors = [
    Color(0xFF4A90C8),
    Color(0xFFE24B3D),
    Color(0xFFF0C020),
    Color(0xFF7B5EA7),
    Color(0xFF5AAB5A),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? const Color(0xFF3A2E22) : const Color(0xFFC9955C),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: _hole(0, tall: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _hole(1, tall: true)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _hole(2, tall: false)),
                  const SizedBox(width: 8),
                  Expanded(child: _hole(3, tall: false)),
                  const SizedBox(width: 8),
                  Expanded(child: _hole(4, tall: false)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hole(int i, {required bool tall}) {
    final selected = i == index;
    return GestureDetector(
      onTap: () => onSelect(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: tall ? (selected ? 70 : 62) : (selected ? 58 : 50),
        decoration: BoxDecoration(
          color: const Color(0xFF5A3F28),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 2)],
        ),
        padding: const EdgeInsets.fromLTRB(5, 6, 5, 5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _colors[i],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3), bottom: Radius.circular(10)),
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: selected ? VisualTheme.label : VisualTheme.label.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _labels[i],
              style: GoogleFonts.fredoka(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: selected ? VisualTheme.ink : VisualTheme.ink.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CorkWall extends StatelessWidget {
  final Widget child;
  const CorkWall({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _CorkPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _CorkPainter extends CustomPainter {
  final bool dark;
  _CorkPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = dark ? VisualTheme.night : VisualTheme.wall);
    final pin = Paint()..color = dark ? const Color(0x33F0C020) : const Color(0x55E24B3D);
    final rnd = math.Random(7);
    for (var i = 0; i < 18; i++) {
      final x = 18.0 + rnd.nextDouble() * (size.width - 36);
      final y = 40.0 + rnd.nextDouble() * (size.height - 80);
      canvas.drawCircle(Offset(x, y), 3.2, pin);
    }
    final tape = Paint()..color = dark ? const Color(0x224A90C8) : const Color(0x334A90C8);
    canvas.drawRect(const Rect.fromLTWH(12, 24, 42, 10), tape);
    canvas.drawRect(Rect.fromLTWH(size.width - 54, 88, 42, 10), tape);
  }

  @override
  bool shouldRepaint(covariant _CorkPainter old) => old.dark != dark;
}

class ToteCard extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const ToteCard({
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
    final fg = accent.computeLuminance() > 0.55 ? VisualTheme.ink : VisualTheme.label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF3A2E22) : const Color(0xFFC9955C),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(6),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(color: VisualTheme.label, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    kind.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(fontSize: 9, fontWeight: FontWeight.w600, color: VisualTheme.ink, height: 1.15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.literata(fontSize: 20, fontWeight: FontWeight.w700, color: fg, height: 1.15)),
                      const SizedBox(height: 4),
                      Text(meta, style: GoogleFonts.fredoka(fontSize: 12, color: fg.withValues(alpha: 0.9))),
                    ],
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

class CenterTile extends StatelessWidget {
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const CenterTile({super.key, required this.title, required this.meta, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg = accent.computeLuminance() > 0.55 ? VisualTheme.ink : VisualTheme.label;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF5A3F28),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3), bottom: Radius.circular(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: VisualTheme.label, borderRadius: BorderRadius.circular(4)),
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w600, color: VisualTheme.ink)),
              ),
              const Spacer(),
              Text(meta, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.fredoka(fontSize: 11, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class NameTag extends StatelessWidget {
  final String label;
  const NameTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: VisualTheme.label,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: VisualTheme.secondaryColor, width: 1.4),
            boxShadow: const [BoxShadow(color: Color(0x22000000), offset: Offset(1, 2), blurRadius: 0)],
          ),
          child: Text(label, style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: VisualTheme.ink)),
        ),
      ),
    );
  }
}
