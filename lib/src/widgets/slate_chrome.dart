import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/visual_theme.dart';

class SlateDock extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const SlateDock({super.key, required this.index, required this.onSelect});

  static const _items = [
    (Icons.calendar_view_day_outlined, 'BOARD'),
    (Icons.schedule_outlined, 'PERIODS'),
    (Icons.star_outline, 'STAR'),
    (Icons.swap_vert, 'SHIFT'),
    (Icons.meeting_room_outlined, 'OFFICE'),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? VisualTheme.deep : VisualTheme.primaryColor,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelect(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_items[i].$1, size: 20, color: i == index ? VisualTheme.accentColor : VisualTheme.chalk.withValues(alpha: 0.55)),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].$2,
                          style: GoogleFonts.syne(
                            fontSize: 9,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                            color: i == index ? VisualTheme.accentColor : VisualTheme.chalk.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PeriodRow extends StatelessWidget {
  final String mark;
  final String title;
  final String meta;
  final String fill;
  final double progress;
  final VoidCallback onTap;
  const PeriodRow({
    super.key,
    required this.mark,
    required this.title,
    required this.meta,
    required this.fill,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).dividerColor;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: line))),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Text(mark, style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, height: 1)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(meta, style: GoogleFonts.manrope(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.65))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress.clamp(0, 1),
                          minHeight: 3,
                          backgroundColor: line,
                          color: VisualTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(fill, style: GoogleFonts.manrope(fontSize: 11, letterSpacing: 0.4)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaterialLine extends StatelessWidget {
  final Color accent;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  const MaterialLine({
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
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(width: 3, height: 36, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: GoogleFonts.manrope(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.65))),
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

class SlateRule extends StatelessWidget {
  final String label;
  const SlateRule({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.syne(fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: VisualTheme.secondaryColor)),
          const SizedBox(width: 10),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
  }
}
