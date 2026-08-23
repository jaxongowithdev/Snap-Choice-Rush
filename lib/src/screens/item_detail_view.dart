import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/slate_chrome.dart';
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
        content: Text(updated.isFavorite ? 'Starred for the next bell' : 'Removed from the star list'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('File this piece away?'),
        content: const Text('It will leave the period board.'),
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
    if (_item == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Piece not found')));

    return Scaffold(
      appBar: AppBar(
        title: Text(_item!.category.toUpperCase(), style: GoogleFonts.syne(fontSize: 13, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            key: const ValueKey('favorite_toggle'),
            icon: Icon(_item!.isFavorite ? Icons.star : Icons.star_outline, color: _item!.isFavorite ? VisualTheme.accentColor : null),
            onPressed: _toggleFavorite,
          ),
          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'move', child: Text('Shift to another period')),
              PopupMenuItem(value: 'edit', child: Text('Edit piece')),
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (_item!.photoPath != null && _item!.photoPath!.isNotEmpty) ...[
            Image.file(
              File(_item!.photoPath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 120, color: VisualTheme.mist, child: const Center(child: Icon(Icons.broken_image))),
            ),
            const SizedBox(height: 16),
          ],
          Text(_item!.name, style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, height: 1.05)),
          const SizedBox(height: 16),
          _kv('COUNT', _item!.quantity.toString()),
          _kv('STATUS', _item!.condition),
          if (_item!.estimatedValue != null) _kv('REPLACE', '\$${_item!.estimatedValue}'),
          if (_item!.notes != null && _item!.notes!.isNotEmpty) ...[
            const SlateRule(label: 'BOARD NOTE'),
            Text(_item!.notes!),
          ],
          const SlateRule(label: 'SITS IN'),
          MaterialLine(
            accent: VisualTheme.secondaryColor,
            title: _container?.name ?? 'Unknown period',
            subtitle: _container != null ? '${_container!.room}  ·  ${_container!.shelf}  ·  ${_container!.code}' : '',
            onTap: _container == null ? () {} : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: _container!.id!))),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(k, style: GoogleFonts.syne(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: VisualTheme.secondaryColor))),
          Text(v, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
