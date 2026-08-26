import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/visual_theme.dart';

// =====================================================================
//  Background — soft nebula blobs + fine star dust
// =====================================================================

class StarDust extends StatelessWidget {
  final Widget child;
  const StarDust({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _DustPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _DustPainter extends CustomPainter {
  final bool dark;
  _DustPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = dark ? VisualTheme.night : VisualTheme.canvas,
    );

    void blob(Offset c, double r, Color color) {
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(rect),
      );
    }

    final a = dark ? 0.22 : 0.30;
    blob(Offset(size.width * 0.10, size.height * 0.06), size.width * 0.62,
        VisualTheme.nova.withValues(alpha: a));
    blob(Offset(size.width * 1.02, size.height * 0.24), size.width * 0.55,
        VisualTheme.rose.withValues(alpha: a * 0.7));
    blob(Offset(size.width * 0.80, size.height * 0.92), size.width * 0.70,
        VisualTheme.mint.withValues(alpha: a * 0.6));
    blob(Offset(size.width * -0.05, size.height * 0.72), size.width * 0.5,
        VisualTheme.sun.withValues(alpha: a * 0.55));

    final rnd = Random(7);
    final star = Paint()
      ..color = dark
          ? Colors.white.withValues(alpha: 0.5)
          : VisualTheme.ink.withValues(alpha: 0.13);
    for (var i = 0; i < 90; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        rnd.nextDouble() * 1.3 + 0.35,
        star,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter old) => old.dark != dark;
}

// =====================================================================
//  Bottom navigation — floating pill bar, label expands on the active tab
// =====================================================================

class OrbitDock extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const OrbitDock({super.key, required this.index, required this.onSelect});

