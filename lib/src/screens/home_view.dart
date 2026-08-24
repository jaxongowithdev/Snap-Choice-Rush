import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/atlas_chrome.dart';
import 'container_detail_view.dart';
import 'item_form_view.dart';
import 'search_view.dart';
import 'container_form_view.dart';
import 'favorites_view.dart';
import 'item_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _storage = StorageManager.instance;
  Map<String, int>? _stats;
  List<ContainerModel> _folios = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _stars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _storage.getStatistics();
      final folios = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in folios) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final stars = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _folios = folios;
        _counts = counts;
        _stars = stars.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  String _bearing(int i) {
    const pts = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return pts[i % pts.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Meridian Desk'),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.north),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesView())).then((_) => _loadData());
            },
          ),
          IconButton(
            key: const ValueKey('search_button'),
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchView()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
                children: [
                  Text('WEEK’S ROUTE', style: GoogleFonts.outfit(fontSize: 11, letterSpacing: 2.2, fontWeight: FontWeight.w700, color: VisualTheme.primaryColor)),
                  const SizedBox(height: 6),
                  Text('this week’s expedition', style: GoogleFonts.fraunces(fontSize: 30, fontStyle: FontStyle.italic, height: 1.1)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _statChip('N', '${_stats?['totalContainers'] ?? 0}', 'folios'),
                      const SizedBox(width: 8),
                      _statChip('E', '${_stats?['totalItems'] ?? 0}', 'pins'),
                      const SizedBox(width: 8),
                      _statChip('S', '${_stars.length}', 'starred'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The desk is empty. Add a map folio before the next unit.'
                        : '${_stats!['totalItems']} pins across ${_stats!['totalContainers']} folios.',
                    style: GoogleFonts.outfit(fontSize: 14, height: 1.45),
                  ),
                  const LegendLabel(label: 'THE FOLIOS'),
                  if (_folios.isEmpty)
                    Text('No folios plotted yet.\nWall maps. Field satchel. Globe cabinet.', style: GoogleFonts.outfit(height: 1.5))
                  else
                    ..._folios.asMap().entries.map((e) {
                      final c = e.value;
                      final count = _counts[c.id] ?? 0;
                      return BearingRow(
                        bearing: _bearing(e.key),
                        title: c.name,
                        meta: '${c.room}  ·  ${c.shelf}  ·  $count / ${c.capacity} pins',
                        accent: VisualTheme.secondaryColor,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                          _loadData();
                        },
                      );
                    }),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const ValueKey('add_box_button'),
                      onPressed: () async {
                        final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                        if (r == true) _loadData();
                      },
                      child: Text('+ new folio', style: GoogleFonts.fraunces(fontSize: 18, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('file a pin  →', style: GoogleFonts.outfit(color: VisualTheme.primaryColor, fontWeight: FontWeight.w600)),
                  ),
                  if (_stars.isNotEmpty) ...[
                    const LegendLabel(label: 'STARRED FOR THE UNIT'),
                    ..._stars.map((item) => BearingRow(
                          bearing: '★',
                          title: item.name,
                          meta: '${item.category}  ·  ${item.condition}',
                          accent: VisualTheme.getCategoryColor(item.category),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                            _loadData();
                          },
                        )),
                  ],
                  const LegendLabel(label: 'FIELD NOTE'),
                  Text('Mark a chart Folded when it leaves the wall — restock before Friday’s unit test.', style: GoogleFonts.fraunces(fontSize: 17, fontStyle: FontStyle.italic, height: 1.4)),
                ],
              ),
            ),
    );
  }

  Widget _statChip(String bearing, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: VisualTheme.primaryColor.withValues(alpha: 0.28)),
        ),
        child: Column(
          children: [
            Text(bearing, style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: VisualTheme.secondaryColor)),
            Text(value, style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600)),
            Text(label, style: GoogleFonts.outfit(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
