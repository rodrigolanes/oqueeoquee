import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa uma piada
///
/// Esta é uma classe pura de domínio, sem dependências do Flutter
/// ou de detalhes de implementação (JSON, banco de dados, etc)
class Joke extends Equatable {
  final int id;
  final String question;
  final String answer;
  final int viewCount; // Local only - not synced with Supabase
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? likeCount;
  final int? dislikeCount;

  const Joke({
    required this.id,
    required this.question,
    required this.answer,
    required this.viewCount,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount,
    this.dislikeCount,
  });

  /// Cria uma nova instância com propriedades opcionalmente atualizadas
  Joke copyWith({
    int? viewCount,
    String? question,
    String? answer,
    bool? deleted,
    int? likeCount,
    int? dislikeCount,
  }) {
    return Joke(
      id: id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      viewCount: viewCount ?? this.viewCount,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        question,
        answer,
        viewCount,
        deleted,
        createdAt,
        updatedAt,
        likeCount,
        dislikeCount,
      ];
}
