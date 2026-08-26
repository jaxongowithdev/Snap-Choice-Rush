import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_pkg;
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';

class ItemFormView extends StatefulWidget {
  final InventoryItemModel? item;
  final int? preselectedContainerId;
  const ItemFormView({super.key, this.item, this.preselectedContainerId});

  @override
  State<ItemFormView> createState() => _ItemFormViewState();
}

class _ItemFormViewState extends State<ItemFormView> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageManager.instance;
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _tagsController;

  List<ContainerModel>? _missions;
  int? _missionId;
  String _category = 'Peg';
  String _recall = 'Fresh';
  String? _photoPath;
  bool _starred = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _notesController = TextEditingController(text: widget.item?.notes);
    _tagsController = TextEditingController(text: widget.item?.keywords);
    _category = widget.item?.category ?? 'Peg';
    if (!VisualTheme.cueTypes.contains(_category)) _category = 'Other';
    _recall = widget.item?.condition ?? 'Fresh';
    if (!VisualTheme.recallLevels.contains(_recall)) _recall = 'Fresh';
    _missionId = widget.item?.containerId ?? widget.preselectedContainerId;
    _photoPath = widget.item?.photoPath;
    _starred = widget.item?.isFavorite ?? false;
    _loadMissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    try {
      final missions = await _storage.getAllContainers(sortBy: 'name');
      if (!mounted) return;
      setState(() {
        _missions = missions;
        if (_missionId == null && missions.isNotEmpty) _missionId = missions.first.id;
      });
    } catch (e) {
      debugPrint('Error loading missions: $e');
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final photo = await _imagePicker.pickImage(
          source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
      if (photo == null) return;
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'cue_${DateTime.now().millisecondsSinceEpoch}${path_pkg.extension(photo.path)}';
      final savedPath = path_pkg.join(appDir.path, 'photos', fileName);
      await Directory(path_pkg.join(appDir.path, 'photos')).create(recursive: true);
      await File(photo.path).copy(savedPath);
      if (mounted) setState(() => _photoPath = savedPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not add the picture: $e')));
      }
    }
  }

  Future<void> _removePhoto() async {
    if (_photoPath != null) {
      try {
        final file = File(_photoPath!);
        if (await file.exists()) await file.delete();
      } catch (e) {
        debugPrint('Error deleting photo: $e');
      }
    }
    setState(() => _photoPath = null);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_missionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a mission first, then file the cue into it.')),
      );
      return;
    }
    final tags = _tagsController.text.trim();
    final cue = InventoryItemModel(
      id: widget.item?.id,
      containerId: _missionId!,
      name: _nameController.text.trim(),
      category: _category,
      quantity: widget.item?.quantity ?? 0,
      condition: _recall,
      estimatedValue: VisualTheme.recallStrength(_recall) * 100,
      purchaseDate: widget.item?.purchaseDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      keywords: tags.isEmpty ? null : tags,
      photoPath: _photoPath,
      isFavorite: _starred,
      createdAt: widget.item?.createdAt,
    );
    if (widget.item == null) {
      await _storage.createItem(cue);
    } else {
      await _storage.updateItem(cue);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    return Scaffold(
      body: StarDust(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(isEditing ? 'Edit cue' : 'New cue',
                    style: VisualTheme.display(30, color: VisualTheme.inkOf(context))),
                const SizedBox(height: 6),
                Text('The front is what you are asked. The anchor is the picture that answers it.',
                    style: VisualTheme.body(14, color: VisualTheme.mutedOf(context))),
                const SizedBox(height: 22),

                if (_photoPath != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(VisualTheme.rXL),
                        child: Image.file(File(_photoPath!),
                            height: 180, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.white),
                          style: IconButton.styleFrom(backgroundColor: VisualTheme.rose),
                          onPressed: _removePhoto,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('camera_button'),
                          onPressed: () => _pickPhoto(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_rounded, size: 18),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('gallery_button'),
                          onPressed: () => _pickPhoto(ImageSource.gallery),
                          icon: const Icon(Icons.image_rounded, size: 18),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 18),

                BentoTile(
                  child: Column(
                    children: [
                      TextFormField(
                        key: const ValueKey('item_name_field'),
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Cue front',
                          hintText: 'e.g. Fourth planet from the Sun',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Write the cue front' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('notes_field'),
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'The anchor (answer + picture)',
                          hintText: 'Mars — a rusty red bicycle parked in my hallway',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('tags_field'),
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (comma separated)',
                          hintText: 'planets, quiz, week 3',
                        ),
                      ),
                    ],
                  ),
                ),

                const SectionHead(title: 'Mission'),
                if (_missions == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: LinearProgressIndicator(),
                  )
                else if (_missions!.isEmpty)
                  BentoTile(
                    fill: VisualTheme.veilOf(context),
                    child: Text('No missions yet — create one from the Missions tab first.',
                        style: VisualTheme.body(14, color: VisualTheme.mutedOf(context))),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _missions!
                        .map((m) => _Pick(
                              label: m.name,
                              icon: VisualTheme.trackIcon(m.room),
                              selected: _missionId == m.id,
                              tint: VisualTheme.nova,
                              onTap: () => setState(() => _missionId = m.id),
                            ))
                        .toList(),
                  ),

                const SectionHead(title: 'Cue type'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: VisualTheme.cueTypes
                      .map((c) => _Pick(
                            label: c,
                            selected: _category == c,
                            tint: VisualTheme.getCategoryColor(c),
                            onTap: () => setState(() => _category = c),
                          ))
                      .toList(),
                ),

                const SectionHead(title: 'Recall level'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: VisualTheme.recallLevels
                      .map((r) => _Pick(
                            label: r,
                            selected: _recall == r,
                            tint: VisualTheme.getConditionColor(r),
                            onTap: () => setState(() => _recall = r),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 18),
                BentoTile(
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: VisualTheme.sun),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Keep in the drill deck',
                            style: VisualTheme.heading(15.5,
                                color: VisualTheme.inkOf(context), w: FontWeight.w700)),
                      ),
                      Switch(
                        value: _starred,
                        activeColor: VisualTheme.sun,
                        onChanged: (v) => setState(() => _starred = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),
                FilledButton(
                  key: const ValueKey('save_item_button'),
                  onPressed: _save,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: Text(isEditing ? 'Save cue' : 'File the cue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pick extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final Color tint;
  final VoidCallback onTap;
  const _Pick({
    required this.label,
    required this.selected,
    required this.tint,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? tint : tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: selected ? Colors.white : tint),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: VisualTheme.heading(13.5,
                    color: selected ? Colors.white : tint, w: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
