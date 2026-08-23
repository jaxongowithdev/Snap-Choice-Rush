import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/binder_chrome.dart';
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
  List<ContainerModel> _spines = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _flags = [];
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
      final spines = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final s in spines) {
        counts[s.id!] = await _storage.getItemCountInContainer(s.id!);
      }
      final flags = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _spines = spines;
        _counts = counts;
        _flags = flags.take(4).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  String _folio(int i) => (i + 1).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('CONTENTS', style: GoogleFonts.ibmPlexMono(fontSize: 12, letterSpacing: 2.2, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.bookmark_border),
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
                padding: const EdgeInsets.fromLTRB(28, 4, 20, 32),
                children: [
                  Text('Cram Binder', style: GoogleFonts.libreBaskerville(fontSize: 34, fontWeight: FontWeight.w700, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The index is blank. Add a subject spine before exam week.'
                        : '${_stats!['totalItems']} drills  ·  ${_stats!['totalContainers']} spines  ·  ${(_stats!['totalContainers'] ?? 0) - (_stats!['emptyContainers'] ?? 0)} in play',
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.45),
                  ),
                  const Colophon(label: 'SUBJECT INDEX'),
                  if (_spines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('No spines yet.\nSAT Math. AP Bio. Friday mock.', style: GoogleFonts.ibmPlexSans(height: 1.5)),
                    )
                  else
                    ..._spines.asMap().entries.map((e) {
                      final c = e.value;
                      final count = _counts[c.id] ?? 0;
                      return TocRow(
                        indexLabel: _folio(e.key),
                        title: c.name,
                        meta: '${c.code}   ${c.room} · ${c.shelf}   $count/${c.capacity}',
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                          _loadData();
                        },
                      );
                    }),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const ValueKey('add_box_button'),
                      onPressed: () async {
                        final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                        if (r == true) _loadData();
                      },
                      child: Text('+ NEW SPINE', style: GoogleFonts.ibmPlexMono(color: VisualTheme.primaryColor, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('FILE A DRILL →', style: GoogleFonts.ibmPlexMono(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w600)),
                  ),
                  if (_flags.isNotEmpty) ...[
                    const Colophon(label: 'FLAGGED FOR TONIGHT'),
                    ..._flags.map((item) => FlagLine(
                          accent: VisualTheme.getCategoryColor(item.category),
                          title: item.name,
                          subtitle: '${item.category}  ·  ${item.condition}',
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                            _loadData();
                          },
                        )),
                  ],
                  const Colophon(label: 'MARGINALIA'),
                  Text('Mark a deck Worn when the corners go soft — restock before the next mock.', style: GoogleFonts.libreBaskerville(fontSize: 14, fontStyle: FontStyle.italic, height: 1.45)),
                ],
              ),
            ),
    );
  }
}
