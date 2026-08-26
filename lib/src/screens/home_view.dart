import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'container_detail_view.dart';
import 'container_form_view.dart';
import 'favorites_view.dart';
import 'item_detail_view.dart';
import 'item_form_view.dart';
import 'search_view.dart';
import 'transfer_log_view.dart';

class HomeView extends StatefulWidget {
  final ValueChanged<int>? onJump;
  const HomeView({super.key, this.onJump});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _storage = StorageManager.instance;

  Map<String, int>? _stats;
  List<ContainerModel> _missions = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _deck = [];
  List<InventoryItemModel> _recent = [];
  int _locked = 0;
  int _reps = 0;
  bool _isLoading = true;

  static const _accents = [
    VisualTheme.nova,
    VisualTheme.sky,
    VisualTheme.flare,
    VisualTheme.mint,
    VisualTheme.rose,
    VisualTheme.plum,
  ];

  static const _briefings = [
    'Recall beats reread. Say the answer out loud before you flip the card.',
    'Anchor every planet to a room you already walk through — hallway, kitchen, stairs.',
    'Three short drills across a week beat one long one on Sunday night.',
    'A cue that keeps slipping is a cue that needs a stranger picture.',
    'Lock a cue only after you have recalled it cold, twice, on different days.',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _storage.getStatistics();
      final missions = await _storage.getAllContainers(sortBy: 'updated');
      final counts = <int, int>{};
      for (final m in missions) {
        counts[m.id!] = await _storage.getItemCountInContainer(m.id!);
      }
      final deck = await _storage.getFavoriteItems();
      final recent = await _storage.getRecentCues(limit: 4);
      final locked = await _storage.getLockedCount();
      final reps = await _storage.getTotalReps();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _missions = missions;
        _counts = counts;
        _deck = deck;
        _recent = recent;
        _locked = locked;
        _reps = reps;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading deck: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning, cadet';
    if (h < 18) return 'Afternoon, cadet';
    return 'Evening, cadet';
  }

