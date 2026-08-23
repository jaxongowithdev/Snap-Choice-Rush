import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../widgets/bench_chrome.dart';

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
      appBar: AppBar(title: const Text('READOUT')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  if (_stats != null)
                    Text('n=${_stats!['totalItems']}  racks=${_stats!['totalContainers']}  empty=${_stats!['emptyContainers']}', style: GoogleFonts.ibmPlexMono()),
                  if (_categoryStats != null && _categoryStats!.isNotEmpty) ...[
                    const SpecLabel(label: 'BY KIND'),
                    ..._categoryStats!.entries.map((e) => Text('${e.key.padRight(14)} ${e.value}', style: GoogleFonts.ibmPlexMono(fontSize: 12))),
                  ],
                  if (_roomStats != null && _roomStats!.isNotEmpty) ...[
                    const SpecLabel(label: 'BY ROOM'),
                    ..._roomStats!.entries.map((e) => Text('${e.key.padRight(14)} ${e.value}', style: GoogleFonts.ibmPlexMono(fontSize: 12))),
                  ],
                ],
              ),
            ),
    );
  }
}
