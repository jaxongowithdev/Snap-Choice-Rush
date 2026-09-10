import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'container_detail_view.dart';
import 'item_form_view.dart';
import 'move_item_view.dart';

class ItemDetailView extends StatefulWidget {
  final int itemId;
  const ItemDetailView({super.key, required this.itemId});

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  final _storage = StorageManager.instance;
  InventoryItemModel? _recipe;
  ContainerModel? _workshop;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final recipe = await _storage.getItem(widget.itemId);
      if (recipe != null) {
        final workshop = await _storage.getContainer(recipe.containerId);
        if (!mounted) return;
        setState(() {
          _recipe = recipe;
          _workshop = workshop;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading recipe: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePin() async {
    if (_recipe == null) return;
    final updated = _recipe!.copyWith(isFavorite: !_recipe!.isFavorite);
    await _storage.updateItem(updated);
    setState(() => _recipe = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(updated.isFavorite ? 'Pinned to the hearth' : 'Taken off the hearth'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  Future<void> _setStage(String level) async {
    if (_recipe == null) return;
    final updated = _recipe!.copyWith(
      condition: level,
      estimatedValue: VisualTheme.recallStrength(level) * 100,
    );
    await _storage.updateItem(updated);
    setState(() => _recipe = updated);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Drop this recipe?'),
        content: const Text('It leaves the workshop and the hearth.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: VisualTheme.wine),
            child: const Text('Drop'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _storage.deleteItem(widget.itemId);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_recipe == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Recipe not found')));
    }

    final recipe = _recipe!;
    final accent = VisualTheme.getCategoryColor(recipe.category);
    final keep = (recipe.estimatedValue ?? VisualTheme.recallStrength(recipe.condition) * 100)
        .clamp(0, 100)
        .toDouble();
    final lastSpark = recipe.purchaseDate == null ? null : DateTime.tryParse(recipe.purchaseDate!);
    final parts = (recipe.notes ?? '').split(RegExp(r'\n— SPARK —\n'));
    final seed = parts.first.trim();
    final draft = parts.length > 1 ? parts.sublist(1).join('\n— SPARK —\n').trim() : '';

    return Scaffold(
      body: PaperGrain(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    key: const ValueKey('favorite_toggle'),
                    icon: Icon(
                        recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: recipe.isFavorite ? VisualTheme.wine : null),
                    onPressed: _togglePin,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'move', child: Text('Move to a workshop')),
                      PopupMenuItem(value: 'edit', child: Text('Edit recipe')),
                      PopupMenuItem(value: 'delete', child: Text('Drop recipe')),
                    ],
                    onSelected: (v) {
                      if (v == 'move') {
                        Navigator.push(context,
                                MaterialPageRoute(builder: (_) => MoveItemView(item: recipe)))
                            .then((r) {
                          if (r == true) _load();
                        });
                      } else if (v == 'edit') {
                        Navigator.push(context,
                                MaterialPageRoute(builder: (_) => ItemFormView(item: recipe)))
                            .then((r) {
                          if (r == true) _load();
                        });
                      } else if (v == 'delete') {
                        _delete();
                      }
                    },
                  ),
                ],
              ),
              if (recipe.photoPath != null && recipe.photoPath!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(VisualTheme.rL),
                  child: Image.file(
                    File(recipe.photoPath!),
                    height: 188,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: VisualTheme.veilOf(context),
                      child: const Center(child: Icon(Icons.broken_image_rounded)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  InkChip(label: recipe.category.toUpperCase(), color: accent),
                  const SizedBox(width: 8),
                  InkChip(
                      label: recipe.condition.toUpperCase(),
                      color: VisualTheme.getConditionColor(recipe.condition)),
                ],
              ),
              const SizedBox(height: 12),
              Text(recipe.name, style: VisualTheme.display(28, color: VisualTheme.inkOf(context))),
              const SizedBox(height: 16),
              SheetCard(
                child: Row(
                  children: [
                    InkGauge(
                      value: keep / 100,
                      color: VisualTheme.getConditionColor(recipe.condition),
                      size: 68,
                      stroke: 7,
                      center: Text('${keep.round()}',
                          style: VisualTheme.display(18, color: VisualTheme.inkOf(context))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Keep score',
                              style: VisualTheme.heading(16, color: VisualTheme.inkOf(context))),
                          const SizedBox(height: 3),
                          Text('${recipe.quantity} sparks run',
                              style: VisualTheme.body(13, color: VisualTheme.mutedOf(context))),
                          Text(
                            lastSpark == null
                                ? 'never sparked'
                                : 'last sparked ${DateFormat('MMM d').format(lastSpark)}',
                            style: VisualTheme.body(13, color: VisualTheme.mutedOf(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const DeskHead(title: 'Set draft stage'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: VisualTheme.recallLevels.map((lvl) {
                  final on = recipe.condition == lvl;
                  final c = VisualTheme.getConditionColor(lvl);
                  return GestureDetector(
                    onTap: () => _setStage(lvl),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 170),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: on ? c : c.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(lvl,
                          style: VisualTheme.heading(13.5, color: on ? Colors.white : c)),
                    ),
                  );
                }).toList(),
              ),
              if (seed.isNotEmpty) ...[
                const DeskHead(title: 'Seed'),
                SheetCard(
                  fill: VisualTheme.veilOf(context),
                  child: Text(seed,
                      style: VisualTheme.body(15.5,
                          color: VisualTheme.inkOf(context), w: FontWeight.w500)),
                ),
              ],
              if (draft.isNotEmpty) ...[
                const DeskHead(title: 'Last kept draft'),
                SheetCard(
                  child: Text(draft,
                      style: VisualTheme.body(15.5, color: VisualTheme.inkOf(context))),
                ),
              ],
              if ((recipe.keywords ?? '').trim().isNotEmpty) ...[
                const DeskHead(title: 'Tags'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recipe.keywords!
                      .split(',')
                      .map((k) => k.trim())
                      .where((k) => k.isNotEmpty)
                      .map((k) => InkChip(label: k, color: VisualTheme.inkBlue))
                      .toList(),
                ),
              ],
              const DeskHead(title: 'Filed under'),
              SheetCard(
                onTap: _workshop == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ContainerDetailView(containerId: _workshop!.id!)),
                        ),
                child: Row(
                  children: [
                    Icon(VisualTheme.trackIcon(_workshop?.room ?? 'General'),
                        color: VisualTheme.moss, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_workshop?.name ?? 'Unknown workshop',
                              style: VisualTheme.heading(16, color: VisualTheme.inkOf(context))),
                          Text(
                            _workshop == null
                                ? ''
                                : '${_workshop!.code} · ${_workshop!.room} · ${_workshop!.shelf}',
                            style: VisualTheme.body(12.5, color: VisualTheme.mutedOf(context)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: VisualTheme.clay),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
