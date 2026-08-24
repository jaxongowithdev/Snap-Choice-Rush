import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../models/transfer_history_model.dart';
import '../models/user_preferences.dart';

class StorageManager {
  static final StorageManager instance = StorageManager._init();
  static Database? _database;

  StorageManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('press_leaf.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Containers table
    await db.execute('''
      CREATE TABLE containers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        room TEXT NOT NULL,
        shelf TEXT NOT NULL,
        capacity INTEGER NOT NULL DEFAULT 50,
        coverImage TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Items table
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        containerId INTEGER NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        condition TEXT NOT NULL DEFAULT 'Fresh',
        purchaseDate TEXT,
        estimatedValue REAL,
        notes TEXT,
        photoPath TEXT,
        keywords TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (containerId) REFERENCES containers (id) ON DELETE CASCADE
      )
    ''');

    // Transfer history table
    await db.execute('''
      CREATE TABLE transfers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId INTEGER NOT NULL,
        fromContainerId INTEGER NOT NULL,
        toContainerId INTEGER NOT NULL,
        moveDate TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (itemId) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY CHECK (id = 1),
        theme TEXT NOT NULL DEFAULT 'system',
        language TEXT NOT NULL DEFAULT 'en',
        capacityUnit TEXT NOT NULL DEFAULT 'slips',
        defaultBoxPrefix TEXT NOT NULL DEFAULT 'LEAF',
        showOnboarding INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Insert default settings
    await db.insert('settings', UserPreferences().toMap()..['id'] = 1);
  }

  // ============ Containers CRUD ============

  Future<int> createContainer(ContainerModel container) async {
    final db = await database;
    return await db.insert('containers', container.toMap());
  }

  Future<List<ContainerModel>> getAllContainers({String? sortBy}) async {
    final db = await database;
    String orderBy = 'updatedAt DESC';

    if (sortBy == 'name') {
      orderBy = 'name ASC';
    } else if (sortBy == 'room') {
      orderBy = 'room ASC, name ASC';
    } else if (sortBy == 'updated') {
      orderBy = 'updatedAt DESC';
    }

    final maps = await db.query('containers', orderBy: orderBy);
    return maps.map((map) => ContainerModel.fromMap(map)).toList();
  }

  Future<ContainerModel?> getContainer(int id) async {
    final db = await database;
    final maps = await db.query(
      'containers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ContainerModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateContainer(ContainerModel container) async {
    final db = await database;
    return await db.update(
      'containers',
      container.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [container.id],
    );
  }

  Future<int> deleteContainer(int id) async {
    final db = await database;
    return await db.delete(
      'containers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getItemCountInContainer(int containerId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM items WHERE containerId = ?',
      [containerId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============ Items CRUD ============

  Future<int> createItem(InventoryItemModel item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<InventoryItemModel>> getAllItems() async {
    final db = await database;
    final maps = await db.query('items', orderBy: 'updatedAt DESC');
    return maps.map((map) => InventoryItemModel.fromMap(map)).toList();
  }

  Future<List<InventoryItemModel>> getItemsByContainer(int containerId) async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'containerId = ?',
      whereArgs: [containerId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => InventoryItemModel.fromMap(map)).toList();
  }

  Future<InventoryItemModel?> getItem(int id) async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return InventoryItemModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateItem(InventoryItemModel item) async {
    final db = await database;
    return await db.update(
      'items',
      item.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<InventoryItemModel>> searchItems(String query) async {
    final db = await database;
    final searchTerm = '%$query%';
    final maps = await db.query(
      'items',
      where: 'name LIKE ? OR category LIKE ? OR keywords LIKE ? OR notes LIKE ?',
      whereArgs: [searchTerm, searchTerm, searchTerm, searchTerm],
      orderBy: 'name ASC',
    );
    return maps.map((map) => InventoryItemModel.fromMap(map)).toList();
  }

  Future<List<InventoryItemModel>> getFavoriteItems() async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => InventoryItemModel.fromMap(map)).toList();
  }

  // ============ Transfer History ============

  Future<int> createTransfer(TransferHistoryModel transfer) async {
    final db = await database;
    return await db.insert('transfers', transfer.toMap());
  }

  Future<List<TransferHistoryModel>> getTransferHistory({int? itemId}) async {
    final db = await database;

    if (itemId != null) {
      final maps = await db.query(
        'transfers',
        where: 'itemId = ?',
        whereArgs: [itemId],
        orderBy: 'moveDate DESC',
      );
      return maps.map((map) => TransferHistoryModel.fromMap(map)).toList();
    }

    final maps = await db.query('transfers', orderBy: 'moveDate DESC', limit: 50);
    return maps.map((map) => TransferHistoryModel.fromMap(map)).toList();
  }

  Future<void> moveItem(int itemId, int fromContainerId, int toContainerId, String? notes) async {
    final db = await database;

    // Update item's container
    await db.update(
      'items',
      {'containerId': toContainerId, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [itemId],
    );

    // Record transfer
    await createTransfer(TransferHistoryModel(
      itemId: itemId,
      fromContainerId: fromContainerId,
      toContainerId: toContainerId,
      notes: notes,
    ));
  }

  // ============ Statistics ============

  Future<Map<String, int>> getStatistics() async {
    final db = await database;

    final totalContainers = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM containers')
    ) ?? 0;

    final totalItems = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM items')
    ) ?? 0;

    final emptyContainers = Sqflite.firstIntValue(
      await db.rawQuery('''
        SELECT COUNT(*) FROM containers
        WHERE id NOT IN (SELECT DISTINCT containerId FROM items)
      ''')
    ) ?? 0;

    return {
      'totalContainers': totalContainers,
      'totalItems': totalItems,
      'emptyContainers': emptyContainers,
    };
  }

  Future<Map<String, int>> getItemsByCategory() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM items
      GROUP BY category
      ORDER BY count DESC
    ''');

    Map<String, int> categories = {};
    for (var row in result) {
      categories[row['category'] as String] = row['count'] as int;
    }
    return categories;
  }

