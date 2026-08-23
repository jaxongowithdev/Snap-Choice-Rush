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
  final Map<int, String> _rackNames = {};
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
          _itemNames[log.itemId] = item?.name ?? 'Unknown set';
        }
        if (!_rackNames.containsKey(log.fromContainerId)) {
          final from = await _storage.getContainer(log.fromContainerId);
          _rackNames[log.fromContainerId] = from?.name ?? 'Removed rack';
        }
        if (!_rackNames.containsKey(log.toContainerId)) {
          final to = await _storage.getContainer(log.toContainerId);
          _rackNames[log.toContainerId] = to?.name ?? 'Removed rack';
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
      appBar: AppBar(title: const Text('LOG')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs == null || _logs!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('0 rec', style: GoogleFonts.ibmPlexMono(fontSize: 22, color: VisualTheme.secondaryColor)),
                        const SizedBox(height: 8),
                        Text('No transfers yet', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('When a set moves between racks, the record lands here.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                    itemCount: _logs!.length,
                    itemBuilder: (_, i) {
                      final log = _logs![i];
                      final when = DateFormat('MM.dd  HH:mm').format(log.moveDate);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_itemNames[log.itemId] ?? 'Set', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
                        subtitle: Text('${_rackNames[log.fromContainerId]}  →  ${_rackNames[log.toContainerId]}\n$when${log.notes != null && log.notes!.isNotEmpty ? '  ·  ${log.notes}' : ''}', style: GoogleFonts.ibmPlexMono(fontSize: 11)),
                        isThreeLine: true,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: log.itemId)));
                          _load();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
