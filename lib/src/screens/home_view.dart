import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/trace_chrome.dart';
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
  List<ContainerModel> _sets = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _pins = [];
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
      final sets = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in sets) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final pins = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _sets = sets;
        _counts = counts;
        _pins = pins.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('TRACE HALL'),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.push_pin_outlined),
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
          ? const Center(child: CircularProgressIndicator(color: VisualTheme.primaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  TitleBlock(
                    project: 'TODAY’S BOARD',
                    note: (_stats?['totalItems'] ?? 0) == 0
                        ? 'The board is empty. Mix a set before critique.'
                        : '${_stats!['totalItems']} plates across ${_stats!['totalContainers']} sets.',
                  ),
                  const SheetStamp(label: 'WORKING SETS'),
                  if (_sets.isEmpty)
                    Text('No sets pinned yet.\nStudio folio. Site roll. Critique crate.', style: GoogleFonts.sourceSerif4(height: 1.5))
                  else
                    ..._sets.map((c) {
                      final count = _counts[c.id] ?? 0;
                      return DrawingPlate(
                        kind: c.code,
                        title: c.name,
                        meta: '${c.room}  ·  $count / ${c.capacity} boards',
                        accent: VisualTheme.primaryColor,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                          _loadData();
                        },
                      );
                    }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const ValueKey('add_box_button'),
                      onPressed: () async {
                        final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                        if (r == true) _loadData();
                      },
                      child: Text('+ NEW SET', style: GoogleFonts.barlowCondensed(fontSize: 16, letterSpacing: 1.2, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('FILE A PLATE  →', style: GoogleFonts.barlowCondensed(color: VisualTheme.primaryColor, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ),
                  if (_pins.isNotEmpty) ...[
                    const SheetStamp(label: 'PINNED FOR CRITIQUE'),
                    ..._pins.map((item) => DrawingPlate(
                          kind: item.category,
                          title: item.name,
                          meta: '${item.condition}  ·  ${item.quantity}',
                          accent: VisualTheme.getCategoryColor(item.category),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                            _loadData();
                          },
                        )),
                  ],
                  const SheetStamp(label: 'STUDIO NOTE'),
                  Text('Mark a plate Smudged when the graphite lifts — reprint before Friday’s pin-up.', style: GoogleFonts.sourceSerif4(fontSize: 16, fontStyle: FontStyle.italic, height: 1.4)),
                ],
              ),
            ),
    );
  }
}
