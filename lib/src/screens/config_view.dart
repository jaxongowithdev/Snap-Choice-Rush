import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../database/storage_manager.dart';
import '../models/user_preferences.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';

class ConfigView extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const ConfigView({super.key, required this.onSettingsChanged});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final _storage = StorageManager.instance;
  UserPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await _storage.getPreferences();
      if (mounted) setState(() => _prefs = prefs);
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _setTheme(String theme) async {
    if (_prefs == null) return;
    final updated = _prefs!.copyWith(theme: theme);
    await _storage.updatePreferences(updated);
    setState(() => _prefs = updated);
    widget.onSettingsChanged();
  }

  Future<void> _export() async {
    try {
      final data = await _storage.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(jsonString)),
            mimeType: 'application/json',
            name: 'orbit_recall_${DateTime.now().millisecondsSinceEpoch}.json',
          )
        ],
        text: 'Orbit Recall backup',
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Backup exported')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not export: $e')));
      }
    }
  }

  Future<void> _import() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore from a backup?'),
        content: const Text('Every mission and cue on this phone is replaced by the file you pick.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;
      final data =
          jsonDecode(utf8.decode(result.files.first.bytes!)) as Map<String, dynamic>;
      await _storage.importData(data);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Backup restored')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not restore: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _prefs?.theme ?? 'system';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
          children: [
            Text('Base',
                style: VisualTheme.display(32, color: VisualTheme.inkOf(context))),
            const SizedBox(height: 4),
            Text('Everything here stays on this phone.',
                style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
            const SizedBox(height: 20),

            BentoTile(
              fill: VisualTheme.nova,
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Orbit Recall',
                            style: VisualTheme.display(24, color: Colors.white)),
                        const SizedBox(height: 3),
                        Text('Version 1.0.0 · offline',
                            style: VisualTheme.body(13,
                                color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SectionHead(title: 'Appearance'),
            BentoTile(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  for (final e in const [
                    ('light', 'Daylight', Icons.light_mode_rounded),
                    ('dark', 'Night watch', Icons.dark_mode_rounded),
                    ('system', 'Match my phone', Icons.smartphone_rounded),
                  ])
                    _Row(
                      icon: e.$3,
                      label: e.$2,
                      tint: VisualTheme.nova,
                      trailing: Icon(
                        theme == e.$1
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: theme == e.$1
                            ? VisualTheme.nova
                            : VisualTheme.mutedOf(context).withValues(alpha: 0.5),
                      ),
                      onTap: () => _setTheme(e.$1),
                    ),
                ],
              ),
            ),

            const SectionHead(title: 'Your data'),
            BentoTile(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _Row(
                    key: const ValueKey('backup_button'),
                    icon: Icons.ios_share_rounded,
                    label: 'Export a backup',
                    sub: 'One JSON file with every mission and cue',
                    tint: VisualTheme.mint,
                    onTap: _export,
                  ),
                  _Row(
                    key: const ValueKey('import_button'),
                    icon: Icons.download_rounded,
                    label: 'Restore a backup',
                    sub: 'Replaces what is on this phone',
                    tint: VisualTheme.flare,
                    onTap: _import,
                  ),
                ],
              ),
            ),

            const SectionHead(title: 'How the drill works'),
            BentoTile(
              fill: VisualTheme.veilOf(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in const [
                    ('Fresh', 'Just filed — never recalled cold.'),
                    ('Shaky', 'You got there, but it took a while.'),
                    ('Steady', 'Recalled without help.'),
                    ('Locked', 'Instant, twice, on different days.'),
                    ('Faded', 'Missed it — back to the front of the queue.'),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 74,
                            child: TinyPill(
                                label: line.$1,
                                color: VisualTheme.getConditionColor(line.$1)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(line.$2,
                                style: VisualTheme.body(13.5,
                                    color: VisualTheme.mutedOf(context))),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SectionHead(title: 'Privacy'),
            BentoTile(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No account. No tracking. No network calls.',
                      style: VisualTheme.heading(16,
                          color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    'Missions, cues, pictures and drill history live in this app’s own storage. Camera and photo library are only used when you attach a picture to a cue.',
                    style: VisualTheme.body(13.5, color: VisualTheme.mutedOf(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final Color tint;
  final Widget? trailing;
  final VoidCallback onTap;
  const _Row({
    super.key,
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
    this.sub,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VisualTheme.rL),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 20, color: tint),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: VisualTheme.heading(15.5,
                          color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                  if (sub != null)
                    Text(sub!,
                        style: VisualTheme.body(12.5, color: VisualTheme.mutedOf(context))),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded, color: VisualTheme.mutedOf(context)),
          ],
        ),
      ),
    );
  }
}
