import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/leaf_chrome.dart';
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
  List<ContainerModel> _presses = [];
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
      final presses = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in presses) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final pins = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _presses = presses;
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
        title: const Text('Press Leaf'),
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
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                children: [
                  Text('this week’s walk', style: GoogleFonts.newsreader(fontSize: 30, fontStyle: FontStyle.italic, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The press is empty. Add a field folio before the next hike.'
                        : '${_stats!['totalItems']} slips across ${_stats!['totalContainers']} presses.',
                    style: GoogleFonts.nunitoSans(fontSize: 15, height: 1.45),
                  ),
                  const TrailLabel(label: 'THE PRESSES'),
                  if (_presses.isEmpty)
                    Text('No presses packed yet.\nField satchel. Classroom folio. Window sill.', style: GoogleFonts.nunitoSans(height: 1.5))
                  else
                    ..._presses.map((c) {
                      final count = _counts[c.id] ?? 0;
                      return SpecimenCard(
                        kind: c.code,
                        title: c.name,
                        meta: '${c.room}  ·  ${c.shelf}  ·  $count / ${c.capacity} slips',
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
                      child: Text('+ new press', style: GoogleFonts.newsreader(fontSize: 18, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('file a slip  →', style: GoogleFonts.nunitoSans(color: VisualTheme.primaryColor, fontWeight: FontWeight.w800)),
                  ),
                  if (_pins.isNotEmpty) ...[
                    const TrailLabel(label: 'PINNED FOR THE HIKE'),
                    ..._pins.map((item) => SpecimenCard(
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
                  const TrailLabel(label: 'FIELD NOTE'),
                  Text('Mark a slip Brittle when the vein snaps — restock before Friday’s hike.', style: GoogleFonts.newsreader(fontSize: 17, fontStyle: FontStyle.italic, height: 1.4)),
                ],
              ),
            ),
    );
  }
}
