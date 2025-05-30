class Note {
  String id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
