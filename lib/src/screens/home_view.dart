import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/amber_chrome.dart';
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
  List<ContainerModel> _trays = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _holds = [];
  bool _isLoading = true;

  static const _frameColors = [
    Color(0xFFE8943A),
    Color(0xFF8FA3A8),
    Color(0xFFE8C547),
    Color(0xFFC45A3A),
    Color(0xFF5A6A4A),
    Color(0xFFC9C2B4),
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
      final trays = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in trays) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final holds = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _trays = trays;
        _counts = counts;
        _holds = holds.take(5).toList();
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
        title: const Text('AMBER TRAY'),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.water_drop_outlined),
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
                  Text('today’s bench', style: GoogleFonts.fraunces(fontSize: 30, fontStyle: FontStyle.italic, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The sink is empty. Mix a tray before critique.'
                        : '${_stats!['totalItems']} sheets across ${_stats!['totalContainers']} trays.',
                    style: GoogleFonts.ibmPlexMono(fontSize: 13, height: 1.45),
                  ),
                  const TimerStamp(label: 'ON THE SINK'),
                  if (_trays.isEmpty)
                    Text('No trays mixed yet.\nDeveloper. Holding bath. Drying rack.', style: GoogleFonts.ibmPlexMono(height: 1.5))
                  else
                    SizedBox(
                      height: 148,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _trays.length,
                        itemBuilder: (_, i) {
                          final c = _trays[i];
                          final count = _counts[c.id] ?? 0;
                          return FilmFrame(
                            title: c.name,
                            meta: '$count / ${c.capacity}',
                            accent: _frameColors[i % _frameColors.length],
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                              _loadData();
                            },
                          );
                        },
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const ValueKey('add_box_button'),
                      onPressed: () async {
                        final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                        if (r == true) _loadData();
                      },
                      child: Text('+ mix a tray', style: GoogleFonts.ibmPlexMono(fontSize: 13, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('file a sheet  →', style: GoogleFonts.ibmPlexMono(color: VisualTheme.primaryColor, fontWeight: FontWeight.w700)),
                  ),
                  if (_holds.isNotEmpty) ...[
                    const TimerStamp(label: 'IN THE HOLDING BATH'),
                    ..._holds.map((item) => ContactSheet(
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
                  const TimerStamp(label: 'BENCH NOTE'),
                  Text('Mark a sheet Wet until it leaves the wash — do not file it curly.', style: GoogleFonts.fraunces(fontSize: 17, fontStyle: FontStyle.italic, height: 1.4)),
                ],
              ),
            ),
    );
  }
}
