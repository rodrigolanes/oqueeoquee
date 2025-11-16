class Joke {
  final int id;
  final String question;
  final String answer;
  int viewCount;

  Joke({
    required this.id,
    required this.question,
    required this.answer,
    this.viewCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'viewCount': viewCount,
    };
  }

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      viewCount: json['viewCount'] ?? 0,
    );
  }

  Joke copyWith({int? viewCount}) {
    return Joke(
      id: id,
      question: question,
      answer: answer,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
