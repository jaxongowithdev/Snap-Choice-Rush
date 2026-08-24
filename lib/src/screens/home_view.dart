import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/dewey_chrome.dart';
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
  List<ContainerModel> _bins = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _flags = [];
  bool _isLoading = true;

  static const _spineColors = [
    Color(0xFF2C4A3C),
    Color(0xFFB33A2B),
    Color(0xFFC4A35A),
    Color(0xFF3D5C7A),
    Color(0xFF7A4A6A),
    Color(0xFF5A7A4A),
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
      final bins = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final b in bins) {
        counts[b.id!] = await _storage.getItemCountInContainer(b.id!);
      }
      final flags = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _bins = bins;
        _counts = counts;
        _flags = flags.take(5).toList();
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
        title: const Text('Dewey Nook'),
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
          ? const Center(child: CircularProgressIndicator(color: VisualTheme.primaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 12, 28),
                children: [
                  Text('this week’s bin', style: GoogleFonts.libreBaskerville(fontSize: 28, fontStyle: FontStyle.italic, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The nook is empty. Label a bin before independent reading.'
                        : '${_stats!['totalItems']} titles across ${_stats!['totalContainers']} bins.',
                    style: GoogleFonts.outfit(fontSize: 15, height: 1.45),
                  ),
                  const PocketLabel(label: 'ON THE SHELF'),
                  if (_bins.isEmpty)
                    Text('No bins labeled yet.\nChapter crate. Picture tub. Teacher shelf.', style: GoogleFonts.outfit(height: 1.5))
                  else
                    SizedBox(
                      height: 168,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(_bins.length, (i) {
                              final c = _bins[i];
                              final count = _counts[c.id] ?? 0;
                              return BookSpine(
                                title: c.name,
                                meta: '$count',
                                accent: _spineColors[i % _spineColors.length],
                                height: 96.0 + (i % 4) * 18,
                                onTap: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                                  _loadData();
                                },
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
                      child: Text('+ new bin', style: GoogleFonts.libreBaskerville(fontSize: 16, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('file a title  →', style: GoogleFonts.outfit(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w800)),
                  ),
                  if (_flags.isNotEmpty) ...[
                    const PocketLabel(label: 'FLAGGED FOR WORKSHOP'),
                    ..._flags.map((item) => CheckoutCard(
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
                  const PocketLabel(label: 'LIBRARIAN NOTE'),
                  Text('Mark a title Worn when the spine splits — replace it before Friday’s checkout.', style: GoogleFonts.libreBaskerville(fontSize: 16, fontStyle: FontStyle.italic, height: 1.4)),
                ],
              ),
            ),
    );
  }
}
