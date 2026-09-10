import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/storage_manager.dart';
import '../engine/local_composer.dart';
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

class _DrillViewState extends State<DrillView> {
  final _storage = StorageManager.instance;

  _Stage _stage = _Stage.setup;
  bool _isLoading = true;

  List<ContainerModel> _workshops = [];
  Map<int, int> _counts = {};
  int _hearthCount = 0;
  int _needCount = 0;

  int? _workshopFilter;
  bool _hearthOnly = false;
  int _length = 6;

  List<InventoryItemModel> _queue = [];
  int _cursor = 0;
  String _draft = '';
  bool _composed = false;
  final Map<String, int> _tally = {
    'Flat': 0,
    'First': 0,
    'Settled': 0,
    'Cellared': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadSetup();
  }

  Future<void> _loadSetup({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final workshops = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final w in workshops) {
        counts[w.id!] = await _storage.getItemCountInContainer(w.id!);
      }
      final hearth = await _storage.getFavoriteItems();
      final weak = await _storage.getWeakCues(limit: 500);
      if (!mounted) return;
      setState(() {
        _workshops = workshops;
        _counts = counts;
        _hearthCount = hearth.length;
        _needCount = weak.where((c) => c.condition != 'Cellared').length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error preparing spark: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startRun() async {
    List<InventoryItemModel> pool;
    if (_hearthOnly) {
      pool = await _storage.getFavoriteItems();
      if (_workshopFilter != null) {
        pool = pool.where((c) => c.containerId == _workshopFilter).toList();
      }
    } else {
      pool = await _storage.getWeakCues(limit: 500, containerId: _workshopFilter);
    }
    if (pool.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No recipes match that selection yet.')),
        );
      }
      return;
    }
    final take = pool.take(_length).toList();
    take.shuffle(Random());
    setState(() {
      _queue = take;
      _cursor = 0;
      _draft = '';
      _composed = false;
      _stage = _Stage.running;
      _tally.updateAll((key, value) => 0);
    });
  }

  void _compose() {
    final recipe = _queue[_cursor];
    final text = LocalComposer.compose(
      title: recipe.name,
      seed: recipe.notes ?? '',
      form: recipe.category,
      tags: recipe.keywords ?? '',
    );
    setState(() {
      _draft = text;
      _composed = true;
    });
  }

  void _rewrite(String move) {
    if (_draft.trim().isEmpty) return;
    setState(() => _draft = LocalComposer.rewrite(_draft, move));
  }

  Future<void> _grade(String level) async {
    final recipe = _queue[_cursor];
    final mastery = VisualTheme.recallStrength(level) * 100;
    var notes = recipe.notes;
    if (_composed &&
        _draft.trim().isNotEmpty &&
        (level == 'Cellared' || level == 'Settled' || level == 'First')) {
      final seed = (recipe.notes ?? '').split(RegExp(r'\n— SPARK —\n')).first.trim();
      notes = '$seed\n\n— SPARK —\n$_draft'.trim();
    }
    await _storage.logDrill(
      recipe.copyWith(notes: notes),
      level,
      mastery,
    );
    _tally[level] = (_tally[level] ?? 0) + 1;

    if (_cursor + 1 >= _queue.length) {
      setState(() => _stage = _Stage.summary);
      await _loadSetup(silent: true);
      return;
    }
    setState(() {
      _cursor += 1;
      _draft = '';
      _composed = false;
    });
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

  Widget _buildSetup() {
    final hasRecipes = _needCount > 0 || _hearthCount > 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
      children: [
        Text('Cupping', style: VisualTheme.display(32, color: VisualTheme.inkOf(context))),
        const SizedBox(height: 4),
        Text('Compose on this phone. Rewrite. Keep what you would actually send.',
            style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
        const SizedBox(height: 20),
        if (!hasRecipes)
          const EmptyDesk(
            icon: Icons.local_fire_department_rounded,
            tint: VisualTheme.clay,
            title: 'Nothing to spark yet',
            body: 'File a leaf into a caddy. Cupping uses the name, seed, form and tags.',
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: StatBlock(
                  value: '$_needCount',
                  label: 'Need a pass',
                  caption: 'shelved + seed first',
                  icon: Icons.edit_outlined,
                  tint: VisualTheme.ochre,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatBlock(
                  value: '$_hearthCount',
                  label: 'On the hearth',
                  caption: 'your own picks',
                  icon: Icons.favorite_border_rounded,
                  tint: VisualTheme.wine,
                ),
              ),
            ],
          ),
          const DeskHead(title: 'Source'),
          SheetCard(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: Column(
              children: [
                _SourceRow(
                  label: 'Needs a pass',
                  sub: 'Shelved, then seed, then rough',
                  icon: Icons.priority_high_rounded,
                  tint: VisualTheme.ochre,
                  selected: !_hearthOnly,
                  onTap: () => setState(() => _hearthOnly = false),
                ),
                _SourceRow(
                  label: 'Hearth only',
                  sub: '$_hearthCount recipe${_hearthCount == 1 ? '' : 's'} you pinned',
                  icon: Icons.favorite_rounded,
                  tint: VisualTheme.wine,
                  selected: _hearthOnly,
                  onTap: () => setState(() => _hearthOnly = true),
                ),
              ],
            ),
          ),
          const DeskHead(title: 'Narrow to a workshop'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'All workshops',
                selected: _workshopFilter == null,
                tint: VisualTheme.clay,
                onTap: () => setState(() => _workshopFilter = null),
              ),
              ..._workshops.map((w) => _FilterChip(
                    label: '${w.name} (${_counts[w.id] ?? 0})',
                    selected: _workshopFilter == w.id,
                    tint: VisualTheme.clay,
                    onTap: () => setState(() => _workshopFilter = w.id),
                  )),
            ],
          ),
          const DeskHead(title: 'Session length'),
          Row(
            children: [
              for (final n in const [3, 6, 10, 16]) ...[
                Expanded(
                  child: _LengthBox(
                    n: n,
                    selected: _length == n,
                    onTap: () => setState(() => _length = n),
                  ),
                ),
                if (n != 16) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('start_drill_button'),
            onPressed: _startRun,
            style: FilledButton.styleFrom(
              backgroundColor: VisualTheme.clay,
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('Open the spark'),
          ),
        ],
      ],
    );
  }

  Widget _buildRun() {
    final recipe = _queue[_cursor];
    final accent = VisualTheme.getCategoryColor(recipe.category);
    final progress = _cursor / _queue.length;
    final seed = (recipe.notes ?? '').split(RegExp(r'\n— SPARK —\n')).first.trim();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 18, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _stage = _Stage.setup),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkBar(value: progress, color: VisualTheme.clay, height: 6),
                ),
              ),
              Text('${_cursor + 1}/${_queue.length}',
                  style: VisualTheme.heading(14, color: VisualTheme.mutedOf(context))),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
            children: [
              InkChip(label: recipe.category.toUpperCase(), color: accent),
              const SizedBox(height: 10),
              Text(recipe.name, style: VisualTheme.display(26, color: VisualTheme.inkOf(context))),
              if (seed.isNotEmpty) ...[
                const SizedBox(height: 10),
                SheetCard(
                  fill: VisualTheme.veilOf(context),
                  child: Text(seed,
                      style: VisualTheme.body(14.5, color: VisualTheme.inkOf(context))),
                ),
              ],
              const SizedBox(height: 14),
              if (!_composed)
                FilledButton.icon(
                  onPressed: _compose,
                  icon: const Icon(Icons.local_fire_department_rounded, size: 20),
                  label: const Text('Compose on this phone'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                )
              else ...[
                Row(
                  children: [
                    Text('DRAFT', style: VisualTheme.tag(11, color: VisualTheme.clay)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _draft));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Draft copied')),
                          );
                        }
                      },
                      child: const Text('Copy'),
                    ),
                  ],
                ),
                SheetCard(
                  padding: const EdgeInsets.all(18),
                  child: Text(_draft,
                      style: VisualTheme.body(16, color: VisualTheme.inkOf(context), w: FontWeight.w500)),
                ),
                const SizedBox(height: 12),
                Text('Rewrite moves',
                    style: VisualTheme.heading(14, color: VisualTheme.mutedOf(context))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LocalComposer.moves
                      .map((m) => OutlinedButton(
                            onPressed: () => _rewrite(m),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(m),
                          ))
                      .toList(),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ItemDetailView(itemId: recipe.id!)));
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Open the recipe'),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
          child: _composed
              ? Column(
                  children: [
                    Text('Keep this draft?',
                        style: VisualTheme.body(13.5, color: VisualTheme.mutedOf(context))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final g in const [
                          ('Flat', 'Flat'),
                          ('First', 'First'),
                          ('Settled', 'Settled'),
                          ('Cellared', 'Keep'),
                        ]) ...[
                          Expanded(
                            child: _GradeButton(
                              label: g.$2,
                              color: VisualTheme.getConditionColor(g.$1),
                              onTap: () => _grade(g.$1),
                            ),
                          ),
                          if (g.$1 != 'Cellared') const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                )
              : Text('Compose first, then grade what to keep.',
                  textAlign: TextAlign.center,
                  style: VisualTheme.body(13, color: VisualTheme.mutedOf(context))),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final done = _queue.length;
    final ready = _tally['Cellared'] ?? 0;
    final tuned = _tally['Settled'] ?? 0;
    final score = done == 0 ? 0.0 : (ready + tuned * 0.6) / done;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
      children: [
        const SizedBox(height: 10),
        Center(
          child: InkGauge(
            value: score,
            color: VisualTheme.moss,
            size: 128,
            stroke: 10,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(score * 100).round()}%',
                    style: VisualTheme.display(32, color: VisualTheme.inkOf(context))),
                Text('KEEP RATE',
                    style: VisualTheme.tag(10, color: VisualTheme.mutedOf(context))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text('Session closed',
            textAlign: TextAlign.center,
            style: VisualTheme.display(26, color: VisualTheme.inkOf(context))),
        const SizedBox(height: 6),
        Text('$done recipe${done == 1 ? '' : 's'} graded. Kept drafts are saved on the recipe.',
            textAlign: TextAlign.center,
            style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
        const DeskHead(title: 'How it landed'),
        SheetCard(
          child: Column(
            children: [
              for (final entry in const ['Cellared', 'Settled', 'First', 'Flat'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 78,
                        child: InkChip(
                            label: entry, color: VisualTheme.getConditionColor(entry)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkBar(
                          value: done == 0 ? 0 : (_tally[entry] ?? 0) / done,
                          color: VisualTheme.getConditionColor(entry),
                          height: 8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 24,
                        child: Text('${_tally[entry] ?? 0}',
                            textAlign: TextAlign.right,
                            style: VisualTheme.heading(15, color: VisualTheme.inkOf(context))),
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
            backgroundColor: VisualTheme.clay,
            minimumSize: const Size.fromHeight(54),
          ),
          child: const Text('Back to Cupping'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _startRun,
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          child: const Text('Run another session'),
        ),
      ],
    );
  }
}

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
            Icon(icon, color: tint, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: VisualTheme.heading(15.5, color: VisualTheme.inkOf(context))),
                  Text(sub, style: VisualTheme.body(12.5, color: VisualTheme.mutedOf(context))),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? tint : VisualTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? tint : tint.withValues(alpha: 0.22), width: 1.2),
        ),
        child: Text(
          label,
          style: VisualTheme.heading(13.5,
              color: selected ? Colors.white : VisualTheme.inkOf(context)),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? VisualTheme.clay : VisualTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(VisualTheme.rM),
          border: selected
              ? null
              : Border.all(color: const Color(0x1A1C1916)),
        ),
        child: Column(
          children: [
            Text('$n',
                style: VisualTheme.display(20,
                    color: selected ? Colors.white : VisualTheme.inkOf(context))),
            Text('recipes',
                style: VisualTheme.tag(9.5,
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(VisualTheme.rM),
          border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: VisualTheme.heading(13, color: color, w: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
