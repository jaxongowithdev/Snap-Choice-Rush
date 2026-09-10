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
  ContainerModel? _workshop;
  List<InventoryItemModel>? _recipes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final workshop = await _storage.getContainer(widget.containerId);
      final recipes = await _storage.getItemsByContainer(widget.containerId);
      if (!mounted) return;
      setState(() {
        _workshop = workshop;
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading workshop: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Close this workshop?'),
        content: const Text('Every recipe filed under it is removed with it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: VisualTheme.wine),
            child: const Text('Close it'),
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
    if (_workshop == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Workshop not found')));
    }

    final w = _workshop!;
    final recipes = _recipes ?? [];
    final ready = recipes.where((c) => c.condition == 'Ready').length;
    final pct = w.capacity == 0 ? 0.0 : (recipes.length / w.capacity).clamp(0.0, 1.0);

    return Scaffold(
      body: PaperGrain(
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
                        PopupMenuItem(value: 'edit', child: Text('Edit workshop')),
                        PopupMenuItem(value: 'delete', child: Text('Close workshop')),
                      ],
                      onSelected: (v) {
                        if (v == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ContainerFormView(container: w)),
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
                SheetCard(
                  fill: VisualTheme.moss,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkChip(
                            label: w.code,
                            color: Colors.white.withValues(alpha: 0.22),
                            icon: VisualTheme.trackIcon(w.room),
                            solid: true,
                          ),
                          const SizedBox(width: 8),
                          InkChip(
                            label: w.shelf,
                            color: Colors.white.withValues(alpha: 0.22),
                            solid: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(w.name, style: VisualTheme.display(26, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(w.room,
                          style: VisualTheme.body(14, color: Colors.white.withValues(alpha: 0.82))),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: InkBar(value: pct, color: Colors.white, height: 6)),
                          const SizedBox(width: 12),
                          Text('${recipes.length}/${w.capacity}',
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
                      child: StatBlock(
                        value: '$ready',
                        label: 'Press-ready',
                        icon: Icons.check_circle_outline_rounded,
                        tint: VisualTheme.moss,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatBlock(
                        value: '${recipes.length - ready}',
                        label: 'In draft',
                        icon: Icons.edit_outlined,
                        tint: VisualTheme.ochre,
                      ),
                    ),
                  ],
                ),
                DeskHead(
                  title: 'Recipes (${recipes.length})',
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
                if (recipes.isEmpty)
                  SheetCard(
                    fill: VisualTheme.veilOf(context),
                    child: Text(
                      'Nothing filed here yet. A recipe is a title, a seed, and the form Spark should write in.',
                      style: VisualTheme.body(14, color: VisualTheme.mutedOf(context)),
                    ),
                  )
                else
                  ...recipes.map((recipe) => RecipeRow(
                        kind: recipe.category,
                        title: recipe.name,
                        meta: '${recipe.category} · ${recipe.quantity} sparks',
                        recall: recipe.condition,
                        accent: VisualTheme.getCategoryColor(recipe.category),
                        onTap: () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ItemDetailView(itemId: recipe.id!)));
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
        heroTag: 'fab_workshop_detail',
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
        label: const Text('Recipe'),
      ),
    );
  }
}
