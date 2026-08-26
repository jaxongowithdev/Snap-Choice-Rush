import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/storage_manager.dart';
import '../models/transfer_history_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'item_detail_view.dart';

class TransferLogView extends StatefulWidget {
  const TransferLogView({super.key});

  @override
  State<TransferLogView> createState() => _TransferLogViewState();
}

class _TransferLogViewState extends State<TransferLogView> {
  final _storage = StorageManager.instance;
  List<TransferHistoryModel>? _logs;
  final Map<int, String> _cueNames = {};
  final Map<int, String> _missionNames = {};
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
        if (!_cueNames.containsKey(log.itemId)) {
          final cue = await _storage.getItem(log.itemId);
          _cueNames[log.itemId] = cue?.name ?? 'Dropped cue';
        }
        for (final id in [log.fromContainerId, log.toContainerId]) {
          if (!_missionNames.containsKey(id)) {
            final m = await _storage.getContainer(id);
            _missionNames[id] = m?.name ?? 'Scrubbed mission';
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading flight log: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: StarDust(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 18, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('Flight log',
                          style: VisualTheme.display(28, color: VisualTheme.inkOf(context))),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_logs == null || _logs!.isEmpty)
                        ? const EmptyOrbit(
                            icon: Icons.route_rounded,
                            tint: VisualTheme.sky,
                            title: 'No reassigns yet',
                            body: 'Every time a cue changes mission, the move lands here with its note.',
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                              itemCount: _logs!.length,
                              itemBuilder: (_, i) {
                                final log = _logs![i];
                                final first = i == 0;
                                final last = i == _logs!.length - 1;
                                return IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 2,
                                              height: 14,
                                              color: first
                                                  ? Colors.transparent
                                                  : VisualTheme.sky.withValues(alpha: 0.3),
                                            ),
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: VisualTheme.sky,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: dark
                                                      ? VisualTheme.night
                                                      : VisualTheme.canvas,
                                                  width: 2.5,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: 2,
                                                color: last
                                                    ? Colors.transparent
                                                    : VisualTheme.sky.withValues(alpha: 0.3),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 12, left: 4),
                                          child: BentoTile(
                                            padding: const EdgeInsets.all(15),
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ItemDetailView(itemId: log.itemId),
                                                ),
                                              );
                                              _load();
                                            },
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _cueNames[log.itemId] ?? 'Cue',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: VisualTheme.heading(16,
                                                            color: VisualTheme.inkOf(context),
                                                            w: FontWeight.w700),
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat('MMM d')
                                                          .format(log.moveDate),
                                                      style: VisualTheme.tag(11,
                                                          color: VisualTheme.mutedOf(context)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: TinyPill(
                                                        label: _missionNames[
                                                                log.fromContainerId] ??
                                                            '—',
                                                        color: VisualTheme.mutedOf(context),
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(horizontal: 6),
                                                      child: Icon(
                                                          Icons.arrow_forward_rounded,
                                                          size: 14,
                                                          color: VisualTheme.sky),
                                                    ),
                                                    Flexible(
                                                      child: TinyPill(
                                                        label:
                                                            _missionNames[log.toContainerId] ??
                                                                '—',
                                                        color: VisualTheme.sky,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if ((log.notes ?? '').isNotEmpty) ...[
                                                  const SizedBox(height: 8),
                                                  Text(log.notes!,
                                                      style: VisualTheme.body(13,
                                                          color:
                                                              VisualTheme.mutedOf(context))),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
