import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/yard_chrome.dart';
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
  List<ContainerModel> _cages = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _stars = [];
  bool _isLoading = true;

  static const _coneColors = [
    Color(0xFFF15A24),
    Color(0xFF1E3A5F),
    Color(0xFFC4D63A),
    Color(0xFFC73E3A),
    Color(0xFF3A7A6A),
    Color(0xFFD45A8A),
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
      final cages = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in cages) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final stars = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _cages = cages;
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
        title: const Text('Cone Yard'),
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
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  Text('THIS PERIOD’S STATION', style: GoogleFonts.oswald(fontSize: 28, height: 1.05, letterSpacing: 0.4)),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The yard is empty. Label a cage before the period starts.'
                        : '${_stats!['totalItems']} pieces across ${_stats!['totalContainers']} cages.',
                    style: GoogleFonts.karla(fontSize: 15, height: 1.45),
                  ),
                  const LaneStamp(label: 'ON THE FLOOR'),
                  if (_cages.isEmpty)
                    Text('No cages labeled yet.\nBall cage. Cone cart. Pinnie hook.', style: GoogleFonts.karla(height: 1.5))
                  else
                    SizedBox(
                      height: 168,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(_cages.length, (i) {
                              final c = _cages[i];
                              final count = _counts[c.id] ?? 0;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: StationCone(
                                  title: c.name,
                                  meta: '$count',
                                  accent: _coneColors[i % _coneColors.length],
                                  height: 88.0 + (i % 4) * 16,
                                  onTap: () async {
                                    await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                                    _loadData();
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
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
                      child: Text('+ NEW CAGE', style: GoogleFonts.oswald(fontSize: 16, letterSpacing: 0.8, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('FILE A PIECE  →', style: GoogleFonts.oswald(color: VisualTheme.secondaryColor, letterSpacing: 0.8)),
                  ),
                  if (_stars.isNotEmpty) ...[
                    const LaneStamp(label: 'STARRED FOR THE PERIOD'),
                    ..._stars.map((item) => ClipboardCard(
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
                  const LaneStamp(label: 'COACH NOTE'),
                  Text('Mark a piece Worn when the bladder leaks — replace it before Friday’s circuit.', style: GoogleFonts.karla(fontSize: 16, height: 1.4, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
    );
  }
}
