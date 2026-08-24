import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cubby_chrome.dart';
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
  List<ContainerModel> _cubbies = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _stars = [];
  bool _isLoading = true;

  static const _tileColors = [
    Color(0xFF4A90C8),
    Color(0xFFE24B3D),
    Color(0xFFF0C020),
    Color(0xFF7B5EA7),
    Color(0xFF5AAB5A),
    Color(0xFFD7A56A),
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
      final cubbies = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in cubbies) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final stars = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _cubbies = cubbies;
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
        title: const Text('Cubby Wall'),
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
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('this morning', style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w600, height: 1.1)),
                          const SizedBox(height: 8),
                          Text(
                            (_stats?['totalItems'] ?? 0) == 0
                                ? 'The wall is empty. Add a learning cubby before circle time.'
                                : '${_stats!['totalItems']} totes across ${_stats!['totalContainers']} cubbies.',
                            style: GoogleFonts.literata(fontSize: 15, height: 1.45),
                          ),
                          const NameTag(label: 'THE ROOM'),
                          if (_cubbies.isEmpty)
                            Text('No cubbies labeled yet.\nArt wall. Block corner. Quiet loft.', style: GoogleFonts.literata(height: 1.5)),
                        ],
                      ),
                    ),
                  ),
                  if (_cubbies.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.05,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final c = _cubbies[i];
                            final count = _counts[c.id] ?? 0;
                            return CenterTile(
                              title: c.name,
                              meta: '${c.room}  ·  $count / ${c.capacity}',
                              accent: _tileColors[i % _tileColors.length],
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                                _loadData();
                              },
                            );
                          },
                          childCount: _cubbies.length,
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              key: const ValueKey('add_box_button'),
                              onPressed: () async {
                                final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                                if (r == true) _loadData();
                              },
                              child: Text('+ new cubby', style: GoogleFonts.fredoka(fontSize: 16, color: VisualTheme.primaryColor)),
                            ),
                          ),
                          TextButton(
                            key: const ValueKey('add_item_button'),
                            onPressed: () async {
                              final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                              if (r == true) _loadData();
                            },
                            child: Text('file a tote  →', style: GoogleFonts.fredoka(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w600)),
                          ),
                          if (_stars.isNotEmpty) ...[
                            const NameTag(label: 'STARRED FOR CIRCLE'),
                            ..._stars.map((item) => ToteCard(
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
                          const NameTag(label: 'TEACHER NOTE'),
                          Text('Mark a tote Worn when the handles fray — restock before Friday’s centers.', style: GoogleFonts.literata(fontSize: 16, fontStyle: FontStyle.italic, height: 1.4)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
