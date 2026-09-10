import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'container_detail_view.dart';
import 'container_form_view.dart';

class ContainerListView extends StatefulWidget {
  const ContainerListView({super.key});

  @override
  State<ContainerListView> createState() => _ContainerListViewState();
}

class _ContainerListViewState extends State<ContainerListView> {
  final _storage = StorageManager.instance;
  List<ContainerModel>? _workshops;
  Map<int, int> _counts = {};
  bool _isLoading = true;
  String _sortBy = 'name';
  String _craftFilter = 'All';

  static const _accents = [
    VisualTheme.clay,
    VisualTheme.moss,
    VisualTheme.inkBlue,
    VisualTheme.ochre,
    VisualTheme.wine,
    VisualTheme.sage,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final workshops = await _storage.getAllContainers(sortBy: _sortBy);
      final counts = <int, int>{};
      for (final w in workshops) {
        counts[w.id!] = await _storage.getItemCountInContainer(w.id!);
      }
      if (!mounted) return;
      setState(() {
        _workshops = workshops;
        _counts = counts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading workshops: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> get _crafts {
    final set = <String>{'All'};
    for (final w in _workshops ?? <ContainerModel>[]) {
      set.add(w.room);
    }
    return set.toList();
  }

  List<ContainerModel> get _visible {
    final all = _workshops ?? <ContainerModel>[];
    if (_craftFilter == 'All') return all;
    return all.where((w) => w.room == _craftFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('Workshops',
                                      style: VisualTheme.display(32,
                                          color: VisualTheme.inkOf(context))),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.swap_vert_rounded),
                                  onSelected: (v) {
                                    setState(() => _sortBy = v);
                                    _load();
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'name', child: Text('Sort by name')),
                                    PopupMenuItem(value: 'room', child: Text('Sort by craft')),
                                    PopupMenuItem(value: 'updated', child: Text('Recently touched')),
                                  ],
                                ),
                              ],
                            ),
                            Text('Each workshop is one craft — a job you write for.',
                                style: VisualTheme.body(14, color: VisualTheme.mutedOf(context))),
                            const SizedBox(height: 16),
                            if ((_workshops ?? []).isNotEmpty)
                              SizedBox(
                                height: 38,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _crafts.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (_, i) {
                                    final t = _crafts[i];
                                    final on = t == _craftFilter;
                                    return GestureDetector(
                                      onTap: () => setState(() => _craftFilter = t),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: on
                                              ? VisualTheme.clay
                                              : VisualTheme.surfaceOf(context),
                                          borderRadius: BorderRadius.circular(6),
                                          border: on
                                              ? null
                                              : Border.all(color: const Color(0x1A1C1916)),
                                        ),
                                        child: Row(
                                          children: [
                                            if (t != 'All') ...[
                                              Icon(VisualTheme.trackIcon(t),
                                                  size: 14,
                                                  color: on
                                                      ? Colors.white
                                                      : VisualTheme.mutedOf(context)),
                                              const SizedBox(width: 5),
                                            ],
                                            Text(t,
                                                style: VisualTheme.heading(13,
                                                    color: on
                                                        ? Colors.white
                                                        : VisualTheme.inkOf(context))),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (_visible.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyDesk(
                          icon: Icons.folder_open_rounded,
                          tint: VisualTheme.moss,
                          title: 'No workshops here',
                          body:
                              'A workshop holds one craft — shop windows, classroom openers, a weekly letter.',
                          actionLabel: 'Open a workshop',
                          onAction: () async {
                            final r = await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ContainerFormView()));
                            if (r == true) _load();
                          },
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 210,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final w = _visible[i];
                              return WorkshopCard(
                                code: w.code,
                                name: w.name,
                                track: w.room,
                                filled: _counts[w.id] ?? 0,
                                target: w.capacity,
                                accent: _accents[i % _accents.length],
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ContainerDetailView(containerId: w.id!)));
                                  _load();
                                },
                              );
                            },
                            childCount: _visible.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('fab_add_container'),
        heroTag: 'fab_workshops',
        onPressed: () async {
          final r = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
          if (r == true) _load();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Workshop'),
      ),
    );
  }
}
