import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/visual_theme.dart';

// =====================================================================
//  Background — warm paper with faint rules
// =====================================================================

class PaperGrain extends StatelessWidget {
  final Widget child;
  const PaperGrain({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _PaperPainter(dark: dark))),
        child,
      ],
    );
  }
}

class _PaperPainter extends CustomPainter {
  final bool dark;
  _PaperPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = dark ? VisualTheme.night : VisualTheme.paper,
    );

    void wash(Offset c, double r, Color color) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    final a = dark ? 0.18 : 0.22;
    wash(Offset(size.width * 0.92, size.height * 0.08), size.width * 0.55,
        VisualTheme.clay.withValues(alpha: a));
    wash(Offset(size.width * 0.08, size.height * 0.88), size.width * 0.62,
        VisualTheme.moss.withValues(alpha: a * 0.7));
    wash(Offset(size.width * 0.7, size.height * 0.72), size.width * 0.4,
        VisualTheme.ochre.withValues(alpha: a * 0.45));

    final rule = Paint()
      ..color = dark
          ? Colors.white.withValues(alpha: 0.04)
          : VisualTheme.ink.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    for (var y = 28.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rule);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPainter old) => old.dark != dark;
}

// =====================================================================
//  Bottom navigation — full-width desk rail, labels always on
// =====================================================================

class DeskRail extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const DeskRail({super.key, required this.index, required this.onSelect});

  static const _labels = ['Bench', 'Caddies', 'Cupping', 'Log', 'Shelf'];
  static const _icons = [
    Icons.table_restaurant_outlined,
    Icons.inventory_2_outlined,
    Icons.emoji_food_beverage_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final line = dark ? const Color(0x337AB8A8) : const Color(0x221C1916);
    return Material(
      color: dark ? VisualTheme.nightSurface : VisualTheme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: line))),
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: _RailItem(
                    icon: _icons[i],
                    label: _labels[i],
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

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _RailItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = VisualTheme.clay;
    final idle = dark
        ? VisualTheme.nightInk.withValues(alpha: 0.42)
        : VisualTheme.muted.withValues(alpha: 0.7);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: active ? tint : idle),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VisualTheme.tag(9.5, color: active ? tint : idle),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2,
              width: active ? 22 : 0,
              color: tint,
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

class DeskHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsets padding;
  const DeskHead({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(2, 24, 2, 10),
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
                style: VisualTheme.heading(18, color: VisualTheme.inkOf(context), w: FontWeight.w600)),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(action!, style: VisualTheme.heading(13, color: VisualTheme.clay)),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: VisualTheme.clay),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Small chip
// =====================================================================

class InkChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool solid;
  const InkChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon == null ? 10 : 8, vertical: 4),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(4),
        border: solid ? null : Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: solid ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VisualTheme.tag(10.5, color: solid ? Colors.white : color),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Paper sheet — layout primitive
// =====================================================================

class SheetCard extends StatelessWidget {
  final Widget child;
  final Color? fill;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;
  const SheetCard({
    super.key,
    required this.child,
    this.fill,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = VisualTheme.rL,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = dark ? const Color(0x227AB8A8) : const Color(0x1A1C1916);
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill ?? VisualTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(radius),
        border: fill == null ? Border.all(color: border) : null,
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

class StatBlock extends StatelessWidget {
  final String value;
  final String label;
  final String? caption;
  final IconData icon;
  final Color tint;
  final VoidCallback? onTap;
  const StatBlock({
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
    return SheetCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: tint),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: VisualTheme.display(28, color: VisualTheme.inkOf(context))),
          ),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VisualTheme.body(13, color: VisualTheme.mutedOf(context), w: FontWeight.w600)),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VisualTheme.body(11, color: tint, w: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

// =====================================================================
//  Gauge + meter
// =====================================================================

class InkGauge extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Widget? center;
  const InkGauge({
    super.key,
    required this.value,
    required this.color,
    this.size = 62,
    this.stroke = 6,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          value: value.clamp(0.0, 1.0),
          color: color,
          stroke: stroke,
          track: dark ? const Color(0x33FFFFFF) : const Color(0x221C1916),
        ),
        child: center == null ? null : Center(child: center),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  final double stroke;
  _GaugePainter({required this.value, required this.color, required this.track, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 0, 2 * pi, false, base);

    if (value <= 0) return;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, -pi / 2, 2 * pi * value, false, arc);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.value != value || old.color != color || old.track != track;
}

class InkBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const InkBar({super.key, required this.value, required this.color, this.height = 6});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(1),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: dark ? const Color(0x33FFFFFF) : const Color(0x221C1916),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

// =====================================================================
//  Recipe row + workshop card
// =====================================================================

class RecipeRow extends StatelessWidget {
  final String kind;
  final String title;
  final String meta;
  final String? recall;
  final Color accent;
  final VoidCallback onTap;
  final Widget? trailing;
  const RecipeRow({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VisualTheme.rL),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          decoration: BoxDecoration(
            color: VisualTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(VisualTheme.rL),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0x227AB8A8)
                  : const Color(0x1A1C1916),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VisualTheme.heading(16, color: VisualTheme.inkOf(context))),
                    const SizedBox(height: 3),
                    Text(meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VisualTheme.body(12.5, color: VisualTheme.mutedOf(context))),
                    if (recall != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          InkChip(label: recall!, color: VisualTheme.getConditionColor(recall!)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkBar(
                              value: VisualTheme.recallStrength(recall!),
                              color: VisualTheme.getConditionColor(recall!),
                              height: 4,
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

class WorkshopCard extends StatelessWidget {
  final String code;
  final String name;
  final String track;
  final int filled;
  final int target;
  final Color accent;
  final VoidCallback onTap;
  const WorkshopCard({
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
    return SheetCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(VisualTheme.trackIcon(track), size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VisualTheme.tag(10.5, color: accent)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkGauge(
            value: pct,
            color: accent,
            size: 52,
            stroke: 5,
            center: Text('$filled', style: VisualTheme.display(16, color: VisualTheme.inkOf(context))),
          ),
          const SizedBox(height: 12),
          Text(name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: VisualTheme.heading(15.5, color: VisualTheme.inkOf(context))),
          const SizedBox(height: 3),
          Text('$track · $filled/$target recipes',
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

class EmptyDesk extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color tint;
  const EmptyDesk({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.tint = VisualTheme.clay,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 20, 34, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: tint),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: VisualTheme.heading(20, color: VisualTheme.inkOf(context))),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kept so older call sites and tests that still import chrome names compile
/// after the atelier rewrite. Prefer the Kettleleaf names above.
typedef StarDust = PaperGrain;
typedef OrbitDock = DeskRail;
typedef SectionHead = DeskHead;
typedef TinyPill = InkChip;
typedef BentoTile = SheetCard;
typedef StatBento = StatBlock;
typedef RingGauge = InkGauge;
typedef MeterBar = InkBar;
typedef CueTile = RecipeRow;
typedef MissionTile = WorkshopCard;
typedef EmptyOrbit = EmptyDesk;
