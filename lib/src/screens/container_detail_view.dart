import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/hall_chrome.dart';
import 'container_form_view.dart';
import 'item_form_view.dart';
import 'item_detail_view.dart';

class ContainerDetailView extends StatefulWidget {
  final int containerId;
  const ContainerDetailView({super.key, required this.containerId});

  @override
  State<ContainerDetailView> createState() => _ContainerDetailViewState();
}

class _ContainerDetailViewState extends State<ContainerDetailView> {
  final _storage = StorageManager.instance;
  ContainerModel? _container;
  List<InventoryItemModel>? _items;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final container = await _storage.getContainer(widget.containerId);
      final items = await _storage.getItemsByContainer(widget.containerId);
      setState(() {
        _container = container;
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading container: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteContainer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear this book?'),
        content: const Text('Every piece filed here will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Clear')),
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
    if (_isLoading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_container == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Book not found')));

    final count = _items?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_container!.code),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit book')),
              PopupMenuItem(value: 'delete', child: Text('Clear book')),
            ],
            onSelected: (v) {
              if (v == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerFormView(container: _container))).then((r) { if (r == true) _loadData(); });
              } else if (v == 'delete') {
                _deleteContainer();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(_container!.name, style: GoogleFonts.cormorantGaramond(fontSize: 34, fontWeight: FontWeight.w600, height: 1.05)),
            const SizedBox(height: 6),
            Text('${_container!.room}  ·  ${_container!.shelf}  ·  $count / ${_container!.capacity} bars', style: GoogleFonts.workSans(fontSize: 13)),
            MovementLabel(label: 'PIECES  ·  $count'),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const ValueKey('add_item_button'),
                onPressed: () async {
                  final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemFormView(preselectedContainerId: widget.containerId)));
                  if (r == true) _loadData();
                },
                child: Text('+ file a piece', style: GoogleFonts.cormorantGaramond(fontSize: 20, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
              ),
            ),
            if (_items == null || _items!.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Nothing filed in this book yet'))
            else
              ..._items!.asMap().entries.map((e) => MeasureRow(
                    beat: '${e.key + 1}',
                    title: e.value.name,
                    meta: '${e.value.category}  ·  ${e.value.quantity}  ·  ${e.value.condition}',
                    accent: VisualTheme.getCategoryColor(e.value.category),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: e.value.id!)));
                      _loadData();
                    },
                  )),
          ],
        ),
      ),
    );
  }
}
