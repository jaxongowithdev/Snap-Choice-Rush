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
  List<ContainerModel> _workshops = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _hearth = [];
  List<InventoryItemModel> _recent = [];
  int _ready = 0;
  int _sparks = 0;
  bool _isLoading = true;

  static const _accents = [
    VisualTheme.clay,
    VisualTheme.moss,
    VisualTheme.inkBlue,
    VisualTheme.ochre,
    VisualTheme.wine,
    VisualTheme.sage,
  ];

  static const _notes = [
    'A recipe with a seed writes faster than a blank page. Put the facts in first.',
    'Spark once, then tighten. The second pass is where the voice shows up.',
    'Keep a hearth of the pieces you would actually send. The rest can wait.',
    'If a draft feels loud, run Formal. If it feels stiff, run Warmer.',
    'One workshop per craft keeps the desk from becoming a junk drawer.',
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
      final workshops = await _storage.getAllContainers(sortBy: 'updated');
      final counts = <int, int>{};
      for (final w in workshops) {
        counts[w.id!] = await _storage.getItemCountInContainer(w.id!);
      }
      final hearth = await _storage.getFavoriteItems();
      final recent = await _storage.getRecentCues(limit: 4);
      final ready = await _storage.getLockedCount();
      final sparks = await _storage.getTotalReps();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _workshops = workshops;
        _counts = counts;
        _hearth = hearth;
        _recent = recent;
        _ready = ready;
        _sparks = sparks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading desk: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning at the desk';
    if (h < 18) return 'Afternoon at the desk';
    return 'Evening at the desk';
  }

  @override
  Widget build(BuildContext context) {
    final total = _stats?['totalItems'] ?? 0;
    final workshopCount = _stats?['totalContainers'] ?? 0;
    final keep = total == 0 ? 0.0 : _ready / total;
    final tip = _notes[DateTime.now().day % _notes.length];

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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_greeting,
                                  style: VisualTheme.body(13.5,
                                      color: VisualTheme.mutedOf(context), w: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('Desk',
                                  style: VisualTheme.display(32, color: VisualTheme.inkOf(context))),
                            ],
                          ),
                        ),
                        _SquareIcon(
                          icon: Icons.search_rounded,
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const SearchView())),
                        ),
                        const SizedBox(width: 8),
                        _SquareIcon(
                          icon: Icons.swap_horiz_rounded,
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const TransferLogView()));
                            _loadData();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    SheetCard(
                      fill: VisualTheme.clay,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ON THE PAGE',
                                    style: VisualTheme.tag(11,
                                        color: Colors.white.withValues(alpha: 0.72))),
                                const SizedBox(height: 8),
                                Text('$total',
                                    style: VisualTheme.display(42, color: Colors.white)),
                                Text(
                                  total == 0
                                      ? 'no recipes filed yet'
                                      : 'recipes across $workshopCount ${workshopCount == 1 ? 'workshop' : 'workshops'}',
                                  style: VisualTheme.body(13.5,
                                      color: Colors.white.withValues(alpha: 0.85)),
                                ),
                                const SizedBox(height: 12),
                                InkChip(
                                  label: '$_sparks sparks run',
                                  color: Colors.white.withValues(alpha: 0.22),
                                  icon: Icons.local_fire_department_rounded,
                                  solid: true,
                                ),
                              ],
                            ),
                          ),
                          InkGauge(
                            value: keep,
                            color: Colors.white,
                            size: 86,
                            stroke: 7,
                            center: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${(keep * 100).round()}%',
                                    style: VisualTheme.display(18, color: Colors.white)),
                                Text('ready',
                                    style: VisualTheme.tag(9,
                                        color: Colors.white.withValues(alpha: 0.75))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: StatBlock(
                            value: '${_hearth.length}',
                            label: 'On the hearth',
                            caption: _hearth.isEmpty ? 'pin a recipe' : 'ready to spark',
                            icon: Icons.favorite_border_rounded,
                            tint: VisualTheme.wine,
                            onTap: () => widget.onJump?.call(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatBlock(
                            value: '$workshopCount',
                            label: 'Workshops',
                            caption: '${_stats?['emptyContainers'] ?? 0} still empty',
                            icon: Icons.folder_open_rounded,
                            tint: VisualTheme.moss,
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
                          child: StatBlock(
                            value: '$_ready',
                            label: 'Press-ready',
                            caption: 'you would send these',
                            icon: Icons.check_circle_outline_rounded,
                            tint: VisualTheme.moss,
                            onTap: () => widget.onJump?.call(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatBlock(
                            value: '${total - _ready}',
                            label: 'Still in draft',
                            caption: 'spark these first',
                            icon: Icons.edit_outlined,
                            tint: VisualTheme.ochre,
                            onTap: () => widget.onJump?.call(2),
                          ),
                        ),
                      ],
                    ),

                    DeskHead(
                      title: 'Open workshops',
                      action: 'All',
                      onAction: () => widget.onJump?.call(1),
                    ),
                    if (_workshops.isEmpty)
                      SheetCard(
                        onTap: () async {
                          final r = await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ContainerFormView()));
                          if (r == true) _loadData();
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.add_rounded, color: VisualTheme.clay, size: 24),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Open your first workshop',
                                      style: VisualTheme.heading(16,
                                          color: VisualTheme.inkOf(context))),
                                  Text('Shop windows, classroom openers, a weekly letter…',
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
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          itemCount: _workshops.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final w = _workshops[i];
                            final count = _counts[w.id] ?? 0;
                            final accent = _accents[i % _accents.length];
                            final pct = w.capacity == 0 ? 0.0 : (count / w.capacity).clamp(0.0, 1.0);
                            return SizedBox(
                              width: 158,
                              child: SheetCard(
                                padding: const EdgeInsets.all(12),
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ContainerDetailView(containerId: w.id!)));
                                  _loadData();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(VisualTheme.trackIcon(w.room),
                                            size: 16, color: accent),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(w.code,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: VisualTheme.tag(10.5, color: accent)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(w.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: VisualTheme.heading(14.5,
                                            color: VisualTheme.inkOf(context))),
                                    const Spacer(),
                                    InkBar(value: pct, color: accent, height: 4),
                                    const SizedBox(height: 5),
                                    Text('$count / ${w.capacity} recipes',
                                        style: VisualTheme.body(11,
                                            color: VisualTheme.mutedOf(context))),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const DeskHead(title: 'Tonight’s spark'),
                    SheetCard(
                      fill: VisualTheme.ochre.withValues(alpha: 0.14),
                      onTap: () => widget.onJump?.call(2),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: VisualTheme.clay,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.local_fire_department_rounded,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Compose a session',
                                    style: VisualTheme.heading(16.5,
                                        color: VisualTheme.inkOf(context))),
                                const SizedBox(height: 2),
                                Text(
                                  total == 0
                                      ? 'File a few recipes and Spark has something to work with.'
                                      : 'Seeds first — compose, rewrite, keep what sings.',
                                  style: VisualTheme.body(13, color: VisualTheme.mutedOf(context)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: VisualTheme.clay),
                        ],
                      ),
                    ),

                    if (_recent.isNotEmpty) ...[
                      DeskHead(
                        title: 'Just touched',
                        action: 'Hearth',
                        onAction: () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const FavoritesView()));
                          _loadData();
                        },
                      ),
                      ..._recent.map((recipe) => RecipeRow(
                            kind: recipe.category,
                            title: recipe.name,
                            meta: '${recipe.category} · ${recipe.quantity} sparks',
                            recall: recipe.condition,
                            accent: VisualTheme.getCategoryColor(recipe.category),
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ItemDetailView(itemId: recipe.id!)));
                              _loadData();
                            },
                          )),
                    ],

                    const DeskHead(title: 'Desk note'),
                    SheetCard(
                      fill: VisualTheme.veilOf(context),
                      child: Text(tip,
                          style: VisualTheme.body(14.5,
                              color: VisualTheme.inkOf(context), w: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add_item_button'),
        heroTag: 'fab_desk',
        onPressed: () async {
          final r = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ItemFormView()));
          if (r == true) _loadData();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New recipe'),
      ),
    );
  }
}

class _SquareIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: VisualTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0x22E08A68)
                : const Color(0x1A1C1916),
          ),
        ),
        child: Icon(icon, size: 20, color: VisualTheme.inkOf(context)),
      ),
    );
  }
}
