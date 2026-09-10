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
  Map<String, int>? _byForm;
  Map<String, int>? _byCraft;
  Map<String, int>? _byStage;
  int _sparks = 0;
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
      final byForm = await _storage.getItemsByCategory();
      final byCraft = await _storage.getItemsByRoom();
      final byStage = await _storage.getRecallBreakdown();
      final sparks = await _storage.getTotalReps();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _byForm = byForm;
        _byCraft = byCraft;
        _byStage = byStage;
        _sparks = sparks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading ledger: $e');
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
                    Text('Ledger',
                        style: VisualTheme.display(32, color: VisualTheme.inkOf(context))),
                    const SizedBox(height: 4),
                    Text('Where the desk sits right now.',
                        style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
                    const SizedBox(height: 20),

                    if (total == 0)
                      const EmptyDesk(
                        icon: Icons.bar_chart_rounded,
                        tint: VisualTheme.moss,
                        title: 'No numbers yet',
                        body: 'File a few recipes and this page fills in with draft stages.',
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: StatBlock(
                              value: '$total',
                              label: 'Recipes',
                              icon: Icons.notes_rounded,
                              tint: VisualTheme.clay,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatBlock(
                              value: '$_sparks',
                              label: 'Sparks run',
                              icon: Icons.local_fire_department_rounded,
                              tint: VisualTheme.ochre,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatBlock(
                              value: '${_stats?['totalContainers'] ?? 0}',
                              label: 'Workshops',
                              icon: Icons.folder_open_rounded,
                              tint: VisualTheme.moss,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatBlock(
                              value: '${_stats?['emptyContainers'] ?? 0}',
                              label: 'Empty workshops',
                              icon: Icons.inbox_outlined,
                              tint: VisualTheme.inkBlue,
                            ),
                          ),
                        ],
                      ),

                      const DeskHead(title: 'Draft stages'),
                      SheetCard(
                        child: Column(
                          children: [
                            for (final lvl in VisualTheme.recallLevels)
                              _Bar(
                                label: lvl,
                                value: _byStage?[lvl] ?? 0,
                                total: total,
                                color: VisualTheme.getConditionColor(lvl),
                              ),
                          ],
                        ),
                      ),

                      if ((_byCraft ?? {}).isNotEmpty) ...[
                        const DeskHead(title: 'By craft'),
                        SheetCard(
                          child: Column(
                            children: [
                              for (final e in _byCraft!.entries)
                                _Bar(
                                  label: e.key,
                                  value: e.value,
                                  total: total,
                                  color: VisualTheme.moss,
                                  icon: VisualTheme.trackIcon(e.key),
                                ),
                            ],
                          ),
                        ),
                      ],

                      if ((_byForm ?? {}).isNotEmpty) ...[
                        const DeskHead(title: 'By form'),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _byForm!.entries.map((e) {
                            final c = VisualTheme.getCategoryColor(e.key);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: c.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(VisualTheme.rM),
                                border: Border.all(color: c.withValues(alpha: 0.22)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${e.value}', style: VisualTheme.display(18, color: c)),
                                  const SizedBox(width: 8),
                                  Text(e.key,
                                      style: VisualTheme.heading(13.5,
                                          color: VisualTheme.inkOf(context))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],

                    const DeskHead(title: 'Jump to'),
                    Row(
                      children: [
                        Expanded(
                          child: SheetCard(
                            onTap: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const FavoritesView()));
                              _load();
                            },
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.favorite_rounded,
                                    color: VisualTheme.wine, size: 22),
                                const SizedBox(height: 10),
                                Text('Hearth',
                                    style: VisualTheme.heading(15.5,
                                        color: VisualTheme.inkOf(context))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SheetCard(
                            onTap: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const TransferLogView()));
                              _load();
                            },
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.swap_horiz_rounded,
                                    color: VisualTheme.inkBlue, size: 22),
                                const SizedBox(height: 10),
                                Text('Move log',
                                    style: VisualTheme.heading(15.5,
                                        color: VisualTheme.inkOf(context))),
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: icon == null ? 76 : 68,
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VisualTheme.body(13, color: VisualTheme.inkOf(context), w: FontWeight.w600)),
          ),
          Expanded(child: InkBar(value: pct, color: color, height: 8)),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text('$value',
                textAlign: TextAlign.right,
                style: VisualTheme.heading(14, color: VisualTheme.inkOf(context))),
          ),
        ],
      ),
    );
  }
}
