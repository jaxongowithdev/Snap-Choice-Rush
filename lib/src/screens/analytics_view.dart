import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'favorites_view.dart';
import 'transfer_log_view.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final _storage = StorageManager.instance;
  Map<String, int>? _stats;
  Map<String, int>? _byType;
  Map<String, int>? _byTrack;
  Map<String, int>? _byRecall;
  int _reps = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _storage.getStatistics();
      final byType = await _storage.getItemsByCategory();
      final byTrack = await _storage.getItemsByRoom();
      final byRecall = await _storage.getRecallBreakdown();
      final reps = await _storage.getTotalReps();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _byType = byType;
        _byTrack = byTrack;
        _byRecall = byRecall;
        _reps = reps;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _stats?['totalItems'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
                  children: [
                    Text('Progress',
                        style: VisualTheme.display(32, color: VisualTheme.inkOf(context))),
                    const SizedBox(height: 4),
                    Text('Where the memory load sits right now.',
                        style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
                    const SizedBox(height: 20),

                    if (total == 0)
                      const EmptyOrbit(
                        icon: Icons.insights_rounded,
                        tint: VisualTheme.mint,
                        title: 'No data yet',
                        body: 'File a few cues and this page fills in with your recall spread.',
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: StatBento(
                              value: '$total',
                              label: 'Total cues',
                              icon: Icons.style_rounded,
                              tint: VisualTheme.nova,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatBento(
                              value: '$_reps',
                              label: 'Reps logged',
                              icon: Icons.repeat_rounded,
                              tint: VisualTheme.flare,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatBento(
                              value: '${_stats?['totalContainers'] ?? 0}',
                              label: 'Missions',
                              icon: Icons.rocket_launch_rounded,
                              tint: VisualTheme.sky,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatBento(
                              value: '${_stats?['emptyContainers'] ?? 0}',
                              label: 'Empty missions',
                              icon: Icons.inbox_rounded,
                              tint: VisualTheme.plum,
                            ),
                          ),
                        ],
                      ),

                      const SectionHead(title: 'Recall spread'),
                      BentoTile(
                        child: Column(
                          children: [
                            for (final lvl in VisualTheme.recallLevels)
                              _Bar(
                                label: lvl,
                                value: _byRecall?[lvl] ?? 0,
                                total: total,
                                color: VisualTheme.getConditionColor(lvl),
                              ),
                          ],
                        ),
                      ),

                      if ((_byTrack ?? {}).isNotEmpty) ...[
                        const SectionHead(title: 'By track'),
                        BentoTile(
                          child: Column(
                            children: [
                              for (final e in _byTrack!.entries)
                                _Bar(
                                  label: e.key,
                                  value: e.value,
                                  total: total,
                                  color: VisualTheme.nova,
                                  icon: VisualTheme.trackIcon(e.key),
                                ),
                            ],
                          ),
                        ),
                      ],

                      if ((_byType ?? {}).isNotEmpty) ...[
                        const SectionHead(title: 'By cue type'),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _byType!.entries.map((e) {
                            final c = VisualTheme.getCategoryColor(e.key);
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: c.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(VisualTheme.rM),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${e.value}',
                                      style: VisualTheme.display(19, color: c)),
                                  const SizedBox(width: 8),
                                  Text(e.key,
                                      style: VisualTheme.heading(13.5,
                                          color: VisualTheme.inkOf(context),
                                          w: FontWeight.w700)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],

                    const SectionHead(title: 'Jump to'),
                    Row(
                      children: [
                        Expanded(
                          child: BentoTile(
                            onTap: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const FavoritesView()));
                              _load();
                            },
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: VisualTheme.sun, size: 24),
                                const SizedBox(height: 10),
                                Text('Drill deck',
                                    style: VisualTheme.heading(15.5,
                                        color: VisualTheme.inkOf(context),
                                        w: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BentoTile(
                            onTap: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const TransferLogView()));
                              _load();
                            },
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.route_rounded,
                                    color: VisualTheme.sky, size: 24),
                                const SizedBox(height: 10),
                                Text('Flight log',
                                    style: VisualTheme.heading(15.5,
                                        color: VisualTheme.inkOf(context),
                                        w: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;
  final IconData? icon;
  const _Bar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: icon == null ? 76 : 68,
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VisualTheme.body(13, color: VisualTheme.inkOf(context), w: FontWeight.w700)),
          ),
          Expanded(child: MeterBar(value: pct, color: color, height: 9)),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text('$value',
                textAlign: TextAlign.right,
                style: VisualTheme.heading(14.5,
                    color: VisualTheme.inkOf(context), w: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
