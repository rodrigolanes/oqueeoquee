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
      'view_count': viewCount,
      'deleted': deleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Joke.fromJson(Map<String, dynamic> json) {
    try {
      return Joke(
        id: json['id'],
        question: json['question'],
        answer: json['answer'],
        viewCount: json['view_count'] ?? json['viewCount'] ?? 0,
        deleted: json['deleted'] ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : DateTime.now(),
      );
    } catch (e) {
      // Se falhar, retorna com valores padrão
      return Joke(
        id: json['id'] ?? 0,
        question: json['question'] ?? '',
        answer: json['answer'] ?? '',
        viewCount: 0,
        deleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Joke copyWith({
    int? viewCount,
    String? question,
    String? answer,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Joke(
      id: id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      viewCount: viewCount ?? this.viewCount,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
