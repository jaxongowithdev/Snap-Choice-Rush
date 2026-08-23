import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
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
  List<ContainerModel>? _recentContainers;
  List<InventoryItemModel>? _onRail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning service';
    if (h < 17) return 'Afternoon rail';
    return 'Evening pour';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _storage.getStatistics();
      final recentMaps = await _storage.getRecentlyUpdatedContainers(limit: 5);
      final favorites = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _recentContainers = recentMaps.map(ContainerModel.fromMap).toList();
        _onRail = favorites.take(4).toList();
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EMBER RAIL', style: GoogleFonts.sora(letterSpacing: 1.8, fontSize: 12, fontWeight: FontWeight.w700, color: VisualTheme.secondaryColor)),
            Text(_greeting, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.local_drink_outlined),
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: VisualTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CART CHECK', style: GoogleFonts.sora(color: VisualTheme.secondaryColor, letterSpacing: 1.6, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          (_stats?['totalItems'] ?? 0) == 0
                              ? 'No bottles on the rail yet.'
                              : '${_stats!['totalItems']} bottles across ${_stats!['totalContainers']} carts.',
                          style: GoogleFonts.sora(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text('Spirits, bitters, citrus, glassware — file what you actually pour.', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _cell('CARTS', _stats?['totalContainers']?.toString() ?? '0'),
                      const SizedBox(width: 8),
                      _cell('STOCK', _stats?['totalItems']?.toString() ?? '0'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _cell('IN USE', ((_stats?['totalContainers'] ?? 0) - (_stats?['emptyContainers'] ?? 0)).toString()),
                      const SizedBox(width: 8),
                      _cell('EMPTY', _stats?['emptyContainers']?.toString() ?? '0'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _cta(key: const ValueKey('add_box_button'), label: 'NEW CART', onTap: () async {
                          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                          if (r == true) _loadData();
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _cta(key: const ValueKey('add_item_button'), label: 'LOG BOTTLE', dark: false, onTap: () async {
                          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                          if (r == true) _loadData();
                        }),
                      ),
                    ],
                  ),
                  if (_onRail != null && _onRail!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('On the rail tonight', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Pinned pours you keep in rotation.', style: GoogleFonts.plusJakartaSans(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 10),
                    ..._onRail!.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              leading: Container(width: 6, height: 36, color: VisualTheme.getCategoryColor(item.category)),
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${item.category} · ${item.condition}'),
                              trailing: const Icon(Icons.arrow_forward, size: 18),
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                                _loadData();
                              },
                            ),
                          ),
                        )),
                  ],
                  if (_recentContainers != null && _recentContainers!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Last opened carts', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    ..._recentContainers!.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: VisualTheme.mist, borderRadius: BorderRadius.circular(8)),
                                child: Text(c.code.substring(0, 1), style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
                              ),
                              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${c.room} / ${c.shelf}'),
                              trailing: const Icon(Icons.arrow_forward, size: 18),
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                                _loadData();
                              },
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: VisualTheme.accentColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Mark a bottle Low when the last finger is gone — restock before Friday guests.', style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _cell(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x1412161C)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700)),
            Text(label, style: GoogleFonts.sora(fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _cta({required Key key, required String label, required VoidCallback onTap, bool dark = true}) {
    return Material(
      color: dark ? VisualTheme.primaryColor : VisualTheme.secondaryColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.sora(color: dark ? Colors.white : VisualTheme.primaryColor, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
