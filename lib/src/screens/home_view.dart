import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/slate_chrome.dart';
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
  List<ContainerModel> _periods = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _stars = [];
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
      final periods = await _storage.getAllContainers(sortBy: 'name');
      final counts = <int, int>{};
      for (final p in periods) {
        counts[p.id!] = await _storage.getItemCountInContainer(p.id!);
      }
      final stars = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _periods = periods;
        _counts = counts;
        _stars = stars.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  String _periodMark(ContainerModel c, int i) {
    final digits = RegExp(r'\d+').firstMatch(c.code);
    if (digits != null) return digits.group(0)!.padLeft(2, '0');
    return (i + 1).toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE · d MMM').format(DateTime.now()).toUpperCase();
    return Scaffold(
      appBar: AppBar(
        title: Text(today, style: GoogleFonts.syne(fontSize: 13, letterSpacing: 1.6, fontWeight: FontWeight.w800)),
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  Text('BOARD', style: GoogleFonts.syne(fontSize: 11, letterSpacing: 2.4, fontWeight: FontWeight.w800, color: VisualTheme.secondaryColor)),
                  const SizedBox(height: 4),
                  Text('Today’s periods', style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, height: 1.05)),
                  const SizedBox(height: 6),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'The slate is blank. Add a period before first bell.'
                        : '${_stats!['totalItems']} pieces · ${_stats!['totalContainers']} periods · ${(_stats!['totalContainers'] ?? 0) - (_stats!['emptyContainers'] ?? 0)} live',
                    style: GoogleFonts.manrope(fontSize: 14, height: 1.4),
                  ),
                  const SlateRule(label: 'TIMETABLE'),
                  if (_periods.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Text('No periods on the board yet.\nPeriod 1 Reading. Period 2 Lab. Period 5 Study hall.', style: GoogleFonts.manrope(height: 1.5)),
                    )
                  else
                    ..._periods.asMap().entries.map((e) {
                      final c = e.value;
                      final count = _counts[c.id] ?? 0;
                      final progress = c.capacity > 0 ? count / c.capacity : 0.0;
                      return PeriodRow(
                        mark: _periodMark(c, e.key),
                        title: c.name,
                        meta: '${c.room}  ·  ${c.shelf}',
                        fill: '$count / ${c.capacity}',
                        progress: progress,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                          _loadData();
                        },
                      );
                    }),
                  const SizedBox(height: 18),
                  OutlinedButton(
                    key: const ValueKey('add_box_button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VisualTheme.primaryColor,
                      side: const BorderSide(color: VisualTheme.primaryColor, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('ADD A PERIOD', style: GoogleFonts.syne(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    key: const ValueKey('add_item_button'),
                    onPressed: () async {
                      final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                      if (r == true) _loadData();
                    },
                    child: Text('FILE A PIECE →', style: GoogleFonts.syne(fontWeight: FontWeight.w800, color: VisualTheme.secondaryColor)),
                  ),
                  if (_stars.isNotEmpty) ...[
                    const SlateRule(label: 'STARRED FOR THE BELL'),
                    ..._stars.map((item) => MaterialLine(
                          accent: VisualTheme.getCategoryColor(item.category),
                          title: item.name,
                          subtitle: '${item.category}  ·  ${item.condition}',
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                            _loadData();
                          },
                        )),
                  ],
                  const SlateRule(label: 'NOTE'),
                  Text('Mark a stack Missing when it leaves the room — restock before tomorrow’s first period.', style: GoogleFonts.manrope(fontSize: 13, height: 1.45)),
                ],
              ),
            ),
    );
  }
}
