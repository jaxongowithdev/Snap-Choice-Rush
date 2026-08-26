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
  List<ContainerModel>? _missions;
  Map<int, int> _counts = {};
  bool _isLoading = true;
  String _sortBy = 'name';
  String _trackFilter = 'All';

  static const _accents = [
    VisualTheme.nova,
    VisualTheme.sky,
    VisualTheme.flare,
    VisualTheme.mint,
    VisualTheme.rose,
    VisualTheme.plum,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final missions = await _storage.getAllContainers(sortBy: _sortBy);
      final counts = <int, int>{};
      for (final m in missions) {
        counts[m.id!] = await _storage.getItemCountInContainer(m.id!);
      }
      if (!mounted) return;
      setState(() {
        _missions = missions;
        _counts = counts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading missions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> get _tracks {
    final set = <String>{'All'};
    for (final m in _missions ?? <ContainerModel>[]) {
      set.add(m.room);
    }
    return set.toList();
  }

  List<ContainerModel> get _visible {
    final all = _missions ?? <ContainerModel>[];
    if (_trackFilter == 'All') return all;
    return all.where((m) => m.room == _trackFilter).toList();
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
                                  child: Text('Missions',
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
                                    PopupMenuItem(value: 'room', child: Text('Sort by track')),
                                    PopupMenuItem(value: 'updated', child: Text('Recently touched')),
                                  ],
                                ),
                              ],
                            ),
                            Text('Each mission is one themed set of cues.',
                                style: VisualTheme.body(14,
                                    color: VisualTheme.mutedOf(context))),
                            const SizedBox(height: 16),
                            if ((_missions ?? []).isNotEmpty)
                              SizedBox(
                                height: 40,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _tracks.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (_, i) {
                                    final t = _tracks[i];
                                    final on = t == _trackFilter;
                                    return GestureDetector(
                                      onTap: () => setState(() => _trackFilter = t),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 9),
                                        decoration: BoxDecoration(
                                          color: on
                                              ? VisualTheme.nova
                                              : VisualTheme.surfaceOf(context),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            if (t != 'All') ...[
                                              Icon(VisualTheme.trackIcon(t),
                                                  size: 15,
                                                  color: on
                                                      ? Colors.white
                                                      : VisualTheme.mutedOf(context)),
                                              const SizedBox(width: 5),
                                            ],
                                            Text(t,
                                                style: VisualTheme.heading(13.5,
                                                    color: on
                                                        ? Colors.white
                                                        : VisualTheme.inkOf(context),
                                                    w: FontWeight.w700)),
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
                        child: EmptyOrbit(
                          icon: Icons.rocket_launch_rounded,
                          tint: VisualTheme.sky,
                          title: 'No missions here',
                          body:
                              'A mission holds one topic — the eight planets, Jupiter’s moons, the Apollo timeline.',
                          actionLabel: 'Launch a mission',
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: 226,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final m = _visible[i];
                              return MissionTile(
                                code: m.code,
                                name: m.name,
                                track: m.room,
                                filled: _counts[m.id] ?? 0,
                                target: m.capacity,
                                accent: _accents[i % _accents.length],
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ContainerDetailView(containerId: m.id!)));
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
        heroTag: 'fab_missions',
        onPressed: () async {
          final r = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
          if (r == true) _load();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Mission'),
      ),
    );
  }
}
