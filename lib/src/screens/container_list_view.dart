import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import 'container_detail_view.dart';
import 'container_form_view.dart';

class ContainerListView extends StatefulWidget {
  const ContainerListView({super.key});

  @override
  State<ContainerListView> createState() => _ContainerListViewState();
}

class _ContainerListViewState extends State<ContainerListView> {
  final _storage = StorageManager.instance;
  List<ContainerModel>? _containers;
  Map<int, int> _itemCounts = {};
  bool _isLoading = true;
  String _sortBy = 'updated';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadContainers();
  }

  Future<void> _loadContainers() async {
    setState(() => _isLoading = true);
    try {
      final containers = await _storage.getAllContainers(sortBy: _sortBy);
      final counts = <int, int>{};
      for (final c in containers) {
        counts[c.id!] = await _storage.getItemCountInContainer(c.id!);
      }
      setState(() {
        _containers = containers;
        _itemCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading containers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _open(ContainerModel c) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
    _loadContainers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carts'),
        actions: [
          IconButton(icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view), onPressed: () => setState(() => _isGridView = !_isGridView)),
          PopupMenuButton<String>(
            onSelected: (v) { setState(() => _sortBy = v); _loadContainers(); },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'name', child: Text('By name')),
              PopupMenuItem(value: 'room', child: Text('By room')),
              PopupMenuItem(value: 'updated', child: Text('Last opened')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _containers == null || _containers!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 48),
                        const SizedBox(height: 12),
                        Text('No carts staged', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('Start a front rail, a back-bar shelf, or the guest cart.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(onRefresh: _loadContainers, child: _isGridView ? _grid() : _list()),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('fab_add_container'),
        onPressed: () async {
          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
          if (r == true) _loadContainers();
        },
        icon: const Icon(Icons.add),
        label: const Text('Cart'),
      ),
    );
  }

  Widget _grid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.9, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _containers!.length,
      itemBuilder: (_, i) {
        final c = _containers![i];
        final count = _itemCounts[c.id] ?? 0;
        final pct = c.capacity > 0 ? (count / c.capacity * 100).round() : 0;
        return Card(
          child: InkWell(
            onTap: () => _open(c),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.code, style: GoogleFonts.sora(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(c.name, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700), maxLines: 2),
                  const Spacer(),
                  Text('${c.room} / ${c.shelf}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: pct / 100, minHeight: 5, backgroundColor: VisualTheme.mist, color: VisualTheme.secondaryColor),
                  const SizedBox(height: 6),
                  Text('$count / ${c.capacity} bottles'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _list() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _containers!.length,
      itemBuilder: (_, i) {
        final c = _containers![i];
        final count = _itemCounts[c.id] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: ListTile(
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${c.code}  ·  ${c.room} / ${c.shelf}\n$count / ${c.capacity} bottles'),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _open(c),
            ),
          ),
        );
      },
    );
  }
}
