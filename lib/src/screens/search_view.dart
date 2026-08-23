import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
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
          style: const TextStyle(color: Color(0xFFF7F1E6)),
          cursorColor: VisualTheme.accentColor,
          decoration: const InputDecoration(hintText: 'Kon-peki, Pilot, iron gall…', hintStyle: TextStyle(color: Colors.white70), border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false),
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
    if (_isSearching) return const Center(child: CircularProgressIndicator());
    if (_searchController.text.isEmpty) return _hint(Icons.search, 'Locate a bottle', 'Search an ink, kind, or swab note.');
    if (_results == null || _results!.isEmpty) return _hint(Icons.search_off, 'No match', 'Try a shorter word or another kind.');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results!.length,
      itemBuilder: (_, i) {
        final item = _results![i];
        final well = _containersCache[item.containerId];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: ListTile(
              leading: Icon(Icons.water_drop, color: VisualTheme.getCategoryColor(item.category)),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${item.category} · ${item.quantity}${well != null ? '\n${well.name} / ${well.room}' : ''}'),
              isThreeLine: well != null,
              trailing: const Icon(Icons.arrow_forward, size: 18),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!))).then((_) => _performSearch(_searchController.text));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _hint(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: VisualTheme.secondaryColor),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.literata(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
