import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'container_form_view.dart';
import 'item_detail_view.dart';
import 'item_form_view.dart';

class ContainerDetailView extends StatefulWidget {
  final int containerId;
  const ContainerDetailView({super.key, required this.containerId});

  @override
  State<ContainerDetailView> createState() => _ContainerDetailViewState();
}

class _ContainerDetailViewState extends State<ContainerDetailView> {
  final _storage = StorageManager.instance;
  ContainerModel? _mission;
  List<InventoryItemModel>? _cues;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final mission = await _storage.getContainer(widget.containerId);
      final cues = await _storage.getItemsByContainer(widget.containerId);
      if (!mounted) return;
      setState(() {
        _mission = mission;
        _cues = cues;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading mission: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Scrub this mission?'),
        content: const Text('Every cue filed under it is removed with it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: VisualTheme.rose),
            child: const Text('Scrub'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _storage.deleteContainer(widget.containerId);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_mission == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Mission not found')));
    }

    final m = _mission!;
    final cues = _cues ?? [];
    final locked = cues.where((c) => c.condition == 'Locked').length;
    final pct = m.capacity == 0 ? 0.0 : (cues.length / m.capacity).clamp(0.0, 1.0);

    return Scaffold(
      body: StarDust(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz_rounded),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit mission')),
                        PopupMenuItem(value: 'delete', child: Text('Scrub mission')),
                      ],
                      onSelected: (v) {
                        if (v == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ContainerFormView(container: m)),
                          ).then((r) {
                            if (r == true) _load();
                          });
                        } else if (v == 'delete') {
                          _delete();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                BentoTile(
                  fill: VisualTheme.nova,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TinyPill(
                            label: m.code,
                            color: Colors.white.withValues(alpha: 0.22),
                            icon: VisualTheme.trackIcon(m.room),
                            solid: true,
                          ),
                          const SizedBox(width: 8),
                          TinyPill(
                            label: m.shelf,
                            color: Colors.white.withValues(alpha: 0.22),
                            solid: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(m.name, style: VisualTheme.display(28, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(m.room,
                          style: VisualTheme.body(14,
                              color: Colors.white.withValues(alpha: 0.82))),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: MeterBar(value: pct, color: Colors.white, height: 8),
                          ),
                          const SizedBox(width: 12),
                          Text('${cues.length}/${m.capacity}',
                              style: VisualTheme.heading(14, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatBento(
                        value: '$locked',
                        label: 'Locked',
                        icon: Icons.lock_rounded,
                        tint: VisualTheme.mint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatBento(
                        value: '${cues.length - locked}',
                        label: 'In training',
                        icon: Icons.autorenew_rounded,
                        tint: VisualTheme.flare,
                      ),
                    ),
                  ],
                ),
                SectionHead(
                  title: 'Cues (${cues.length})',
                  action: 'Add',
                  onAction: () async {
                    final r = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemFormView(preselectedContainerId: widget.containerId),
                      ),
                    );
                    if (r == true) _load();
                  },
                ),
                if (cues.isEmpty)
                  BentoTile(
                    fill: VisualTheme.veilOf(context),
                    child: Text(
                      'Nothing filed here yet. A cue is one fact plus the picture that makes it stick.',
                      style: VisualTheme.body(14, color: VisualTheme.mutedOf(context)),
                    ),
                  )
                else
                  ...cues.map((cue) => CueTile(
                        kind: cue.category,
                        title: cue.name,
                        meta: '${cue.category} · ${cue.quantity} reps',
                        recall: cue.condition,
                        accent: VisualTheme.getCategoryColor(cue.category),
                        onTap: () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ItemDetailView(itemId: cue.id!)));
                          _load();
                        },
                      )),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add_item_button'),
        heroTag: 'fab_mission_detail',
        onPressed: () async {
          final r = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemFormView(preselectedContainerId: widget.containerId),
            ),
          );
          if (r == true) _load();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Cue'),
      ),
    );
  }
}
