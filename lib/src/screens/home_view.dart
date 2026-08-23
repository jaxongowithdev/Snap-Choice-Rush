import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/hall_chrome.dart';
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
  List<ContainerModel> _books = [];
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
      final books = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in books) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final stars = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _books = books;
        _counts = counts;
        _stars = stars.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  String _beat(int i) {
    const beats = ['♩', '♪', '♫', '♬', '♩'];
    return beats[i % beats.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Etude Hall'),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.star_outline),
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
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                children: [
                  Text('this week’s programme', style: GoogleFonts.cormorantGaramond(fontSize: 32, fontStyle: FontStyle.italic, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The hall is quiet. Add a practice book before the next lesson.'
                        : '${_stats!['totalItems']} pieces across ${_stats!['totalContainers']} books.',
                    style: GoogleFonts.workSans(fontSize: 14, height: 1.45),
                  ),
                  const MovementLabel(label: 'THE BOOKS'),
                  if (_books.isEmpty)
                    Text('No books on the stand yet.\nStudio Czerny. Recital folder. Jazz fakebook.', style: GoogleFonts.workSans(height: 1.5))
                  else
                    ..._books.asMap().entries.map((e) {
                      final c = e.value;
                      final count = _counts[c.id] ?? 0;
                      return MeasureRow(
                        beat: _beat(e.key),
                        title: c.name,
                        meta: '${c.room}  ·  ${c.shelf}  ·  $count / ${c.capacity} bars',
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
                      child: Text('+ new book', style: GoogleFonts.cormorantGaramond(fontSize: 20, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('file a piece  →', style: GoogleFonts.workSans(color: VisualTheme.primaryColor, fontWeight: FontWeight.w600)),
                  ),
                  if (_stars.isNotEmpty) ...[
                    const MovementLabel(label: 'STARRED FOR THE RECITAL'),
                    ..._stars.map((item) => MeasureRow(
                          beat: '★',
                          title: item.name,
                          meta: '${item.category}  ·  ${item.condition}',
                          accent: VisualTheme.getCategoryColor(item.category),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                            _loadData();
                          },
                        )),
                  ],
                  const MovementLabel(label: 'A TEMPO'),
                  Text('Mark a part Torn when the seam gives out — restock before Saturday’s recital.', style: GoogleFonts.cormorantGaramond(fontSize: 18, fontStyle: FontStyle.italic, height: 1.4)),
                ],
              ),
            ),
    );
  }
}
