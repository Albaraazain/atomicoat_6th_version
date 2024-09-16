// lib/models/documentation.dart
class Documentation {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime lastUpdated;

  Documentation({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.lastUpdated,
  });

  factory Documentation.fromJson(Map<String, dynamic> json) {
    return Documentation(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}