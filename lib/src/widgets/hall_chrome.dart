import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class PianoDock extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const PianoDock({super.key, required this.index, required this.onSelect});

  static const _labels = ['HALL', 'BOOKS', 'STAR', 'CUE', 'FOYER'];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VisualTheme.ink,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Stack(
            children: [
              Row(
                children: [
                  for (var i = 0; i < 5; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onSelect(i),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(1, 0, 1, 0),
                          decoration: BoxDecoration(
                            color: i == index ? VisualTheme.ivory : const Color(0xFFF4EBD8),
                            border: Border.all(color: VisualTheme.ink, width: 1.2),
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _labels[i],
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w700,
                              color: i == index ? VisualTheme.primaryColor : VisualTheme.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IgnorePointer(
                child: Row(
                  children: [
                    const Spacer(flex: 7),
                    _blackKey(),
                    const Spacer(flex: 10),
                    _blackKey(),
                    const Spacer(flex: 10),
                    _blackKey(),
                    const Spacer(flex: 7),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blackKey() {
    return Container(
      width: 18,
      height: 34,
      decoration: BoxDecoration(
        color: VisualTheme.ink,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
        border: Border.all(color: const Color(0xFF2A2420)),
      ),
    );
  }
}

class StaffPaper extends StatelessWidget {
  final Widget child;
  const StaffPaper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _StaffPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _StaffPainter extends CustomPainter {
  final bool dark;
  _StaffPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dark ? const Color(0x22F7F1E3) : const Color(0x331A1814)
      ..strokeWidth = 1;
    const staffH = 40.0;
    const gap = 56.0;
    for (double y = 36; y < size.height; y += staffH + gap) {
      for (var i = 0; i < 5; i++) {
        final yy = y + i * 8;
        canvas.drawLine(Offset(16, yy), Offset(size.width - 16, yy), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StaffPainter oldDelegate) => oldDelegate.dark != dark;
}

class MeasureRow extends StatelessWidget {
  final String beat;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  const MeasureRow({
    super.key,
    required this.beat,
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(beat, style: GoogleFonts.cormorantGaramond(fontSize: 22, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: accent.withValues(alpha: 0.5)),
                  const SizedBox(height: 6),
                  Text(title, style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w600, height: 1.05)),
                  Text(meta, style: GoogleFonts.workSans(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovementLabel extends StatelessWidget {
  final String label;
  const MovementLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(label, style: GoogleFonts.workSans(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600, color: VisualTheme.primaryColor)),
    );
  }
}
