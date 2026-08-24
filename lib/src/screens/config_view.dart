import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../database/storage_manager.dart';
import '../models/user_preferences.dart';
import '../utils/visual_theme.dart';
import '../widgets/trace_chrome.dart';

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
        [XFile.fromData(Uint8List.fromList(jsonString.codeUnits), mimeType: 'application/json', name: 'trace_hall_${DateTime.now().millisecondsSinceEpoch}.json')],
        text: 'Trace Hall catalog',
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catalog exported')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not export: $e')));
    }
  }

  Future<void> _importData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore a catalog?'),
        content: const Text('The current sets will be replaced by the file you pick.'),
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catalog restored')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not restore: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('DESK')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text('Trace Hall', style: GoogleFonts.sourceSerif4(fontSize: 32, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('A private studio catalog. Nothing leaves this phone.', style: GoogleFonts.barlowCondensed(height: 1.4, fontSize: 16)),
          const SheetStamp(label: 'LIGHT'),
          for (final e in const [('light', 'Vellum daylight'), ('dark', 'Blueprint night'), ('system', 'Match the phone')])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text((_preferences?.theme ?? 'system') == e.$1 ? '●' : '○', style: const TextStyle(color: VisualTheme.primaryColor)),
              title: Text(e.$2),
              onTap: () => _updateTheme(e.$1),
            ),
          const SheetStamp(label: 'CATALOG'),
          ListTile(contentPadding: EdgeInsets.zero, key: const ValueKey('backup_button'), title: const Text('Export catalog'), trailing: const Text('JSON →'), onTap: _exportData),
          ListTile(contentPadding: EdgeInsets.zero, key: const ValueKey('import_button'), title: const Text('Restore catalog'), trailing: const Text('← FILE'), onTap: _importData),
          const SheetStamp(label: 'COLOPHON'),
          Text('Version 1.0.0  ·  Offline studio inventory', style: GoogleFonts.barlowCondensed(fontSize: 13)),
          const SizedBox(height: 6),
          Text('No account. No tracking. Local only.', style: GoogleFonts.barlowCondensed(fontSize: 13)),
        ],
      ),
    );
  }
}
