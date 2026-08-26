// Reassign log — a cue moving from one mission to another
class TransferHistoryModel {
  final int? id;
  final int itemId;
  final int fromContainerId;
  final int toContainerId;
  final DateTime moveDate;
  final String? notes;

  TransferHistoryModel({
    this.id,
    required this.itemId,
    required this.fromContainerId,
    required this.toContainerId,
    DateTime? moveDate,
    this.notes,
  }) : moveDate = moveDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'fromContainerId': fromContainerId,
      'toContainerId': toContainerId,
      'moveDate': moveDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory TransferHistoryModel.fromMap(Map<String, dynamic> map) {
    return TransferHistoryModel(
      id: map['id'] as int?,
      itemId: map['itemId'] as int,
      fromContainerId: map['fromContainerId'] as int,
      toContainerId: map['toContainerId'] as int,
      moveDate: DateTime.parse(map['moveDate'] as String),
      notes: map['notes'] as String?,
    );
  }
}
