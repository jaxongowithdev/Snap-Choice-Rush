import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/bench_chrome.dart';
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
        title: const Text('Clear this rack?'),
        content: const Text('Every set filed here will be removed.'),
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
    if (_container == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Rack not found')));

    final count = _items?.length ?? 0;
    final pct = _container!.capacity > 0 ? count / _container!.capacity : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_container!.code),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit rack')),
              PopupMenuItem(value: 'delete', child: Text('Clear rack')),
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(_container!.name, style: GoogleFonts.spaceGrotesk(fontSize: 30, fontWeight: FontWeight.w700, height: 1.05)),
            const SizedBox(height: 6),
            Text('${_container!.room}  ·  ${_container!.shelf}', style: GoogleFonts.ibmPlexMono(fontSize: 12)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: pct.clamp(0, 1), minHeight: 3, backgroundColor: Theme.of(context).dividerColor, color: VisualTheme.secondaryColor),
            const SizedBox(height: 6),
            Text('$count / ${_container!.capacity} wells  ·  ${(pct * 100).round()}%', style: GoogleFonts.ibmPlexMono(fontSize: 11)),
            SpecLabel(label: 'SETS  ·  $count'),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const ValueKey('add_item_button'),
                onPressed: () async {
                  final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemFormView(preselectedContainerId: widget.containerId)));
                  if (r == true) _loadData();
                },
                child: Text('+ FILE A SET', style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600, color: VisualTheme.secondaryColor)),
              ),
            ),
            if (_items == null || _items!.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Nothing filed in this rack yet'))
            else
              ..._items!.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(width: 8, height: 8, color: VisualTheme.getCategoryColor(item.category)),
                    title: Text(item.name, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
                    subtitle: Text('${item.category}  ·  ${item.quantity}  ·  ${item.condition}', style: GoogleFonts.ibmPlexMono(fontSize: 11)),
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
