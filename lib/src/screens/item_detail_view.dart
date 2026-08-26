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
  InventoryItemModel? _cue;
  ContainerModel? _mission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final cue = await _storage.getItem(widget.itemId);
      if (cue != null) {
        final mission = await _storage.getContainer(cue.containerId);
        if (!mounted) return;
        setState(() {
          _cue = cue;
          _mission = mission;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading cue: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStar() async {
    if (_cue == null) return;
    final updated = _cue!.copyWith(isFavorite: !_cue!.isFavorite);
    await _storage.updateItem(updated);
    setState(() => _cue = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(updated.isFavorite ? 'Added to the drill deck' : 'Removed from the drill deck'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  Future<void> _setRecall(String level) async {
    if (_cue == null) return;
    final updated = _cue!.copyWith(
      condition: level,
      estimatedValue: VisualTheme.recallStrength(level) * 100,
    );
    await _storage.updateItem(updated);
    setState(() => _cue = updated);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Drop this cue?'),
        content: const Text('It leaves the mission and the drill deck.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: VisualTheme.rose),
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
    if (_cue == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Cue not found')));
    }

    final cue = _cue!;
    final accent = VisualTheme.getCategoryColor(cue.category);
    final mastery = (cue.estimatedValue ?? VisualTheme.recallStrength(cue.condition) * 100)
        .clamp(0, 100)
        .toDouble();
    final lastDrill = cue.purchaseDate == null
        ? null
        : DateTime.tryParse(cue.purchaseDate!);

    return Scaffold(
      body: StarDust(
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
                    icon: Icon(cue.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: cue.isFavorite ? VisualTheme.sun : null),
                    onPressed: _toggleStar,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'move', child: Text('Reassign to a mission')),
                      PopupMenuItem(value: 'edit', child: Text('Edit cue')),
                      PopupMenuItem(value: 'delete', child: Text('Drop cue')),
                    ],
                    onSelected: (v) {
                      if (v == 'move') {
                        Navigator.push(context,
                                MaterialPageRoute(builder: (_) => MoveItemView(item: cue)))
                            .then((r) {
                          if (r == true) _load();
                        });
                      } else if (v == 'edit') {
                        Navigator.push(context,
                                MaterialPageRoute(builder: (_) => ItemFormView(item: cue)))
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
              if (cue.photoPath != null && cue.photoPath!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(VisualTheme.rXL),
                  child: Image.file(
                    File(cue.photoPath!),
                    height: 200,
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
                  TinyPill(label: cue.category.toUpperCase(), color: accent),
                  const SizedBox(width: 8),
                  TinyPill(
                      label: cue.condition.toUpperCase(),
                      color: VisualTheme.getConditionColor(cue.condition)),
                ],
              ),
              const SizedBox(height: 14),
              Text(cue.name, style: VisualTheme.display(30, color: VisualTheme.inkOf(context))),
              const SizedBox(height: 18),
              BentoTile(
                child: Row(
                  children: [
                    RingGauge(
                      value: mastery / 100,
                      color: VisualTheme.getConditionColor(cue.condition),
                      size: 74,
                      stroke: 8,
                      center: Text('${mastery.round()}',
                          style: VisualTheme.display(19, color: VisualTheme.inkOf(context))),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mastery',
                              style: VisualTheme.heading(16,
                                  color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text('${cue.quantity} reps logged',
                              style: VisualTheme.body(13, color: VisualTheme.mutedOf(context))),
                          Text(
                            lastDrill == null
                                ? 'never drilled'
                                : 'last drilled ${DateFormat('MMM d').format(lastDrill)}',
                            style: VisualTheme.body(13, color: VisualTheme.mutedOf(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SectionHead(title: 'Set recall level'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: VisualTheme.recallLevels.map((lvl) {
                  final on = cue.condition == lvl;
                  final c = VisualTheme.getConditionColor(lvl);
                  return GestureDetector(
                    onTap: () => _setRecall(lvl),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 170),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        color: on ? c : c.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(lvl,
                          style: VisualTheme.heading(13.5,
                              color: on ? Colors.white : c, w: FontWeight.w700)),
                    ),
                  );
                }).toList(),
              ),
              if ((cue.notes ?? '').trim().isNotEmpty) ...[
                const SectionHead(title: 'The anchor'),
                BentoTile(
                  fill: VisualTheme.veilOf(context),
                  child: Text(cue.notes!,
                      style: VisualTheme.body(16,
                          color: VisualTheme.inkOf(context), w: FontWeight.w600)),
                ),
              ],
              if ((cue.keywords ?? '').trim().isNotEmpty) ...[
                const SectionHead(title: 'Tags'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cue.keywords!
                      .split(',')
                      .map((k) => k.trim())
                      .where((k) => k.isNotEmpty)
                      .map((k) => TinyPill(label: k, color: VisualTheme.plum))
                      .toList(),
                ),
              ],
              const SectionHead(title: 'Filed under'),
              BentoTile(
                onTap: _mission == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ContainerDetailView(containerId: _mission!.id!)),
                        ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: VisualTheme.nova.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(VisualTheme.trackIcon(_mission?.room ?? 'General'),
                          color: VisualTheme.nova, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_mission?.name ?? 'Unknown mission',
                              style: VisualTheme.heading(16,
                                  color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                          Text(
                            _mission == null
                                ? ''
                                : '${_mission!.code} · ${_mission!.room} · ${_mission!.shelf}',
                            style: VisualTheme.body(12.5, color: VisualTheme.mutedOf(context)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: VisualTheme.nova),
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
