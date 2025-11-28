import 'dart:convert';
import '../../domain/entities/joke.dart';

/// Model que estende a entidade Joke e adiciona serialização JSON
///
/// Responsável por converter entre JSON (API/Database) e objetos Dart
class JokeModel extends Joke {
  const JokeModel({
    required super.id,
    required super.question,
    required super.answer,
    required super.viewCount,
    required super.deleted,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Cria um JokeModel a partir de um Map JSON
  ///
  /// Usado para deserializar dados do banco local ou API remota
  factory JokeModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at'] as String);
    
    return JokeModel(
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
      viewCount: (json['view_count'] as int?) ?? 0,
      deleted: (json['deleted'] as bool?) ?? false,
      createdAt: createdAt,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : createdAt,
    );
  }

  /// Converte o JokeModel para um Map JSON
  ///
  /// Usado para serializar dados para o banco local ou API remota
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

  /// Cria um JokeModel a partir de uma string JSON
  factory JokeModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return JokeModel.fromJson(json);
  }

  /// Converte o JokeModel para uma string JSON
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Cria um JokeModel a partir de uma entidade Joke
  ///
  /// Útil para converter entities do domínio em models da camada de dados
  factory JokeModel.fromEntity(Joke joke) {
    return JokeModel(
      id: joke.id,
      question: joke.question,
      answer: joke.answer,
      viewCount: joke.viewCount,
      deleted: joke.deleted,
      createdAt: joke.createdAt,
      updatedAt: joke.updatedAt,
    );
  }

  @override
  JokeModel copyWith({
    int? id,
    String? question,
    String? answer,
    int? viewCount,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JokeModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      viewCount: viewCount ?? this.viewCount,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
