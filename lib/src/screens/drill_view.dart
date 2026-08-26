import 'dart:math';
import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'item_detail_view.dart';

enum _Stage { setup, running, summary }

class DrillView extends StatefulWidget {
  const DrillView({super.key});

  @override
  State<DrillView> createState() => _DrillViewState();
}

class _DrillViewState extends State<DrillView> with SingleTickerProviderStateMixin {
  final _storage = StorageManager.instance;

  _Stage _stage = _Stage.setup;
  bool _isLoading = true;

  List<ContainerModel> _missions = [];
  Map<int, int> _counts = {};
  int _deckCount = 0;
  int _weakCount = 0;

  /// null = every mission
  int? _missionFilter;
  bool _starredOnly = false;
  int _length = 10;

  List<InventoryItemModel> _queue = [];
  int _cursor = 0;
  bool _flipped = false;
  final Map<String, int> _tally = {'Faded': 0, 'Shaky': 0, 'Steady': 0, 'Locked': 0};

  late final AnimationController _flipCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void initState() {
    super.initState();
    _loadSetup();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSetup({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final missions = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final m in missions) {
        counts[m.id!] = await _storage.getItemCountInContainer(m.id!);
      }
      final starred = await _storage.getFavoriteItems();
      final weak = await _storage.getWeakCues(limit: 500);
      if (!mounted) return;
      setState(() {
        _missions = missions;
        _counts = counts;
        _deckCount = starred.length;
        _weakCount = weak.where((c) => c.condition != 'Locked').length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error preparing drill: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startRun() async {
    List<InventoryItemModel> pool;
    if (_starredOnly) {
      pool = await _storage.getFavoriteItems();
      if (_missionFilter != null) {
        pool = pool.where((c) => c.containerId == _missionFilter).toList();
      }
    } else {
      pool = await _storage.getWeakCues(limit: 500, containerId: _missionFilter);
    }
    if (pool.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cues match that selection yet.')),
        );
      }
      return;
    }
    final take = pool.take(_length).toList();
    take.shuffle(Random());
    setState(() {
      _queue = take;
      _cursor = 0;
      _flipped = false;
      _stage = _Stage.running;
      _tally.updateAll((key, value) => 0);
    });
    _flipCtrl.value = 0;
  }

  void _flip() {
    setState(() => _flipped = !_flipped);
    if (_flipped) {
      _flipCtrl.forward();
    } else {
      _flipCtrl.reverse();
    }
  }

  Future<void> _grade(String level) async {
    final cue = _queue[_cursor];
    final mastery = VisualTheme.recallStrength(level) * 100;
    await _storage.logDrill(cue, level, mastery);
    _tally[level] = (_tally[level] ?? 0) + 1;

    if (_cursor + 1 >= _queue.length) {
      setState(() => _stage = _Stage.summary);
      await _loadSetup(silent: true);
      return;
    }
    setState(() {
      _cursor += 1;
      _flipped = false;
    });
    _flipCtrl.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : switch (_stage) {
                _Stage.setup => _buildSetup(),
                _Stage.running => _buildRun(),
                _Stage.summary => _buildSummary(),
              },
      ),
    );
  }

