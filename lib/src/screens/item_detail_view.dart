import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import 'item_form_view.dart';
import 'container_detail_view.dart';
import 'move_item_view.dart';

class ItemDetailView extends StatefulWidget {
  final int itemId;
  const ItemDetailView({super.key, required this.itemId});

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  final _storage = StorageManager.instance;
  InventoryItemModel? _item;
  ContainerModel? _container;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final item = await _storage.getItem(widget.itemId);
      if (item != null) {
        final container = await _storage.getContainer(item.containerId);
        setState(() {
          _item = item;
          _container = container;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading item: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_item == null) return;
    final updated = _item!.copyWith(isFavorite: !_item!.isFavorite);
    await _storage.updateItem(updated);
    setState(() => _item = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(updated.isFavorite ? 'Pinned to this week’s desk' : 'Removed from this week’s desk'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Retire this piece?'),
        content: const Text('It will leave the lesson catalog.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Retire')),
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
    if (_isLoading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_item == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Piece not found')));

    return Scaffold(
      appBar: AppBar(
        title: Text(_item!.name),
        actions: [
          IconButton(
            key: const ValueKey('favorite_toggle'),
            icon: Icon(_item!.isFavorite ? Icons.push_pin : Icons.push_pin_outlined, color: _item!.isFavorite ? VisualTheme.secondaryColor : null),
            onPressed: _toggleFavorite,
          ),
          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'move', child: Text('Move to another tray')),
              PopupMenuItem(value: 'edit', child: Text('Edit piece')),
              PopupMenuItem(value: 'delete', child: Text('Retire piece')),
            ],
            onSelected: (v) {
              if (v == 'move') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MoveItemView(item: _item!))).then((r) { if (r == true) _loadData(); });
              } else if (v == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ItemFormView(item: _item))).then((r) { if (r == true) _loadData(); });
              } else if (v == 'delete') {
                _deleteItem();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_item!.photoPath != null && _item!.photoPath!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_item!.photoPath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(height: 140, color: VisualTheme.sand, child: const Center(child: Icon(Icons.broken_image))),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(_item!.category.toUpperCase(), style: GoogleFonts.lexend(color: VisualTheme.getCategoryColor(_item!.category), letterSpacing: 1.4, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(_item!.name, style: GoogleFonts.sourceSerif4(fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _row('Count', _item!.quantity.toString()),
                  _row('Wear', _item!.condition),
                  if (_item!.estimatedValue != null) _row('Replace', '\$${_item!.estimatedValue}'),
                  if (_item!.notes != null && _item!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text('Lesson note', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(_item!.notes!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: Text(_container?.name ?? 'Unknown tray'),
              subtitle: _container != null ? Text('${_container!.room} · ${_container!.shelf}\nMark: ${_container!.code}') : null,
              isThreeLine: _container != null,
              trailing: const Icon(Icons.arrow_forward, size: 18),
              onTap: _container == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: _container!.id!))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [SizedBox(width: 90, child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]),
    );
  }
}
