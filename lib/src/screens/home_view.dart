import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/spine_chrome.dart';
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
  List<ContainerModel> _shelves = [];
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
      final shelves = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in shelves) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final pins = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _shelves = shelves;
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
        title: const Text('Time Spine'),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.flag_outlined),
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
                padding: const EdgeInsets.fromLTRB(16, 4, 12, 28),
                children: [
                  Text('this century', style: GoogleFonts.cormorantGaramond(fontSize: 32, fontStyle: FontStyle.italic, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The hall is empty. Raise a shelf before the unit test.'
                        : '${_stats!['totalItems']} pieces across ${_stats!['totalContainers']} shelves.',
                    style: GoogleFonts.publicSans(fontSize: 14, height: 1.45),
                  ),
                  const AccessionLabel(label: 'THE GALLERY'),
                  if (_shelves.isEmpty)
                    Text('No shelves raised yet.\nAncient hall. Local crate. Review cart.', style: GoogleFonts.publicSans(height: 1.5))
                  else
                    ...List.generate(_shelves.length, (i) {
                      final c = _shelves[i];
                      final count = _counts[c.id] ?? 0;
                      return ExhibitPlaque(
                        kind: c.code,
                        title: c.name,
                        meta: '${c.room}  ·  $count / ${c.capacity} pieces',
                        accent: i.isEven ? VisualTheme.primaryColor : VisualTheme.secondaryColor,
                        offsetRight: i.isOdd,
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
                      child: Text('+ new shelf', style: GoogleFonts.cormorantGaramond(fontSize: 18, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('file a piece  →', style: GoogleFonts.publicSans(color: VisualTheme.primaryColor, fontWeight: FontWeight.w800)),
                  ),
                  if (_pins.isNotEmpty) ...[
                    const AccessionLabel(label: 'PINNED FOR THE TEST'),
                    ..._pins.map((item) => ExhibitPlaque(
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
                  const AccessionLabel(label: 'CURATOR NOTE'),
                  Text('Mark a piece Fragile when the paper foxes — restock before Friday’s seminar.', style: GoogleFonts.cormorantGaramond(fontSize: 17, fontStyle: FontStyle.italic, height: 1.4)),
                ],
              ),
            ),
    );
  }
}
