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
  final Map<int, String> _trayNames = {};
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
          _itemNames[log.itemId] = item?.name ?? 'Unknown piece';
        }
        if (!_trayNames.containsKey(log.fromContainerId)) {
          final from = await _storage.getContainer(log.fromContainerId);
          _trayNames[log.fromContainerId] = from?.name ?? 'Removed tray';
        }
        if (!_trayNames.containsKey(log.toContainerId)) {
          final to = await _storage.getContainer(log.toContainerId);
          _trayNames[log.toContainerId] = to?.name ?? 'Removed tray';
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
      appBar: AppBar(title: const Text('Trace')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs == null || _logs!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history_edu_outlined, size: 48, color: VisualTheme.secondaryColor),
                        const SizedBox(height: 12),
                        Text('No lesson trace yet', style: GoogleFonts.sourceSerif4(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('When you move a piece between trays, the shift shows up here.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    itemCount: _logs!.length,
                    itemBuilder: (_, i) {
                      final log = _logs![i];
                      final when = DateFormat('MMM d · HH:mm').format(log.moveDate);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0x1AC4532C),
                              child: const Icon(Icons.swap_horiz, color: VisualTheme.secondaryColor),
                            ),
                            title: Text(_itemNames[log.itemId] ?? 'Piece', style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${_trayNames[log.fromContainerId]} → ${_trayNames[log.toContainerId]}\n$when${log.notes != null && log.notes!.isNotEmpty ? '  ·  ${log.notes}' : ''}'),
                            isThreeLine: true,
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: log.itemId)));
                              _load();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
