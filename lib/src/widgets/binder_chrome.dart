import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class BinderShell extends StatelessWidget {
  final Widget child;
  const BinderShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 28,
          color: VisualTheme.primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (_) => Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? VisualTheme.night : VisualTheme.paper,
                border: Border.all(color: VisualTheme.accentColor, width: 2),
              ),
            )),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _RulePainter(dark: dark))),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class _RulePainter extends CustomPainter {
  final bool dark;
  _RulePainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dark ? const Color(0x22F4EFE4) : const Color(0x2215233B)
      ..strokeWidth = 1;
    for (double y = 28; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final margin = Paint()
      ..color = VisualTheme.primaryColor.withValues(alpha: 0.28)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(18, 0), Offset(18, size.height), margin);
  }

  @override
  bool shouldRepaint(covariant _RulePainter oldDelegate) => oldDelegate.dark != dark;
}

class BinderTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const BinderTabs({super.key, required this.index, required this.onSelect});

  static const _labels = ['INDEX', 'SPINES', 'FLAGS', 'MOVES', 'COVER'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 46,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < _labels.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(i),
                  child: Container(
                    height: i == index ? 46 : 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index ? VisualTheme.primaryColor : VisualTheme.secondaryColor,
                      border: Border(
                        right: BorderSide(color: VisualTheme.paper.withValues(alpha: 0.25)),
                      ),
                    ),
                    child: Text(
                      _labels[i],
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 9,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: VisualTheme.paper,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TocRow extends StatelessWidget {
  final String indexLabel;
  final String title;
  final String meta;
  final VoidCallback onTap;
  const TocRow({
    super.key,
    required this.indexLabel,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(
              width: 36,
              child: Text(indexLabel, style: GoogleFonts.ibmPlexMono(fontSize: 13, fontWeight: FontWeight.w600, color: VisualTheme.primaryColor)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.libreBaskerville(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(meta, style: GoogleFonts.ibmPlexMono(fontSize: 11, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlagLine extends StatelessWidget {
  final Color accent;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  const FlagLine({
    super.key,
    required this.accent,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(width: 10, height: 14, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.libreBaskerville(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: GoogleFonts.ibmPlexMono(fontSize: 11)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class Colophon extends StatelessWidget {
  final String label;
  const Colophon({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(label, style: GoogleFonts.ibmPlexMono(fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w600, color: VisualTheme.primaryColor)),
    );
  }
}
