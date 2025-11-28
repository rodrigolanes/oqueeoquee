import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa uma piada
/// 
/// Esta é uma classe pura de domínio, sem dependências do Flutter
/// ou de detalhes de implementação (JSON, banco de dados, etc)
class Joke extends Equatable {
  final int id;
  final String question;
  final String answer;
  final int viewCount;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Joke({
    required this.id,
    required this.question,
    required this.answer,
    required this.viewCount,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma nova instância com propriedades opcionalmente atualizadas
  Joke copyWith({
    int? viewCount,
    String? question,
    String? answer,
    bool? deleted,
  }) {
    return Joke(
      id: id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      viewCount: viewCount ?? this.viewCount,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
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
      ];
}
