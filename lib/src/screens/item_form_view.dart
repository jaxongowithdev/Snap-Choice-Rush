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

  List<ContainerModel>? _workshops;
  int? _workshopId;
  String _category = 'Aroma';
  String _stage = 'Dry';
  String? _photoPath;
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _notesController = TextEditingController(text: widget.item?.notes);
    _tagsController = TextEditingController(text: widget.item?.keywords);
    _category = widget.item?.category ?? 'Aroma';
    if (!VisualTheme.cueTypes.contains(_category)) _category = 'Other';
    _stage = widget.item?.condition ?? 'Dry';
    if (!VisualTheme.recallLevels.contains(_stage)) _stage = 'Dry';
    _workshopId = widget.item?.containerId ?? widget.preselectedContainerId;
    _photoPath = widget.item?.photoPath;
    _pinned = widget.item?.isFavorite ?? false;
    _loadWorkshops();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkshops() async {
    try {
      final workshops = await _storage.getAllContainers(sortBy: 'name');
      if (!mounted) return;
      setState(() {
        _workshops = workshops;
        if (_workshopId == null && workshops.isNotEmpty) _workshopId = workshops.first.id;
      });
    } catch (e) {
      debugPrint('Error loading workshops: $e');
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final photo = await _imagePicker.pickImage(
          source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
      if (photo == null) return;
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'recipe_${DateTime.now().millisecondsSinceEpoch}${path_pkg.extension(photo.path)}';
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
    if (_workshopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Open a workshop first, then file the recipe into it.')),
      );
      return;
    }
    final tags = _tagsController.text.trim();
    final recipe = InventoryItemModel(
      id: widget.item?.id,
      containerId: _workshopId!,
      name: _nameController.text.trim(),
      category: _category,
      quantity: widget.item?.quantity ?? 0,
      condition: _stage,
      estimatedValue: VisualTheme.recallStrength(_stage) * 100,
      purchaseDate: widget.item?.purchaseDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      keywords: tags.isEmpty ? null : tags,
      photoPath: _photoPath,
      isFavorite: _pinned,
      createdAt: widget.item?.createdAt,
    );
    if (widget.item == null) {
      await _storage.createItem(recipe);
    } else {
      await _storage.updateItem(recipe);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    return Scaffold(
      body: PaperGrain(
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
                Text(isEditing ? 'Edit recipe' : 'New recipe',
                    style: VisualTheme.display(30, color: VisualTheme.inkOf(context))),
                const SizedBox(height: 6),
                Text('The title is the job. The seed is the facts Spark should write from.',
                    style: VisualTheme.body(14, color: VisualTheme.mutedOf(context))),
                const SizedBox(height: 20),

                if (_photoPath != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(VisualTheme.rL),
                        child: Image.file(File(_photoPath!),
                            height: 168, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.white),
                          style: IconButton.styleFrom(backgroundColor: VisualTheme.wine),
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
                          label: const Text('Library'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                SheetCard(
                  child: Column(
                    children: [
                      TextFormField(
                        key: const ValueKey('item_name_field'),
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Recipe title',
                          hintText: 'e.g. Saturday market opener',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Name the recipe' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('notes_field'),
                        controller: _notesController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Seed (facts, voice, constraints)',
                          hintText: 'Heirloom tomatoes, still warm. Close at two. Cash or tap.',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('tags_field'),
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (voice, audience)',
                          hintText: 'warm, shop, Saturday',
                        ),
                      ),
                    ],
                  ),
                ),

                const DeskHead(title: 'Workshop'),
                if (_workshops == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: LinearProgressIndicator(),
                  )
                else if (_workshops!.isEmpty)
                  SheetCard(
                    fill: VisualTheme.veilOf(context),
                    child: Text('No workshops yet — open one from the Workshops tab first.',
                        style: VisualTheme.body(14, color: VisualTheme.mutedOf(context))),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _workshops!
                        .map((w) => _Pick(
                              label: w.name,
                              icon: VisualTheme.trackIcon(w.room),
                              selected: _workshopId == w.id,
                              tint: VisualTheme.clay,
                              onTap: () => setState(() => _workshopId = w.id),
                            ))
                        .toList(),
                  ),

                const DeskHead(title: 'Form'),
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

                const DeskHead(title: 'Draft stage'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: VisualTheme.recallLevels
                      .map((r) => _Pick(
                            label: r,
                            selected: _stage == r,
                            tint: VisualTheme.getConditionColor(r),
                            onTap: () => setState(() => _stage = r),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 16),
                SheetCard(
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: VisualTheme.wine),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Pin to the hearth',
                            style: VisualTheme.heading(15.5, color: VisualTheme.inkOf(context))),
                      ),
                      Switch(
                        value: _pinned,
                        activeTrackColor: VisualTheme.wine,
                        onChanged: (v) => setState(() => _pinned = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                FilledButton(
                  key: const ValueKey('save_item_button'),
                  onPressed: _save,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                  child: Text(isEditing ? 'Save recipe' : 'File the recipe'),
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
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? tint : tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : tint),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: VisualTheme.heading(13.5, color: selected ? Colors.white : tint)),
          ],
        ),
      ),
    );
  }
}
