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

/*

class Documentation {
    /// Unique identifier for the document
    final String id;
    /// Document title
    final String title;
    /// Document content
    final String content;
    /// Document category/type
    final String category;
    /// Last update timestamp
    final DateTime lastUpdated;

    /// Constructor for creating a new documentation entry
    /// @param id: Unique identifier
    /// @param title: Document title
    /// @param content: Document content
    /// @param category: Document category
    /// @param lastUpdated: Last modification timestamp
    Documentation({
        required this.id,
        required this.title,
        required this.content,
        required this.category,
        required this.lastUpdated,
    });
}

 */