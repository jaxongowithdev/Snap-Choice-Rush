import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
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
        title: const Text('Clear this well?'),
        content: const Text('Every bottle filed here will be removed.'),
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
    if (_container == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Well not found')));

    final count = _items?.length ?? 0;
    final pct = _container!.capacity > 0 ? (count / _container!.capacity * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_container!.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit well')),
              PopupMenuItem(value: 'delete', child: Text('Clear well')),
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
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: VisualTheme.primaryColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_container!.code, style: GoogleFonts.outfit(color: VisualTheme.accentColor, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(_container!.name, style: GoogleFonts.literata(fontSize: 28, fontWeight: FontWeight.w600, color: VisualTheme.cream)),
                  const SizedBox(height: 8),
                  Text('${_container!.room} / ${_container!.shelf}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: pct / 100, minHeight: 6, backgroundColor: Colors.white24, color: VisualTheme.secondaryColor, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 8),
                  Text('$count / ${_container!.capacity} bottles  ·  $pct% packed', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Text('Bottles ($count)', style: GoogleFonts.literata(fontSize: 22, fontWeight: FontWeight.w600))),
                FilledButton.icon(
                  key: const ValueKey('add_item_button'),
                  onPressed: () async {
                    final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemFormView(preselectedContainerId: widget.containerId)));
                    if (r == true) _loadData();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Bottle'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_items == null || _items!.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(28), child: Center(child: Text('Nothing filed here yet'))))
            else
              ..._items!.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.water_drop, color: VisualTheme.getCategoryColor(item.category)),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${item.category} · ${item.quantity} · ${item.condition}'),
                        trailing: const Icon(Icons.arrow_forward, size: 18),
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                          _loadData();
                        },
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
