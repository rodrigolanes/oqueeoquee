import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/error/exceptions.dart';
import 'package:oqueeoquee/features/jokes/data/datasources/joke_local_datasource_impl.dart';
import 'package:oqueeoquee/features/jokes/data/models/joke_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'joke_local_datasource_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late JokeLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = JokeLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getJokes', () {
    final tJokeModels = [
      JokeModel(
        id: 1,
        question: 'Pergunta 1',
        answer: 'Resposta 1',
        viewCount: 5,
        deleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      ),
      JokeModel(
        id: 2,
        question: 'Pergunta 2',
        answer: 'Resposta 2',
        viewCount: 3,
        deleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      ),
    ];

    test('deve retornar lista de JokeModel quando há dados no cache', () async {
      // arrange
      final jsonString = json.encode(
        tJokeModels.map((joke) => joke.toJson()).toList(),
      );
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenReturn(jsonString);

      // act
      final result = await dataSource.getJokes();

      // assert
      verify(mockSharedPreferences.getString(cachedJokesKey));
      expect(result, equals(tJokeModels));
    });

    test('deve retornar lista vazia quando não há dados no cache', () async {
      // arrange
      when(mockSharedPreferences.getString(cachedJokesKey)).thenReturn(null);

      // act
      final result = await dataSource.getJokes();

      // assert
      verify(mockSharedPreferences.getString(cachedJokesKey));
      expect(result, isEmpty);
    });

    test('deve lançar CacheException quando houver erro ao ler', () async {
      // arrange
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenThrow(Exception('Erro de leitura'));

      // act & assert
      expect(
        () => dataSource.getJokes(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('cacheJokes', () {
    final tJokeModels = [
      JokeModel(
        id: 1,
        question: 'Pergunta 1',
        answer: 'Resposta 1',
        viewCount: 5,
        deleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      ),
    ];

    test('deve salvar piadas no SharedPreferences', () async {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // act
      await dataSource.cacheJokes(tJokeModels);

      // assert
      final expectedJsonString = json.encode(
        tJokeModels.map((joke) => joke.toJson()).toList(),
      );
      verify(mockSharedPreferences.setString(
        cachedJokesKey,
        expectedJsonString,
      ));
    });

    test('deve lançar CacheException quando falhar ao salvar', () async {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => false);

      // act & assert
      expect(
        () => dataSource.cacheJokes(tJokeModels),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('incrementViewCount', () {
    final tJokeModels = [
      JokeModel(
        id: 1,
        question: 'Pergunta 1',
        answer: 'Resposta 1',
        viewCount: 5,
        deleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      ),
    ];

    test('deve incrementar viewCount da piada correta', () async {
      // arrange
      final jsonString = json.encode(
        tJokeModels.map((joke) => joke.toJson()).toList(),
      );
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenReturn(jsonString);
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // act
      await dataSource.incrementViewCount(1);

      // assert
      verify(mockSharedPreferences.getString(cachedJokesKey));
      verify(mockSharedPreferences.setString(cachedJokesKey, any));
    });

    test('deve lançar CacheException quando piada não for encontrada',
        () async {
      // arrange
      final jsonString = json.encode(
        tJokeModels.map((joke) => joke.toJson()).toList(),
      );
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenReturn(jsonString);

      // act & assert
      expect(
        () => dataSource.incrementViewCount(999),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('resetViewCounters', () {
    final tJokeModels = [
      JokeModel(
        id: 1,
        question: 'Pergunta 1',
        answer: 'Resposta 1',
        viewCount: 5,
        deleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      ),
    ];

    test('deve resetar todos os viewCount para 0', () async {
      // arrange
      final jsonString = json.encode(
        tJokeModels.map((joke) => joke.toJson()).toList(),
      );
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenReturn(jsonString);
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // act
      await dataSource.resetViewCounters();

      // assert
      verify(mockSharedPreferences.getString(cachedJokesKey));
      verify(mockSharedPreferences.setString(cachedJokesKey, any));
    });
  });

  group('createJoke', () {
    test('deve criar uma nova piada com ID incrementado', () async {
      // arrange
      final existingJokes = [
        JokeModel(
          id: 1,
          question: 'Pergunta 1',
          answer: 'Resposta 1',
          viewCount: 0,
          deleted: false,
          createdAt: DateTime.utc(2025, 1, 1),
          updatedAt: DateTime.utc(2025, 1, 1),
        ),
      ];
      final jsonString = json.encode(
        existingJokes.map((joke) => joke.toJson()).toList(),
      );
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenReturn(jsonString);
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // act
      final result = await dataSource.createJoke(
        question: 'Nova pergunta',
        answer: 'Nova resposta',
      );

      // assert
      expect(result.id, 2);
      expect(result.question, 'Nova pergunta');
      expect(result.answer, 'Nova resposta');
      expect(result.viewCount, 0);
      expect(result.deleted, false);
      verify(mockSharedPreferences.setString(cachedJokesKey, any));
    });

    test('deve criar piada com ID 1 quando cache está vazio', () async {
      // arrange
      when(mockSharedPreferences.getString(cachedJokesKey)).thenReturn(null);
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // act
      final result = await dataSource.createJoke(
        question: 'Primeira pergunta',
        answer: 'Primeira resposta',
      );

      // assert
      expect(result.id, 1);
    });
  });

  group('updateJoke', () {
    final tJokeModels = [
      JokeModel(
        id: 1,
        question: 'Pergunta antiga',
        answer: 'Resposta antiga',
        viewCount: 5,
        deleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      ),
    ];

    test('deve atualizar piada existente', () async {
      // arrange
      final jsonString = json.encode(
        tJokeModels.map((joke) => joke.toJson()).toList(),
      );
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenReturn(jsonString);
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // act
      final result = await dataSource.updateJoke(
        id: 1,
        question: 'Pergunta atualizada',
        answer: 'Resposta atualizada',
      );

      // assert
      expect(result.id, 1);
      expect(result.question, 'Pergunta atualizada');
      expect(result.answer, 'Resposta atualizada');
      expect(result.viewCount, 5); // Mantém viewCount
      verify(mockSharedPreferences.setString(cachedJokesKey, any));
    });

    test('deve lançar CacheException quando piada não for encontrada',
        () async {
      // arrange
      final jsonString = json.encode(
        tJokeModels.map((joke) => joke.toJson()).toList(),
      );
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenReturn(jsonString);

      // act & assert
      expect(
        () => dataSource.updateJoke(
          id: 999,
          question: 'Pergunta',
          answer: 'Resposta',
        ),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('deleteJoke', () {
    final tJokeModels = [
      JokeModel(
        id: 1,
        question: 'Pergunta 1',
        answer: 'Resposta 1',
        viewCount: 5,
        deleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      ),
    ];

    test('deve marcar piada como deleted (soft delete)', () async {
      // arrange
      final jsonString = json.encode(
        tJokeModels.map((joke) => joke.toJson()).toList(),
      );
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenReturn(jsonString);
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // act
      await dataSource.deleteJoke(1);

      // assert
      verify(mockSharedPreferences.getString(cachedJokesKey));
      verify(mockSharedPreferences.setString(cachedJokesKey, any));
    });

    test('deve lançar CacheException quando piada não for encontrada',
        () async {
      // arrange
      final jsonString = json.encode(
        tJokeModels.map((joke) => joke.toJson()).toList(),
      );
      when(mockSharedPreferences.getString(cachedJokesKey))
          .thenReturn(jsonString);

      // act & assert
      expect(
        () => dataSource.deleteJoke(999),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('clearCache', () {
    test('deve limpar o cache com sucesso', () async {
      // arrange
      when(mockSharedPreferences.remove(cachedJokesKey))
          .thenAnswer((_) async => true);

      // act
      await dataSource.clearCache();

      // assert
      verify(mockSharedPreferences.remove(cachedJokesKey));
    });

    test('deve lançar CacheException quando falhar ao limpar', () async {
      // arrange
      when(mockSharedPreferences.remove(cachedJokesKey))
          .thenAnswer((_) async => false);

      // act & assert
      expect(
        () => dataSource.clearCache(),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
