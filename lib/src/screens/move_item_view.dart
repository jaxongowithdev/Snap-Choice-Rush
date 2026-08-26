import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/loci_chrome.dart';

class MoveItemView extends StatefulWidget {
  final InventoryItemModel item;
  const MoveItemView({super.key, required this.item});

  @override
  State<MoveItemView> createState() => _MoveItemViewState();
}

class _MoveItemViewState extends State<MoveItemView> {
  final _storage = StorageManager.instance;
  final _notesController = TextEditingController();
  List<ContainerModel>? _containers;
  ContainerModel? _currentContainer;
  ContainerModel? _selectedContainer;
  Map<int, int> _itemCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final current = await _storage.getContainer(widget.item.containerId);
      final others = (await _storage.getAllContainers()).where((c) => c.id != widget.item.containerId).toList();
      final counts = <int, int>{};
      for (final c in others) {
        counts[c.id!] = await _storage.getItemCountInContainer(c.id!);
      }
      setState(() { _currentContainer = current; _containers = others; _itemCounts = counts; _isLoading = false; });
    } catch (e) {
      debugPrint('Error loading containers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _moveItem() async {
    if (_selectedContainer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick a destination room')));
      return;
    }
    final destCount = _itemCounts[_selectedContainer!.id] ?? 0;
    if (destCount >= _selectedContainer!.capacity) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('That room is full'),
          content: Text('"${_selectedContainer!.name}" has no open loci. File it anyway?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('File anyway')),
          ],
        ),
      );
      if (confirm != true) return;
    }
    await _storage.moveItem(widget.item.id!, widget.item.containerId, _selectedContainer!.id!, _notesController.text.trim().isEmpty ? null : _notesController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moved to ${_selectedContainer!.name}')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TRANSFER')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: VisualTheme.secondaryColor))
          : ListView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
              children: [
                Text('MOVING', textAlign: TextAlign.center, style: GoogleFonts.cinzel(letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.w700, color: VisualTheme.secondaryColor)),
                Text(widget.item.name, textAlign: TextAlign.center, style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.w700)),
                Text('${widget.item.category}  ·  ${widget.item.quantity}', textAlign: TextAlign.center),
                const SkyStamp(label: 'NOW IN'),
                Text(_currentContainer == null ? 'Unknown room' : '${_currentContainer!.name}  ·  ${_currentContainer!.room}', textAlign: TextAlign.center),
                const SkyStamp(label: 'MOVE INTO'),
                if (_containers == null || _containers!.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('No other rooms yet', textAlign: TextAlign.center))
                else
                  ..._containers!.map((c) {
                    final count = _itemCounts[c.id] ?? 0;
                    final selected = _selectedContainer?.id == c.id;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(selected ? '★' : '☆', style: TextStyle(color: selected ? VisualTheme.secondaryColor : null, fontSize: 16)),
                      title: Text(c.name, style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700)),
                      subtitle: Text('${c.room}  ·  $count/${c.capacity}${count >= c.capacity ? '  ·  full' : ''}'),
                      onTap: () => setState(() => _selectedContainer = c),
                    );
                  }),
                const SizedBox(height: 12),
                TextField(key: const ValueKey('move_notes_field'), controller: _notesController, decoration: const InputDecoration(labelText: 'Why the move?', hintText: 'e.g., Going into the myth gallery'), maxLines: 2),
                const SizedBox(height: 22),
                FilledButton(key: const ValueKey('confirm_move_button'), onPressed: _selectedContainer == null ? null : _moveItem, child: const Text('Log the transfer')),
              ],
            ),
    );
  }
}
