/// Represents an item (lab, task, etc.) from the LMS backend.
class Item {
  final int id;
  final int? parentId;
  final String type;
  final String title;
  final String? description;

  Item({
    required this.id,
    this.parentId,
    required this.type,
    required this.title,
    this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      parentId: json['parent_id'] as int?,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
    );
  }

  bool get isLab => type == 'lab';
  bool get isTask => type == 'task';
}
