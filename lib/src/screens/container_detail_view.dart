import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/binder_chrome.dart';
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
        title: const Text('Clear this spine?'),
        content: const Text('Every drill filed here will be removed.'),
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
    if (_container == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Spine not found')));

    final count = _items?.length ?? 0;
    final pct = _container!.capacity > 0 ? (count / _container!.capacity * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_container!.code, style: GoogleFonts.ibmPlexMono(fontSize: 14, fontWeight: FontWeight.w600)),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit spine')),
              PopupMenuItem(value: 'delete', child: Text('Clear spine')),
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
            Text(_container!.name, style: GoogleFonts.libreBaskerville(fontSize: 32, fontWeight: FontWeight.w700, height: 1.1)),
            const SizedBox(height: 6),
            Text('${_container!.room}  ·  ${_container!.shelf}  ·  $count/${_container!.capacity} pages  ·  $pct%', style: GoogleFonts.ibmPlexMono(fontSize: 12)),
            Colophon(label: 'DRILLS  ·  $count'),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const ValueKey('add_item_button'),
                onPressed: () async {
                  final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemFormView(preselectedContainerId: widget.containerId)));
                  if (r == true) _loadData();
                },
                child: Text('+ FILE A DRILL', style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600, color: VisualTheme.primaryColor)),
              ),
            ),
            if (_items == null || _items!.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('Nothing filed in this spine yet'))
            else
              ..._items!.map((item) => FlagLine(
                    accent: VisualTheme.getCategoryColor(item.category),
                    title: item.name,
                    subtitle: '${item.category}  ·  ${item.quantity}  ·  ${item.condition}',
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                      _loadData();
                    },
                  )),
          ],
        ),
      ),
    );
  }
}
