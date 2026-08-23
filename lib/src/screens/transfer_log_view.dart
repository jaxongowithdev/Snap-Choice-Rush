import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/storage_manager.dart';
import '../models/transfer_history_model.dart';
import '../utils/visual_theme.dart';
import 'item_detail_view.dart';

class TransferLogView extends StatefulWidget {
  const TransferLogView({super.key});

  @override
  State<TransferLogView> createState() => _TransferLogViewState();
}

class _TransferLogViewState extends State<TransferLogView> {
  final _storage = StorageManager.instance;
  List<TransferHistoryModel>? _logs;
  final Map<int, String> _itemNames = {};
  final Map<int, String> _spineNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _storage.getTransferHistory();
      for (final log in logs) {
        if (!_itemNames.containsKey(log.itemId)) {
          final item = await _storage.getItem(log.itemId);
          _itemNames[log.itemId] = item?.name ?? 'Unknown drill';
        }
        if (!_spineNames.containsKey(log.fromContainerId)) {
          final from = await _storage.getContainer(log.fromContainerId);
          _spineNames[log.fromContainerId] = from?.name ?? 'Removed spine';
        }
        if (!_spineNames.containsKey(log.toContainerId)) {
          final to = await _storage.getContainer(log.toContainerId);
          _spineNames[log.toContainerId] = to?.name ?? 'Removed spine';
        }
      }
      setState(() { _logs = logs; _isLoading = false; });
    } catch (e) {
      debugPrint('Error loading transfer log: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Moves')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs == null || _logs!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ibid.', style: GoogleFonts.libreBaskerville(fontSize: 28, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
                        const SizedBox(height: 8),
                        Text('No moves yet', style: GoogleFonts.libreBaskerville(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('When a drill changes spines, the citation lands here.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(28, 8, 20, 28),
                    itemCount: _logs!.length,
                    itemBuilder: (_, i) {
                      final log = _logs![i];
                      final when = DateFormat('MMM d').format(log.moveDate);
                      return InkWell(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: log.itemId)));
                          _load();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${(i + 1).toString().padLeft(2, '0')}   ${_itemNames[log.itemId] ?? 'Drill'}', style: GoogleFonts.libreBaskerville(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('${_spineNames[log.fromContainerId]}  →  ${_spineNames[log.toContainerId]}', style: GoogleFonts.ibmPlexMono(fontSize: 11)),
                              Text('$when${log.notes != null && log.notes!.isNotEmpty ? '  ·  ${log.notes}' : ''}', style: GoogleFonts.ibmPlexMono(fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
