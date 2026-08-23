import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick a destination tray')));
      return;
    }
    final destCount = _itemCounts[_selectedContainer!.id] ?? 0;
    if (destCount >= _selectedContainer!.capacity) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('That tray is full'),
          content: Text('"${_selectedContainer!.name}" has no open slots. File it anyway?'),
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
      appBar: AppBar(title: const Text('Move piece')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MOVING', style: GoogleFonts.lexend(color: VisualTheme.secondaryColor, letterSpacing: 1.4, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(widget.item.name, style: GoogleFonts.sourceSerif4(fontSize: 24, fontWeight: FontWeight.w700)),
                        Text('${widget.item.category} · ${widget.item.quantity}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: VisualTheme.primaryColor, borderRadius: BorderRadius.circular(18)),
                  child: Text('Now in ${_currentContainer?.name ?? 'unknown'}${_currentContainer != null ? ' · ${_currentContainer!.room}' : ''}', style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                Text('Move into', style: GoogleFonts.sourceSerif4(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                if (_containers == null || _containers!.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(28), child: Center(child: Text('No other trays yet'))))
                else
                  ..._containers!.map((c) {
                    final count = _itemCounts[c.id] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        color: _selectedContainer?.id == c.id ? VisualTheme.sand : null,
                        child: RadioListTile<int>(
                          value: c.id!,
                          groupValue: _selectedContainer?.id,
                          onChanged: (_) => setState(() => _selectedContainer = c),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${c.room} · ${c.shelf}  ·  $count/${c.capacity}${count >= c.capacity ? '  ·  full' : ''}'),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                TextField(key: const ValueKey('move_notes_field'), controller: _notesController, decoration: const InputDecoration(labelText: 'Why the move?', hintText: 'e.g., Going into the Monday kit', prefixIcon: Icon(Icons.notes)), maxLines: 2),
                const SizedBox(height: 22),
                FilledButton.icon(key: const ValueKey('confirm_move_button'), onPressed: _selectedContainer == null ? null : _moveItem, icon: const Icon(Icons.swap_horiz), label: const Text('Move piece')),
              ],
            ),
    );
  }
}