  // ------------------------------------------------------------------
  // SETUP
  // ------------------------------------------------------------------
  Widget _buildSetup() {
    final hasCues = _weakCount > 0 || _deckCount > 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
      children: [
        Text('Drill room',
            style: VisualTheme.display(32, color: VisualTheme.inkOf(context))),
        const SizedBox(height: 4),
        Text('Flip, answer out loud, then grade yourself honestly.',
            style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
        const SizedBox(height: 20),

        if (!hasCues)
          EmptyOrbit(
            icon: Icons.bolt_rounded,
            tint: VisualTheme.flare,
            title: 'Nothing to drill yet',
            body: 'File a few cues into a mission and they queue up here automatically.',
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: StatBento(
                  value: '$_weakCount',
                  label: 'Need work',
                  caption: 'faded + shaky first',
                  icon: Icons.trending_down_rounded,
                  tint: VisualTheme.rose,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatBento(
                  value: '$_deckCount',
                  label: 'Starred',
                  caption: 'your own picks',
                  icon: Icons.star_rounded,
                  tint: VisualTheme.sun,
                ),
              ),
            ],
          ),

          const SectionHead(title: 'Pick a source'),
          BentoTile(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: Column(
              children: [
                _SourceRow(
                  label: 'Weakest cues',
                  sub: 'Faded, then shaky, then fresh',
                  icon: Icons.priority_high_rounded,
                  tint: VisualTheme.rose,
                  selected: !_starredOnly,
                  onTap: () => setState(() => _starredOnly = false),
                ),
                _SourceRow(
                  label: 'Starred deck only',
                  sub: '$_deckCount cue${_deckCount == 1 ? '' : 's'} you marked',
                  icon: Icons.star_rounded,
                  tint: VisualTheme.sun,
                  selected: _starredOnly,
                  onTap: () => setState(() => _starredOnly = true),
                ),
              ],
            ),
          ),

          const SectionHead(title: 'Narrow to a mission'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'All missions',
                selected: _missionFilter == null,
                tint: VisualTheme.nova,
                onTap: () => setState(() => _missionFilter = null),
              ),
              ..._missions.map((m) => _FilterChip(
                    label: '${m.name} (${_counts[m.id] ?? 0})',
                    selected: _missionFilter == m.id,
                    tint: VisualTheme.nova,
                    onTap: () => setState(() => _missionFilter = m.id),
                  )),
            ],
          ),

          const SectionHead(title: 'Run length'),
          Row(
            children: [
              for (final n in const [5, 10, 20, 40]) ...[
                Expanded(
                  child: _LengthBox(
                    n: n,
                    selected: _length == n,
                    onTap: () => setState(() => _length = n),
                  ),
                ),
                if (n != 40) const SizedBox(width: 10),
              ],
            ],
          ),

