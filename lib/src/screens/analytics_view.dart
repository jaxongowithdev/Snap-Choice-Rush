import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../utils/visual_theme.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final _storage = StorageManager.instance;
  Map<String, int>? _stats;
  Map<String, int>? _categoryStats;
  Map<String, int>? _roomStats;
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
      final categories = await _storage.getItemsByCategory();
      final rooms = await _storage.getItemsByRoom();
      setState(() { _stats = stats; _categoryStats = categories; _roomStats = rooms; _isLoading = false; });
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mix')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  _overview(),
                  if (_categoryStats != null && _categoryStats!.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text('By kind', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _chart(_categoryStats!, true),
                  ],
                  if (_roomStats != null && _roomStats!.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text('By room', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _chart(_roomStats!, false),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _overview() {
    if (_stats == null) return const SizedBox.shrink();
    final carts = _stats!['totalContainers'] ?? 0;
    final items = _stats!['totalItems'] ?? 0;
    final empty = _stats!['emptyContainers'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: VisualTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RAIL SNAPSHOT', style: GoogleFonts.sora(color: VisualTheme.secondaryColor, letterSpacing: 1.6, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(
            children: [
              _cell('Carts', carts.toString()),
              _cell('Bottles', items.toString()),
              _cell('In use', (carts - empty).toString()),
              _cell('Empty', empty.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.sora(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _chart(Map<String, int> data, bool klass) {
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = _stats?['totalItems'] ?? 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: sorted.map((e) {
            final pct = (e.value / total * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700)), Text('${e.value} · $pct%')]),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(value: e.value / total, minHeight: 5, backgroundColor: VisualTheme.mist, color: klass ? VisualTheme.getCategoryColor(e.key) : VisualTheme.secondaryColor),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