  @override
  Widget build(BuildContext context) {
    final total = _stats?['totalItems'] ?? 0;
    final missionCount = _stats?['totalContainers'] ?? 0;
    final mastery = total == 0 ? 0.0 : _locked / total;
    final tip = _briefings[DateTime.now().day % _briefings.length];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 96),
                  children: [
                    // ---------- header ----------
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_greeting,
                                  style: VisualTheme.body(13.5,
                                      color: VisualTheme.mutedOf(context), w: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('Flight deck',
                                  style: VisualTheme.display(32, color: VisualTheme.inkOf(context))),
                            ],
                          ),
                        ),
                        _RoundIcon(
                          icon: Icons.search_rounded,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SearchView())),
                        ),
                        const SizedBox(width: 8),
                        _RoundIcon(
                          icon: Icons.history_rounded,
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const TransferLogView()));
                            _loadData();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ---------- hero bento ----------
                    BentoTile(
                      fill: VisualTheme.nova,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('MEMORY LOAD',
                                    style: VisualTheme.tag(11,
                                        color: Colors.white.withValues(alpha: 0.72))),
                                const SizedBox(height: 8),
                                Text('$total',
                                    style: VisualTheme.display(46, color: Colors.white)),
                                Text(
                                  total == 0
                                      ? 'no cues in orbit yet'
                                      : 'cues across $missionCount ${missionCount == 1 ? 'mission' : 'missions'}',
                                  style: VisualTheme.body(13.5,
                                      color: Colors.white.withValues(alpha: 0.85)),
                                ),
                                const SizedBox(height: 14),
                                TinyPill(
                                  label: '$_reps reps logged',
                                  color: Colors.white.withValues(alpha: 0.22),
                                  icon: Icons.repeat_rounded,
                                  solid: true,
                                ),
                              ],
                            ),
                          ),
                          RingGauge(
                            value: mastery,
                            color: Colors.white,
                            size: 92,
                            stroke: 9,
                            center: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${(mastery * 100).round()}%',
                                    style: VisualTheme.display(20, color: Colors.white)),
                                Text('locked',
                                    style: VisualTheme.tag(9,
                                        color: Colors.white.withValues(alpha: 0.75))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ---------- 2x2 stat bento ----------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: StatBento(
                            value: '${_deck.length}',
                            label: 'In drill deck',
                            caption: _deck.isEmpty ? 'star a cue' : 'ready to run',
                            icon: Icons.bolt_rounded,
                            tint: VisualTheme.flare,
                            onTap: () => widget.onJump?.call(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatBento(
                            value: '$missionCount',
                            label: 'Missions',
                            caption: '${_stats?['emptyContainers'] ?? 0} still empty',
                            icon: Icons.rocket_launch_rounded,
                            tint: VisualTheme.sky,
                            onTap: () => widget.onJump?.call(1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: StatBento(
                            value: '$_locked',
                            label: 'Locked cues',
                            caption: 'recalled cold',
                            icon: Icons.lock_rounded,
                            tint: VisualTheme.mint,
                            onTap: () => widget.onJump?.call(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatBento(
                            value: '${total - _locked}',
                            label: 'Still wobbly',
                            caption: 'drill these first',
                            icon: Icons.trending_up_rounded,
                            tint: VisualTheme.rose,
                            onTap: () => widget.onJump?.call(2),
                          ),
                        ),
                      ],
                    ),

                    // ---------- missions strip ----------
                    SectionHead(
                      title: 'Missions in orbit',
                      action: 'All',
                      onAction: () => widget.onJump?.call(1),
                    ),
                    if (_missions.isEmpty)
                      BentoTile(
                        onTap: () async {
                          final r = await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ContainerFormView()));
                          if (r == true) _loadData();
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: VisualTheme.nova.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: VisualTheme.nova, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Launch your first mission',
                                      style: VisualTheme.heading(16,
                                          color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                                  Text('Eight planets, Jupiter’s moons, the Apollo flights…',
                                      style: VisualTheme.body(12.5,
                                          color: VisualTheme.mutedOf(context))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 118,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          itemCount: _missions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final m = _missions[i];
                            final count = _counts[m.id] ?? 0;
                            final accent = _accents[i % _accents.length];
                            final pct = m.capacity == 0
                                ? 0.0
                                : (count / m.capacity).clamp(0.0, 1.0);
                            return SizedBox(
                              width: 150,
                              child: BentoTile(
                                padding: const EdgeInsets.all(14),
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ContainerDetailView(containerId: m.id!)));
                                  _loadData();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(VisualTheme.trackIcon(m.room),
                                            size: 17, color: accent),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(m.code,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: VisualTheme.tag(11, color: accent)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(m.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: VisualTheme.heading(15,
                                            color: VisualTheme.inkOf(context),
                                            w: FontWeight.w700)),
                                    const Spacer(),
                                    MeterBar(value: pct, color: accent, height: 6),
                                    const SizedBox(height: 6),
                                    Text('$count / ${m.capacity} cues',
                                        style: VisualTheme.body(11.5,
                                            color: VisualTheme.mutedOf(context))),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // ---------- drill call to action ----------
                    const SectionHead(title: 'Tonight’s run'),
                    BentoTile(
                      fill: VisualTheme.getConditionColor('Shaky').withValues(alpha: 0.12),
                      onTap: () => widget.onJump?.call(2),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: VisualTheme.flare,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start a drill',
                                    style: VisualTheme.heading(17,
                                        color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(
                                  total == 0
                                      ? 'Add a few cues and the deck fills itself.'
                                      : 'Weakest cues first — flip, answer, grade.',
                                  style: VisualTheme.body(13,
                                      color: VisualTheme.mutedOf(context)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: VisualTheme.flare),
                        ],
                      ),
                    ),

                    // ---------- recent cues ----------
                    if (_recent.isNotEmpty) ...[
                      SectionHead(
                        title: 'Just touched',
                        action: 'Deck',
                        onAction: () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const FavoritesView()));
                          _loadData();
                        },
                      ),
                      ..._recent.map((cue) => CueTile(
                            kind: cue.category,
                            title: cue.name,
                            meta: '${cue.category} · ${cue.quantity} reps',
                            recall: cue.condition,
                            accent: VisualTheme.getCategoryColor(cue.category),
                            onTap: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => ItemDetailView(itemId: cue.id!)));
                              _loadData();
                            },
                          )),
                    ],

                    // ---------- briefing ----------
                    const SectionHead(title: 'Cadet briefing'),
                    BentoTile(
                      fill: VisualTheme.veilOf(context),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_rounded,
                              color: VisualTheme.sun, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(tip,
                                style: VisualTheme.body(14.5,
                                    color: VisualTheme.inkOf(context), w: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add_item_button'),
        heroTag: 'fab_deck',
        onPressed: () async {
          final r = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ItemFormView()));
          if (r == true) _loadData();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New cue'),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: VisualTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: VisualTheme.softShadow(dark),
        ),
        child: Icon(icon, size: 21, color: VisualTheme.inkOf(context)),
      ),
    );
  }
}
