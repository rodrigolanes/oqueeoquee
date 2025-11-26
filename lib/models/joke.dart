class Joke {
  final int id;
  final String question;
  final String answer;
  int viewCount;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Joke({
    required this.id,
    required this.question,
    required this.answer,
    this.viewCount = 0,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'viewCount': viewCount,
      'deleted': deleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      viewCount: json['viewCount'] ?? 0,
      deleted: json['deleted'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Joke copyWith({
    int? viewCount,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Joke(
      id: id,
      question: question,
      answer: answer,
      viewCount: viewCount ?? this.viewCount,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