  Future<Map<String, int>> getItemsByRoom() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT c.room, COUNT(i.id) as count
      FROM containers c
      LEFT JOIN items i ON c.id = i.containerId
      GROUP BY c.room
      ORDER BY count DESC
    ''');

    Map<String, int> rooms = {};
    for (var row in result) {
      rooms[row['room'] as String] = row['count'] as int;
    }
    return rooms;
  }

  Future<List<Map<String, dynamic>>> getRecentlyUpdatedContainers({int limit = 5}) async {
    final db = await database;
    final maps = await db.query(
      'containers',
      orderBy: 'updatedAt DESC',
      limit: limit,
    );
    return maps;
  }

  // ============ Settings ============

  Future<UserPreferences> getPreferences() async {
    final db = await database;
    final maps = await db.query('settings', where: 'id = 1');

    if (maps.isNotEmpty) {
      return UserPreferences.fromMap(maps.first);
    }
    return UserPreferences();
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    final db = await database;
    await db.update(
      'settings',
      preferences.toMap(),
      where: 'id = 1',
    );
  }

  // ============ Backup & Export ============

  Future<Map<String, dynamic>> exportData() async {
    final containers = await getAllContainers();
    final items = await getAllItems();
    final transfers = await getTransferHistory();
    final preferences = await getPreferences();

    return {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'containers': containers.map((c) => c.toMap()).toList(),
      'items': items.map((i) => i.toMap()).toList(),
      'transfers': transfers.map((t) => t.toMap()).toList(),
      'preferences': preferences.toMap(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;

    // Clear existing data
    await db.delete('transfers');
    await db.delete('items');
    await db.delete('containers');

    // Import containers
    if (data['containers'] != null) {
      for (var containerMap in data['containers']) {
        await db.insert('containers', containerMap);
      }
    }

    // Import items
    if (data['items'] != null) {
      for (var itemMap in data['items']) {
        await db.insert('items', itemMap);
      }
    }

    // Import transfers
    if (data['transfers'] != null) {
      for (var transferMap in data['transfers']) {
        await db.insert('transfers', transferMap);
      }
    }

    // Import preferences
    if (data['preferences'] != null) {
      await db.update('settings', data['preferences'], where: 'id = 1');
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
