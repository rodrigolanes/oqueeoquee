import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:oqueeoquee/features/jokes/data/models/joke_model.dart';
import 'package:oqueeoquee/features/jokes/domain/entities/joke.dart';

void main() {
  final tJokeModel = JokeModel(
    id: 1,
    question: 'O que é o que é?',
    answer: 'Uma piada',
    viewCount: 5,
    deleted: false,
    createdAt: DateTime.utc(2025, 1, 1, 12, 0, 0),
    updatedAt: DateTime.utc(2025, 1, 2, 14, 30, 0),
  );

  test('deve ser uma subclasse de Joke entity', () {
    expect(tJokeModel, isA<Joke>());
  });

  group('fromJson', () {
    test('deve retornar um JokeModel válido do JSON', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'question': 'O que é o que é?',
        'answer': 'Uma piada',
        'view_count': 5, // Local cache includes view_count
        'deleted': false,
        'created_at': '2025-01-01T12:00:00.000Z',
        'updated_at': '2025-01-02T14:30:00.000Z',
      };

      // act
      final result = JokeModel.fromJson(jsonMap);

      // assert
      expect(result, equals(tJokeModel));
    });

    test('deve aceitar deleted como null (default false)', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'question': 'O que é o que é?',
        'answer': 'Uma piada',
        'created_at': '2025-01-01T12:00:00.000Z',
        'updated_at': '2025-01-02T14:30:00.000Z',
      };

      // act
      final result = JokeModel.fromJson(jsonMap);

      // assert
      expect(result.deleted, false);
    });

    test('deve usar createdAt como updatedAt se updatedAt for null', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'question': 'O que é o que é?',
        'answer': 'Uma piada',
        'deleted': false,
        'created_at': '2025-01-01T12:00:00.000Z',
      };

      // act
      final result = JokeModel.fromJson(jsonMap);

      // assert
      expect(result.updatedAt, equals(result.createdAt));
    });
  });

  group('toJson', () {
    test('deve retornar um Map com dados corretos', () {
      // act
      final result = tJokeModel.toJson();

      // assert - toJson includes view_count for local cache
      final expectedMap = {
        'id': 1,
        'question': 'O que é o que é?',
        'answer': 'Uma piada',
        'view_count': 5, // Incluído para cache local
        'deleted': false,
        'created_at': '2025-01-01T12:00:00.000Z',
        'updated_at': '2025-01-02T14:30:00.000Z',
      };
      expect(result, equals(expectedMap));
    });
  });

  group('fromJsonString', () {
    test('deve retornar JokeModel a partir de uma string JSON', () {
      // arrange - Local cache JSON includes view_count
      const jsonString = '''
      {
        "id": 1,
        "question": "O que é o que é?",
        "answer": "Uma piada",
        "view_count": 5,
        "deleted": false,
        "created_at": "2025-01-01T12:00:00.000Z",
        "updated_at": "2025-01-02T14:30:00.000Z"
      }
      ''';

      // act
      final result = JokeModel.fromJsonString(jsonString);

      // assert
      expect(result, equals(tJokeModel));
    });
  });

  group('toJsonString', () {
    test('deve retornar uma string JSON válida', () {
      // act
      final result = tJokeModel.toJsonString();

      // assert
      final decoded = json.decode(result);
      expect(decoded, isA<Map<String, dynamic>>());
      expect(decoded['id'], 1);
      expect(decoded['question'], 'O que é o que é?');
    });
  });

  group('fromEntity', () {
    test('deve criar JokeModel a partir de Joke entity', () {
      // arrange
      final joke = Joke(
        id: 1,
        question: 'O que é o que é?',
        answer: 'Uma piada',
        viewCount: 5,
        deleted: false,
        createdAt: DateTime.utc(2025, 1, 1, 12, 0, 0),
        updatedAt: DateTime.utc(2025, 1, 2, 14, 30, 0),
      );

      // act
      final result = JokeModel.fromEntity(joke);

      // assert
      expect(result, equals(tJokeModel));
      expect(result, isA<JokeModel>());
    });
  });

  group('copyWith', () {
    test('deve criar uma nova instância com valores atualizados', () {
      // act
      final result = tJokeModel.copyWith(
        deleted: true,
      );

      // assert
      expect(result.deleted, true);
      expect(result.question, tJokeModel.question);
      expect(result.answer, tJokeModel.answer);
      expect(result.updatedAt.isAfter(tJokeModel.updatedAt), true);
    });
  });
}
