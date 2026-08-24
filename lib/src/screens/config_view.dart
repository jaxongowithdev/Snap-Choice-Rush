import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../database/storage_manager.dart';
import '../models/user_preferences.dart';
import '../utils/visual_theme.dart';
import '../widgets/stanza_chrome.dart';

class ConfigView extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const ConfigView({super.key, required this.onSettingsChanged});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final _storage = StorageManager.instance;
  UserPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _storage.getPreferences();
      setState(() => _preferences = prefs);
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _updateTheme(String theme) async {
    if (_preferences == null) return;
    final updated = _preferences!.copyWith(theme: theme);
    await _storage.updatePreferences(updated);
    setState(() => _preferences = updated);
    widget.onSettingsChanged();
  }

  Future<void> _exportData() async {
    try {
      final data = await _storage.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await Share.shareXFiles(
        [XFile.fromData(Uint8List.fromList(jsonString.codeUnits), mimeType: 'application/json', name: 'ink_stanza_${DateTime.now().millisecondsSinceEpoch}.json')],
        text: 'Ink Stanza catalog',
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Desk exported')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not export: $e')));
    }
  }

  Future<void> _importData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore a desk?'),
        content: const Text('The current folios will be replaced by the file you pick.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;
      final data = jsonDecode(String.fromCharCodes(result.files.first.bytes!)) as Map<String, dynamic>;
      await _storage.importData(data);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Desk restored')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not restore: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Desk')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 16, 28),
        children: [
          Text('Ink Stanza', style: GoogleFonts.spectral(fontSize: 32, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Text('A private poetry workshop. Nothing leaves this phone.', style: GoogleFonts.figtree(height: 1.4)),
          const SealLabel(label: 'LIGHT'),
          for (final e in const [('light', 'Daylight washi'), ('dark', 'After the reading'), ('system', 'Match the phone')])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text((_preferences?.theme ?? 'system') == e.$1 ? '●' : '○', style: const TextStyle(color: VisualTheme.primaryColor)),
              title: Text(e.$2),
              onTap: () => _updateTheme(e.$1),
            ),
          const SealLabel(label: 'CATALOG'),
          ListTile(contentPadding: EdgeInsets.zero, key: const ValueKey('backup_button'), title: const Text('Export desk'), trailing: const Text('JSON →'), onTap: _exportData),
          ListTile(contentPadding: EdgeInsets.zero, key: const ValueKey('import_button'), title: const Text('Restore desk'), trailing: const Text('← FILE'), onTap: _importData),
          const SealLabel(label: 'COLOPHON'),
          Text('Version 1.0.0  ·  Offline poetry inventory', style: GoogleFonts.figtree(fontSize: 13)),
          const SizedBox(height: 6),
          Text('No account. No tracking. Local only.', style: GoogleFonts.figtree(fontSize: 13)),
        ],
      ),
    );
  }
}
