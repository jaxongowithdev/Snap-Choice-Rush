import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/loci_chrome.dart';
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
  List<ContainerModel> _rooms = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _pins = [];
  bool _isLoading = true;

  static const _orbColors = [
    Color(0xFFE8C547),
    Color(0xFF7EC8E3),
    Color(0xFF6B4C9A),
    Color(0xFFC45A9A),
    Color(0xFF5A8A7A),
    Color(0xFFB08C5A),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _storage.getStatistics();
      final rooms = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in rooms) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final pins = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _rooms = rooms;
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
        title: const Text('STAR LOCI'),
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
          ? const Center(child: CircularProgressIndicator(color: VisualTheme.secondaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                children: [
                  Text('tonight’s palace', textAlign: TextAlign.center, style: GoogleFonts.cinzel(fontSize: 26, height: 1.15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The dome is empty. Open a palace room before the quiz.'
                        : '${_stats!['totalItems']} loci across ${_stats!['totalContainers']} rooms.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(fontSize: 15, height: 1.45),
                  ),
                  const SkyStamp(label: 'IN ORBIT'),
                  if (_rooms.isEmpty)
                    Text('No rooms opened yet.\nPlanet hall. Myth gallery. Number vault.', textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(height: 1.5))
                  else
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _rooms.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (_, i) {
                          final c = _rooms[i];
                          final count = _counts[c.id] ?? 0;
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: PlanetOrb(
                              title: c.name,
                              meta: '$count',
                              accent: _orbColors[i % _orbColors.length],
                              size: 72.0 + (i % 4) * 10,
                              ring: i.isOdd,
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                                _loadData();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      key: const ValueKey('add_box_button'),
                      onPressed: () async {
                        final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                        if (r == true) _loadData();
                      },
                      child: Text('+ NEW ROOM', style: GoogleFonts.cinzel(fontSize: 14, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('FILE A LOCUS  →', style: GoogleFonts.cinzel(color: VisualTheme.secondaryColor, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                  ),
                  if (_pins.isNotEmpty) ...[
                    const SkyStamp(label: 'PINNED FOR RECALL'),
                    ..._pins.map((item) => StarPlate(
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
                  const SkyStamp(label: 'MNEMONIC'),
                  Text('Mark a locus Faded when the image slips — rebuild it before Friday’s oral quiz.', textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(fontSize: 15, height: 1.45, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
    );
  }
}
