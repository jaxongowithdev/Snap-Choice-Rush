import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/atlas_chrome.dart';
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
        content: Text(updated.isFavorite ? 'Starred for the unit' : 'Removed from the star list'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('File this pin away?'),
        content: const Text('It will leave the atlas catalog.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('File away')),
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
    if (_item == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Pin not found')));

    return Scaffold(
      appBar: AppBar(
        title: Text(_item!.category),
        actions: [
          IconButton(
            key: const ValueKey('favorite_toggle'),
            icon: Icon(_item!.isFavorite ? Icons.north : Icons.north_outlined, color: _item!.isFavorite ? VisualTheme.secondaryColor : null),
            onPressed: _toggleFavorite,
          ),
          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'move', child: Text('Move to another folio')),
              PopupMenuItem(value: 'edit', child: Text('Edit pin')),
              PopupMenuItem(value: 'delete', child: Text('File away')),
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
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: [
          if (_item!.photoPath != null && _item!.photoPath!.isNotEmpty) ...[
            Image.file(File(_item!.photoPath!), height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 120, color: VisualTheme.foam, child: const Center(child: Icon(Icons.broken_image)))),
            const SizedBox(height: 16),
          ],
          Text(_item!.name, style: GoogleFonts.fraunces(fontSize: 32, fontWeight: FontWeight.w600, height: 1.05)),
          const SizedBox(height: 14),
          Text('count  ${_item!.quantity}     wear  ${_item!.condition}', style: GoogleFonts.outfit(fontSize: 13)),
          if (_item!.estimatedValue != null) Text('replace  \$${_item!.estimatedValue}', style: GoogleFonts.outfit(fontSize: 13)),
          if (_item!.notes != null && _item!.notes!.isNotEmpty) ...[
            const LegendLabel(label: 'FIELD NOTE'),
            Text(_item!.notes!, style: GoogleFonts.fraunces(fontSize: 18, fontStyle: FontStyle.italic)),
          ],
          const LegendLabel(label: 'SITS IN'),
          BearingRow(
            bearing: 'N',
            title: _container?.name ?? 'Unknown folio',
            meta: _container != null ? '${_container!.room}  ·  ${_container!.shelf}  ·  ${_container!.code}' : '',
            accent: VisualTheme.primaryColor,
            onTap: _container == null ? () {} : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: _container!.id!))),
          ),
        ],
      ),
    );
  }
}
