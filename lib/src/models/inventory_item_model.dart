// Item stored in containers
class InventoryItemModel {
  final int? id;
  final int containerId;
  final String name;
  final String category;
  final int quantity;
  final String condition; // Clean, In use, Dirty, Stored
  final String? purchaseDate;
  final double? estimatedValue;
  final String? notes;
  final String? photoPath;
  final String? keywords;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  InventoryItemModel({
    this.id,
    required this.containerId,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.condition = 'Clean',
    this.purchaseDate,
    this.estimatedValue,
    this.notes,
    this.photoPath,
    this.keywords,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isFavorite = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'containerId': containerId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'condition': condition,
      'purchaseDate': purchaseDate,
      'estimatedValue': estimatedValue,
      'notes': notes,
      'photoPath': photoPath,
      'keywords': keywords,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory InventoryItemModel.fromMap(Map<String, dynamic> map) {
    return InventoryItemModel(
      id: map['id'] as int?,
      containerId: map['containerId'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as int? ?? 1,
      condition: map['condition'] as String? ?? 'Clean',
      purchaseDate: map['purchaseDate'] as String?,
      estimatedValue: map['estimatedValue'] as double?,
      notes: map['notes'] as String?,
      photoPath: map['photoPath'] as String?,
      keywords: map['keywords'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
    );
  }

  InventoryItemModel copyWith({
    int? id,
    int? containerId,
    String? name,
    String? category,
    int? quantity,
    String? condition,
    String? purchaseDate,
    double? estimatedValue,
    String? notes,
    String? photoPath,
    String? keywords,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      containerId: containerId ?? this.containerId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      condition: condition ?? this.condition,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      keywords: keywords ?? this.keywords,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
