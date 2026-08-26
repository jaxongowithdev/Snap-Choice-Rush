import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/loci_chrome.dart';
import 'item_detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _storage = StorageManager.instance;
  final _searchController = TextEditingController();
  List<InventoryItemModel>? _results;
  Map<int, ContainerModel> _containersCache = {};
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _results = null; _isSearching = false; });
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await _storage.searchItems(query);
      final containers = <int, ContainerModel>{};
      for (final item in results) {
        if (!containers.containsKey(item.containerId)) {
          final c = await _storage.getContainer(item.containerId);
          if (c != null) containers[item.containerId] = c;
        }
      }
      setState(() { _results = results; _containersCache = containers; _isSearching = false; });
    } catch (e) {
      debugPrint('Error searching: $e');
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const ValueKey('search_field'),
          controller: _searchController,
          autofocus: true,
          cursorColor: VisualTheme.secondaryColor,
          decoration: const InputDecoration(hintText: 'locus, room, myth…', border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _performSearch(''); }),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) return const Center(child: CircularProgressIndicator(color: VisualTheme.secondaryColor));
    if (_searchController.text.isEmpty) return _hint('find a locus', 'Search a card, kind, or mnemonic note.');
    if (_results == null || _results!.isEmpty) return _hint('no match', 'Try a shorter word or another kind.');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      itemCount: _results!.length,
      itemBuilder: (_, i) {
        final item = _results![i];
        final room = _containersCache[item.containerId];
        return StarPlate(
          kind: item.category,
          title: item.name,
          meta: room != null ? room.name : '',
          accent: VisualTheme.getCategoryColor(item.category),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!))).then((_) => _performSearch(_searchController.text));
          },
        );
      },
    );
  }

  Widget _hint(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
