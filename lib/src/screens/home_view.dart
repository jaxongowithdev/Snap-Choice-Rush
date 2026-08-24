import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/stanza_chrome.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Ink Stanza'),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.auto_awesome_outlined),
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
                padding: const EdgeInsets.fromLTRB(20, 4, 16, 28),
                children: [
                  Text('this week’s reading', style: GoogleFonts.spectral(fontSize: 32, fontStyle: FontStyle.italic, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The desk is quiet. Hang a folio before the next workshop.'
                        : '${_stats!['totalItems']} verses across ${_stats!['totalContainers']} folios.',
                    style: GoogleFonts.figtree(fontSize: 14, height: 1.45),
                  ),
                  const SealLabel(label: 'THE FOLIOS'),
                  if (_folios.isEmpty)
                    Text('No folios hanging yet.\nClass set. Reading night. Journal drawer.', style: GoogleFonts.figtree(height: 1.5))
                  else
                    ..._folios.map((c) {
                      final count = _counts[c.id] ?? 0;
                      return CoupletCard(
                        kind: c.code,
                        title: c.name,
                        meta: '${c.room}  ·  ${c.shelf}  ·  $count / ${c.capacity} lines',
                        accent: VisualTheme.secondaryColor,
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
                      child: Text('+ hang a folio', style: GoogleFonts.spectral(fontSize: 18, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('file a verse  →', style: GoogleFonts.figtree(color: VisualTheme.primaryColor, fontWeight: FontWeight.w600)),
                  ),
                  if (_stars.isNotEmpty) ...[
                    const SealLabel(label: 'SEALED FOR THE READING'),
                    ..._stars.map((item) => CoupletCard(
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
                  const SealLabel(label: 'MARGINALIA'),
                  Text('Mark a leaf Creased when the fold shows — restock before Friday’s reading.', style: GoogleFonts.spectral(fontSize: 17, fontStyle: FontStyle.italic, height: 1.4)),
                ],
              ),
            ),
    );
  }
}
