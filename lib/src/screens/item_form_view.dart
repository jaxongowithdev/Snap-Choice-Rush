import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_pkg;
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late TextEditingController _valueController;
  List<ContainerModel>? _containers;
  int? _selectedContainerId;
  String _selectedCondition = 'New';
  String? _photoPath;
  final _imagePicker = ImagePicker();
  final _conditions = ['New', 'Loaned', 'Worn', 'Filed'];
  final _categories = ['Picture', 'Chapter', 'Nonfiction', 'Poetry', 'Graphic', 'Biography', 'Folktale', 'Science', 'History', 'Series', 'Teacher', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _categoryController = TextEditingController(text: widget.item?.category);
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '1');
    _notesController = TextEditingController(text: widget.item?.notes);
    _valueController = TextEditingController(text: widget.item?.estimatedValue?.toString());
    _selectedCondition = widget.item?.condition ?? 'New';
    _selectedContainerId = widget.item?.containerId ?? widget.preselectedContainerId;
    _photoPath = widget.item?.photoPath;
    _loadContainers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadContainers() async {
    try {
      final containers = await _storage.getAllContainers();
      setState(() => _containers = containers);
    } catch (e) {
      debugPrint('Error loading containers: $e');
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final photo = await _imagePicker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (photo == null) return;
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'dewey_${DateTime.now().millisecondsSinceEpoch}${path_pkg.extension(photo.path)}';
      final savedPath = path_pkg.join(appDir.path, 'photos', fileName);
      await Directory(path_pkg.join(appDir.path, 'photos')).create(recursive: true);
      await File(photo.path).copy(savedPath);
      setState(() => _photoPath = savedPath);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not add photo: $e')));
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

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedContainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a bin first')));
      return;
    }
    final item = InventoryItemModel(
      id: widget.item?.id,
      containerId: _selectedContainerId!,
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      condition: _selectedCondition,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      estimatedValue: _valueController.text.trim().isEmpty ? null : double.tryParse(_valueController.text.trim()),
      photoPath: _photoPath,
    );
    if (widget.item == null) {
      await _storage.createItem(item);
    } else {
      await _storage.updateItem(item);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit title' : 'File a title')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
          children: [
            if (_photoPath != null)
              Stack(
                children: [
                  Image.file(File(_photoPath!), height: 180, width: double.infinity, fit: BoxFit.cover),
                  Positioned(top: 8, right: 8, child: IconButton(icon: const Icon(Icons.delete, color: Colors.white), style: IconButton.styleFrom(backgroundColor: Colors.red), onPressed: _removePhoto)),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: OutlinedButton(key: const ValueKey('camera_button'), onPressed: () => _pickPhoto(ImageSource.camera), child: const Text('SNAP'))),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton(key: const ValueKey('gallery_button'), onPressed: () => _pickPhoto(ImageSource.gallery), child: const Text('ALBUM'))),
                ],
              ),
            const SizedBox(height: 16),
            TextFormField(key: const ValueKey('item_name_field'), controller: _nameController, decoration: const InputDecoration(labelText: 'Title name', hintText: 'e.g., Frog and Toad, Weather kit'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Name this title' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(key: const ValueKey('category_dropdown'), value: _categories.contains(_categoryController.text) ? _categoryController.text : null, decoration: const InputDecoration(labelText: 'Kind'), items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) { if (v != null) _categoryController.text = v; }, validator: (_) => _categoryController.text.isEmpty ? 'Pick a kind' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(key: const ValueKey('container_dropdown'), value: _selectedContainerId, decoration: const InputDecoration(labelText: 'Bin'), items: _containers?.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name} (${c.code})'))).toList(), onChanged: (v) => setState(() => _selectedContainerId = v), validator: (v) => v == null ? 'Choose a bin' : null),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(key: const ValueKey('quantity_field'), controller: _quantityController, decoration: const InputDecoration(labelText: 'Count'), keyboardType: TextInputType.number, validator: (v) => int.tryParse(v?.trim() ?? '') == null ? 'Invalid' : null)),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(key: const ValueKey('condition_dropdown'), value: _selectedCondition, decoration: const InputDecoration(labelText: 'Wear'), items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) { if (v != null) setState(() => _selectedCondition = v); })),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('value_field'), controller: _valueController, decoration: const InputDecoration(labelText: 'Replacement cost (optional)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('notes_field'), controller: _notesController, decoration: const InputDecoration(labelText: 'Librarian note', hintText: 'Last checkout, missing pages, or level'), maxLines: 3),
            const SizedBox(height: 22),
            FilledButton(key: const ValueKey('save_item_button'), onPressed: _saveItem, child: Text(isEditing ? 'Save title' : 'File title')),
          ],
        ),
      ),
    );
  }
}
