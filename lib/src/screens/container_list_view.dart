import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/bench_chrome.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('RACKS'),
        actions: [
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
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 28, height: 28, decoration: BoxDecoration(border: Border.all(color: VisualTheme.secondaryColor, width: 2))),
                        const SizedBox(height: 12),
                        Text('No racks staged', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('Start Station A, the prep room, or a safety crate.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadContainers,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: _containers!.length,
                    itemBuilder: (_, i) {
                      final c = _containers![i];
                      final count = _itemCounts[c.id] ?? 0;
                      return WellTile(
                        code: c.code,
                        title: c.name,
                        meta: '${c.room}  ·  $count/${c.capacity}',
                        fill: c.capacity > 0 ? count / c.capacity : 0,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                          _loadContainers();
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('fab_add_container'),
        onPressed: () async {
          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
          if (r == true) _loadContainers();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
