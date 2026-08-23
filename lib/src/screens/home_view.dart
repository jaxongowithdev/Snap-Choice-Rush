import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import 'container_detail_view.dart';
import 'item_form_view.dart';
import 'search_view.dart';
import 'container_form_view.dart';
import 'favorites_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _storage = StorageManager.instance;
  Map<String, int>? _stats;
  List<ContainerModel>? _recentContainers;
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
      final recentMaps = await _storage.getRecentlyUpdatedContainers(limit: 5);
      setState(() {
        _stats = stats;
        _recentContainers = recentMaps.map(ContainerModel.fromMap).toList();
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
        title: Text('NIB LEDGER', style: GoogleFonts.outfit(letterSpacing: 2.4, fontSize: 14, fontWeight: FontWeight.w700, color: VisualTheme.cream)),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: VisualTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BLOTTER CHECK', style: GoogleFonts.outfit(color: VisualTheme.accentColor, letterSpacing: 1.8, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          (_stats?['totalItems'] ?? 0) == 0
                              ? 'No wells staged yet.'
                              : '${_stats!['totalItems']} bottles across ${_stats!['totalContainers']} wells.',
                          style: GoogleFonts.literata(color: VisualTheme.cream, fontSize: 26, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _cell('WELLS', _stats?['totalContainers']?.toString() ?? '0'),
                      const SizedBox(width: 8),
                      _cell('INK', _stats?['totalItems']?.toString() ?? '0'),
                      const SizedBox(width: 8),
                      _cell('EMPTY', _stats?['emptyContainers']?.toString() ?? '0'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _cta(key: const ValueKey('add_box_button'), label: 'NEW WELL', onTap: () async {
                          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                          if (r == true) _loadData();
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _cta(key: const ValueKey('add_item_button'), label: 'LOG BOTTLE', onTap: () async {
                          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                          if (r == true) _loadData();
                        }),
                      ),
                    ],
                  ),
                  if (_recentContainers != null && _recentContainers!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Last opened', style: GoogleFonts.literata(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    ..._recentContainers!.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: VisualTheme.mist,
                                foregroundColor: VisualTheme.ink,
                                child: Text(c.code.substring(0, 1), style: GoogleFonts.literata(fontWeight: FontWeight.w700)),
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
          color: const Color(0xFFFFFBF4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x221B2A4A)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.literata(fontSize: 24, fontWeight: FontWeight.w600)),
            Text(label, style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _cta({required Key key, required String label, required VoidCallback onTap}) {
    return Material(
      color: VisualTheme.secondaryColor,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
