// Field press / nature-study journal
class ContainerModel {
  final int? id;
  final String name;
  final String code;
  final String room;
  final String shelf;
  final int capacity;
  final String? coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContainerModel({
    this.id,
    required this.name,
    required this.code,
    required this.room,
    required this.shelf,
    required this.capacity,
    this.coverImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'room': room,
      'shelf': shelf,
      'capacity': capacity,
      'coverImage': coverImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ContainerModel.fromMap(Map<String, dynamic> map) {
    return ContainerModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      code: map['code'] as String,
      room: map['room'] as String,
      shelf: map['shelf'] as String,
      capacity: map['capacity'] as int,
      coverImage: map['coverImage'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  ContainerModel copyWith({
    int? id,
    String? name,
    String? code,
    String? room,
    String? shelf,
    int? capacity,
    String? coverImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContainerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      room: room ?? this.room,
      shelf: shelf ?? this.shelf,
      capacity: capacity ?? this.capacity,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
