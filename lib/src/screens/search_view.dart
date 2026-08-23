import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/binder_chrome.dart';
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
          cursorColor: VisualTheme.primaryColor,
          decoration: const InputDecoration(hintText: 'Mock, Anki, SAT…', border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false),
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
    if (_searchController.text.isEmpty) return _hint('FIND A DRILL', 'Search a paper, kind, or study note.');
    if (_results == null || _results!.isEmpty) return _hint('NO MATCH', 'Try a shorter word or another kind.');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      itemCount: _results!.length,
      itemBuilder: (_, i) {
        final item = _results![i];
        final spine = _containersCache[item.containerId];
        return FlagLine(
          accent: VisualTheme.getCategoryColor(item.category),
          title: item.name,
          subtitle: '${item.category}  ·  ${item.quantity}${spine != null ? '\n${spine.name}  ·  ${spine.room}' : ''}',
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
            Text(title, style: GoogleFonts.ibmPlexMono(fontSize: 14, letterSpacing: 1.4, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.libreBaskerville()),
          ],
        ),
      ),
    );
  }
}