  static const _labels = ['Deck', 'Missions', 'Drill', 'Stats', 'Base'];
  static const _icons = [
    Icons.dashboard_rounded,
    Icons.rocket_launch_rounded,
    Icons.bolt_rounded,
    Icons.insights_rounded,
    Icons.tune_rounded,
  ];
  static const _tints = [
    VisualTheme.nova,
    VisualTheme.sky,
    VisualTheme.flare,
    VisualTheme.mint,
    VisualTheme.plum,
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: dark ? VisualTheme.nightSurface : Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: VisualTheme.softShadow(dark),
            border: Border.all(
              color: dark ? const Color(0x229C8CFF) : const Color(0x14382C7A),
            ),
          ),
          child: Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  flex: i == index ? 5 : 3,
                  child: _DockItem(
                    icon: _icons[i],
                    label: _labels[i],
                    tint: _tints[i],
                    active: i == index,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tint;
  final bool active;
  final VoidCallback onTap;
  const _DockItem({
    required this.icon,
    required this.label,
    required this.tint,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
        decoration: BoxDecoration(
          color: active ? tint.withValues(alpha: dark ? 0.26 : 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: active ? 21 : 20,
              color: active
                  ? tint
                  : (dark
                      ? VisualTheme.nightInk.withValues(alpha: 0.42)
                      : VisualTheme.muted.withValues(alpha: 0.65)),
            ),
            if (active)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: VisualTheme.heading(13, color: tint, w: FontWeight.w700),
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

// =====================================================================
//  Section header
// =====================================================================

class SectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsets padding;
  const SectionHead({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(2, 26, 2, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(title,
                style: VisualTheme.heading(19, color: VisualTheme.inkOf(context), w: FontWeight.w700)),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(action!, style: VisualTheme.heading(13, color: VisualTheme.nova)),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: VisualTheme.nova),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Small pill / chip
// =====================================================================

class TinyPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool solid;
  const TinyPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon == null ? 11 : 9, vertical: 5),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: solid ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VisualTheme.tag(11, color: solid ? Colors.white : color),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Bento tile — the layout primitive of the whole app
// =====================================================================

class BentoTile extends StatelessWidget {
  final Widget child;
  final Color? fill;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;
  const BentoTile({
    super.key,
    required this.child,
    this.fill,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius = VisualTheme.rXL,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill ?? VisualTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: fill == null ? VisualTheme.softShadow(dark) : null,
      ),
      child: child,
    );
    if (onTap == null) return body;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: body,
    );
  }
}

/// A stat square: big number, label, icon badge.
class StatBento extends StatelessWidget {
  final String value;
  final String label;
  final String? caption;
  final IconData icon;
  final Color tint;
  final VoidCallback? onTap;
  const StatBento({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.tint,
    this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BentoTile(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: tint),
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: VisualTheme.display(30, color: VisualTheme.inkOf(context))),
          ),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VisualTheme.body(13, color: VisualTheme.mutedOf(context), w: FontWeight.w700)),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VisualTheme.body(11, color: tint, w: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}

// =====================================================================
//  Ring gauge + meter bar
// =====================================================================

class RingGauge extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double stroke;
  final Color color;
  final Widget? center;
  const RingGauge({
    super.key,
    required this.value,
    required this.color,
    this.size = 62,
    this.stroke = 7,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0.0, 1.0),
          color: color,
          stroke: stroke,
          track: dark ? const Color(0x33FFFFFF) : const Color(0x14382C7A),
        ),
        child: center == null ? null : Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  final double stroke;
  _RingPainter({required this.value, required this.color, required this.track, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, base);

    if (value <= 0) return;
    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [color.withValues(alpha: 0.55), color],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, 2 * pi * value, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

class MeterBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double height;
  const MeterBar({super.key, required this.value, required this.color, this.height = 7});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: dark ? const Color(0x33FFFFFF) : const Color(0x14382C7A),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

// =====================================================================
//  Cue tile (list row) and Mission tile (grid card)
// =====================================================================

class CueTile extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final String? recall;
  final Color accent;
  final VoidCallback onTap;
  final Widget? trailing;
  const CueTile({
    super.key,
    required this.kind,
    required this.title,
    required this.meta,
    required this.accent,
    required this.onTap,
    this.recall,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VisualTheme.rL),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            color: VisualTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(VisualTheme.rL),
            boxShadow: VisualTheme.softShadow(dark),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    kind.isEmpty ? '?' : kind.characters.first.toUpperCase(),
                    style: VisualTheme.display(20, color: accent),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VisualTheme.heading(16.5, color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VisualTheme.body(12.5, color: VisualTheme.mutedOf(context))),
                    if (recall != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TinyPill(label: recall!, color: VisualTheme.getConditionColor(recall!)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MeterBar(
                              value: VisualTheme.recallStrength(recall!),
                              color: VisualTheme.getConditionColor(recall!),
                              height: 5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class MissionTile extends StatelessWidget {
  final String code;
  final String name;
  final String track;
  final int filled;
  final int target;
  final Color accent;
  final VoidCallback onTap;
  const MissionTile({
    super.key,
    required this.code,
    required this.name,
    required this.track,
    required this.filled,
    required this.target,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = target == 0 ? 0.0 : (filled / target).clamp(0.0, 1.0);
    return BentoTile(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: TinyPill(label: code, color: accent, icon: VisualTheme.trackIcon(track))),
            ],
          ),
          const SizedBox(height: 14),
          RingGauge(
            value: pct,
            color: accent,
            size: 58,
            stroke: 6,
            center: Text('$filled',
                style: VisualTheme.display(17, color: VisualTheme.inkOf(context))),
          ),
          const SizedBox(height: 12),
          Text(name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: VisualTheme.heading(16, color: VisualTheme.inkOf(context), w: FontWeight.w700)),
          const SizedBox(height: 3),
          Text('$track · $filled/$target cues',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VisualTheme.body(12, color: VisualTheme.mutedOf(context))),
        ],
      ),
    );
  }
}

// =====================================================================
//  Empty state
// =====================================================================

class EmptyOrbit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color tint;
  const EmptyOrbit({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.tint = VisualTheme.nova,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 20, 34, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(icon, size: 38, color: tint),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: VisualTheme.heading(21, color: VisualTheme.inkOf(context), w: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
            if (actionLabel != null) ...[
              const SizedBox(height: 22),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