          const SizedBox(height: 26),
          FilledButton(
            key: const ValueKey('start_drill_button'),
            onPressed: _startRun,
            style: FilledButton.styleFrom(
              backgroundColor: VisualTheme.flare,
              minimumSize: const Size.fromHeight(58),
            ),
            child: const Text('Launch drill'),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------------
  // RUNNING
  // ------------------------------------------------------------------
  Widget _buildRun() {
    final cue = _queue[_cursor];
    final accent = VisualTheme.getCategoryColor(cue.category);
    final progress = (_cursor) / _queue.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _stage = _Stage.setup),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: MeterBar(value: progress, color: VisualTheme.flare, height: 8),
                ),
              ),
              Text('${_cursor + 1}/${_queue.length}',
                  style: VisualTheme.heading(14, color: VisualTheme.mutedOf(context))),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
            child: GestureDetector(
              onTap: _flip,
              child: AnimatedBuilder(
                animation: _flipCtrl,
                builder: (context, _) {
                  final angle = _flipCtrl.value * pi;
                  final showBack = _flipCtrl.value > 0.5;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0011)
                      ..rotateY(angle),
                    child: showBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _cardBack(cue, accent),
                          )
                        : _cardFront(cue, accent),
                  );
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
          child: _flipped
              ? Column(
                  children: [
                    Text('How did that go?',
                        style: VisualTheme.body(13.5, color: VisualTheme.mutedOf(context))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final g in const [
                          ('Faded', 'Missed'),
                          ('Shaky', 'Shaky'),
                          ('Steady', 'Got it'),
                          ('Locked', 'Locked'),
                        ]) ...[
                          Expanded(
                            child: _GradeButton(
                              label: g.$2,
                              color: VisualTheme.getConditionColor(g.$1),
                              onTap: () => _grade(g.$1),
                            ),
                          ),
                          if (g.$1 != 'Locked') const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                )
              : FilledButton(
                  onPressed: _flip,
                  style: FilledButton.styleFrom(
                    backgroundColor: VisualTheme.nova,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Reveal the answer'),
                ),
        ),
      ],
    );
  }

  Widget _cardFront(InventoryItemModel cue, Color accent) {
    return BentoTile(
      fill: accent,
      padding: const EdgeInsets.all(26),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TinyPill(
              label: cue.category.toUpperCase(),
              color: Colors.white.withValues(alpha: 0.24),
              solid: true,
            ),
            const SizedBox(height: 22),
            Text(cue.name,
                textAlign: TextAlign.center,
                style: VisualTheme.display(30, color: Colors.white)),
            const SizedBox(height: 18),
            Text('tap to reveal',
                style: VisualTheme.tag(11, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _cardBack(InventoryItemModel cue, Color accent) {
    final note = (cue.notes ?? '').trim();
    return BentoTile(
      padding: const EdgeInsets.all(26),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TinyPill(label: 'THE ANCHOR', color: accent),
            const SizedBox(height: 18),
            Text(
              note.isEmpty ? 'No anchor written for this cue yet.' : note,
              style: VisualTheme.heading(22,
                  color: VisualTheme.inkOf(context), w: FontWeight.w600),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                TinyPill(
                    label: 'was ${cue.condition}',
                    color: VisualTheme.getConditionColor(cue.condition)),
                const SizedBox(width: 8),
                TinyPill(
                    label: '${cue.quantity} reps', color: VisualTheme.mutedOf(context)),
              ],
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ItemDetailView(itemId: cue.id!)));
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 17),
              label: const Text('Open the cue'),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // SUMMARY
  // ------------------------------------------------------------------
  Widget _buildSummary() {
    final done = _queue.length;
    final locked = _tally['Locked'] ?? 0;
    final steady = _tally['Steady'] ?? 0;
    final score = done == 0 ? 0.0 : (locked + steady * 0.6) / done;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
      children: [
        const SizedBox(height: 10),
        Center(
          child: RingGauge(
            value: score,
            color: VisualTheme.mint,
            size: 140,
            stroke: 13,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(score * 100).round()}%',
                    style: VisualTheme.display(34, color: VisualTheme.inkOf(context))),
                Text('RUN SCORE',
                    style: VisualTheme.tag(10, color: VisualTheme.mutedOf(context))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Drill complete',
            textAlign: TextAlign.center,
            style: VisualTheme.display(28, color: VisualTheme.inkOf(context))),
        const SizedBox(height: 6),
        Text('$done cue${done == 1 ? '' : 's'} graded and saved.',
            textAlign: TextAlign.center,
            style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
        const SectionHead(title: 'How it landed'),
        BentoTile(
          child: Column(
            children: [
              for (final entry in const ['Locked', 'Steady', 'Shaky', 'Faded'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 74,
                        child: TinyPill(
                            label: entry, color: VisualTheme.getConditionColor(entry)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MeterBar(
                          value: done == 0 ? 0 : (_tally[entry] ?? 0) / done,
                          color: VisualTheme.getConditionColor(entry),
                          height: 9,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 24,
                        child: Text('${_tally[entry] ?? 0}',
                            textAlign: TextAlign.right,
                            style: VisualTheme.heading(15,
                                color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => setState(() => _stage = _Stage.setup),
          style: FilledButton.styleFrom(
            backgroundColor: VisualTheme.flare,
            minimumSize: const Size.fromHeight(56),
          ),
          child: const Text('Back to the drill room'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _startRun,
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text('Run it again'),
        ),
      ],
    );
  }
}

// ====================================================================
//  Small setup widgets
// ====================================================================

class _SourceRow extends StatelessWidget {
  final String label;
  final String sub;
  final IconData icon;
  final Color tint;
  final bool selected;
  final VoidCallback onTap;
  const _SourceRow({
    required this.label,
    required this.sub,
    required this.icon,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VisualTheme.rL),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? tint.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(VisualTheme.rL),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: VisualTheme.heading(15.5,
                          color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                  Text(sub,
                      style:
                          VisualTheme.body(12.5, color: VisualTheme.mutedOf(context))),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? tint : VisualTheme.mutedOf(context).withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color tint;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? tint : VisualTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? tint : tint.withValues(alpha: 0.18),
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: VisualTheme.heading(13.5,
              color: selected ? Colors.white : VisualTheme.inkOf(context),
              w: FontWeight.w700),
        ),
      ),
    );
  }
}

class _LengthBox extends StatelessWidget {
  final int n;
  final bool selected;
  final VoidCallback onTap;
  const _LengthBox({required this.n, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? VisualTheme.nova : VisualTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(VisualTheme.rM),
        ),
        child: Column(
          children: [
            Text('$n',
                style: VisualTheme.display(22,
                    color: selected ? Colors.white : VisualTheme.inkOf(context))),
            Text('cues',
                style: VisualTheme.tag(10,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.8)
                        : VisualTheme.mutedOf(context))),
          ],
        ),
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _GradeButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(VisualTheme.rM),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                style: VisualTheme.heading(14, color: color, w: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}
