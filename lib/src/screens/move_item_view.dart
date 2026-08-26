import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';

class MoveItemView extends StatefulWidget {
  final InventoryItemModel item;
  const MoveItemView({super.key, required this.item});

  @override
  State<MoveItemView> createState() => _MoveItemViewState();
}

class _MoveItemViewState extends State<MoveItemView> {
  final _storage = StorageManager.instance;
  final _notesController = TextEditingController();
  List<ContainerModel>? _targets;
  ContainerModel? _current;
  ContainerModel? _picked;
  Map<int, int> _counts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final current = await _storage.getContainer(widget.item.containerId);
      final others = (await _storage.getAllContainers())
          .where((m) => m.id != widget.item.containerId)
          .toList();
      final counts = <int, int>{};
      for (final m in others) {
        counts[m.id!] = await _storage.getItemCountInContainer(m.id!);
      }
      if (!mounted) return;
      setState(() {
        _current = current;
        _targets = others;
        _counts = counts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading missions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _move() async {
    if (_picked == null) return;
    final destCount = _counts[_picked!.id] ?? 0;
    if (destCount >= _picked!.capacity) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Mission is at target'),
          content: Text('"${_picked!.name}" already holds ${_picked!.capacity} cues. Reassign anyway?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reassign')),
          ],
        ),
      );
      if (confirm != true) return;
    }
    await _storage.moveItem(
      widget.item.id!,
      widget.item.containerId,
      _picked!.id!,
      _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Reassigned to ${_picked!.name}')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarDust(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Text('Reassign cue',
                        style: VisualTheme.display(30, color: VisualTheme.inkOf(context))),
                    const SizedBox(height: 18),
                    BentoTile(
                      fill: VisualTheme.getCategoryColor(widget.item.category),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MOVING',
                              style: VisualTheme.tag(11,
                                  color: Colors.white.withValues(alpha: 0.75))),
                          const SizedBox(height: 8),
                          Text(widget.item.name,
                              style: VisualTheme.display(22, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(
                            'now in ${_current?.name ?? 'an unknown mission'}',
                            style: VisualTheme.body(13.5,
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    const SectionHead(title: 'Destination mission'),
                    if (_targets == null || _targets!.isEmpty)
                      BentoTile(
                        fill: VisualTheme.veilOf(context),
                        child: Text('No other mission to move into yet.',
                            style: VisualTheme.body(14, color: VisualTheme.mutedOf(context))),
                      )
                    else
                      ..._targets!.map((m) {
                        final count = _counts[m.id] ?? 0;
                        final on = _picked?.id == m.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BentoTile(
                            fill: on ? VisualTheme.nova.withValues(alpha: 0.12) : null,
                            onTap: () => setState(() => _picked = m),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: VisualTheme.nova.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(VisualTheme.trackIcon(m.room),
                                      size: 20, color: VisualTheme.nova),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.name,
                                          style: VisualTheme.heading(15.5,
                                              color: VisualTheme.inkOf(context),
                                              w: FontWeight.w700)),
                                      Text(
                                        '${m.code} · $count/${m.capacity}${count >= m.capacity ? ' · at target' : ''}',
                                        style: VisualTheme.body(12.5,
                                            color: VisualTheme.mutedOf(context)),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  on
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  color: on
                                      ? VisualTheme.nova
                                      : VisualTheme.mutedOf(context).withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SectionHead(title: 'Why the move?'),
                    BentoTile(
                      child: TextField(
                        key: const ValueKey('move_notes_field'),
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          hintText: 'e.g. regrouping for the Friday quiz',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const ValueKey('confirm_move_button'),
                      onPressed: _picked == null ? null : _move,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                      child: const Text('Log the reassign'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
