import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/booth_chrome.dart';
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
  List<ContainerModel> _crates = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _cast = [];
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
      final crates = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in crates) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final cast = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _crates = crates;
        _counts = counts;
        _cast = cast.take(5).toList();
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
        title: const Text('Prompt Booth'),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.theater_comedy_outlined),
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
                padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
                children: [
                  Text(
                    'this week’s bill',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(fontSize: 13, letterSpacing: 2.8, color: VisualTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The house is dark. Hang a script crate before the next rehearsal.'
                        : '${_stats!['totalItems']} cues across ${_stats!['totalContainers']} crates.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.libreFranklin(fontSize: 14, height: 1.45),
                  ),
                  const BillLabel(label: 'THE CRATES'),
                  if (_crates.isEmpty)
                    Text('No crates in the wings yet.\nRehearsal book. Costume rack. Prop table.', textAlign: TextAlign.center, style: GoogleFonts.libreFranklin(height: 1.5))
                  else
                    ..._crates.map((c) {
                      final count = _counts[c.id] ?? 0;
                      return PlaybillBlock(
                        title: c.name,
                        meta: '${c.room}  ·  ${c.shelf}  ·  $count / ${c.capacity} cues',
                        accent: VisualTheme.secondaryColor,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                          _loadData();
                        },
                      );
                    }),
                  TextButton(
                    key: const ValueKey('add_box_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('+ new crate', style: GoogleFonts.cinzel(fontSize: 14, letterSpacing: 1.2, color: VisualTheme.primaryColor)),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('file a cue  →', style: GoogleFonts.libreFranklin(color: VisualTheme.primaryColor, fontWeight: FontWeight.w600)),
                  ),
                  if (_cast.isNotEmpty) ...[
                    const BillLabel(label: 'CAST FOR OPENING NIGHT'),
                    ..._cast.map((item) => PlaybillBlock(
                          title: item.name,
                          meta: '${item.category}  ·  ${item.condition}',
                          accent: VisualTheme.getCategoryColor(item.category),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                            _loadData();
                          },
                        )),
                  ],
                  const BillLabel(label: 'NOTES FROM THE WINGS'),
                  Text('Mark a costume Worn when the seam gives — restock before Friday’s dress.', textAlign: TextAlign.center, style: GoogleFonts.cinzel(fontSize: 15, height: 1.45)),
                ],
              ),
            ),
    );
  }
}
