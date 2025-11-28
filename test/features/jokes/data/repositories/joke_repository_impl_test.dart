import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/error/exceptions.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/features/jokes/data/datasources/joke_local_datasource.dart';
import 'package:oqueeoquee/features/jokes/data/datasources/joke_remote_datasource.dart';
import 'package:oqueeoquee/features/jokes/data/models/joke_model.dart';
import 'package:oqueeoquee/features/jokes/data/repositories/joke_repository_impl.dart';

import 'joke_repository_impl_test.mocks.dart';

@GenerateMocks([JokeLocalDataSource, JokeRemoteDataSource])
void main() {
  late JokeRepositoryImpl repository;
  late MockJokeLocalDataSource mockLocalDataSource;
  late MockJokeRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockLocalDataSource = MockJokeLocalDataSource();
    mockRemoteDataSource = MockJokeRemoteDataSource();
    repository = JokeRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

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

  group('getJokes', () {
    test('deve retornar piadas do cache local quando disponíveis', () async {
      // arrange
      when(mockLocalDataSource.getJokes()).thenAnswer((_) async => tJokeModels);

      // act
      final result = await repository.getJokes();

      // assert
      expect(result, Right(tJokeModels));
      verify(mockLocalDataSource.getJokes());
      verifyNever(mockRemoteDataSource.getJokes());
    });

    test('deve buscar remotamente quando cache está vazio', () async {
      // arrange
      when(mockLocalDataSource.getJokes()).thenAnswer((_) async => []);
      when(mockRemoteDataSource.getJokes())
          .thenAnswer((_) async => tJokeModels);
      when(mockLocalDataSource.cacheJokes(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.getJokes();

      // assert
      expect(result, Right(tJokeModels));
      verify(mockLocalDataSource.getJokes());
      verify(mockRemoteDataSource.getJokes());
      verify(mockLocalDataSource.cacheJokes(tJokeModels));
    });

    test('deve retornar CacheFailure quando houver CacheException', () async {
      // arrange
      when(mockLocalDataSource.getJokes())
          .thenThrow(CacheException('Erro no cache'));

      // act
      final result = await repository.getJokes();

      // assert
      expect(result, const Left(CacheFailure('Erro no cache')));
    });

    test('deve retornar ServerFailure quando remoto falhar', () async {
      // arrange
      when(mockLocalDataSource.getJokes()).thenAnswer((_) async => []);
      when(mockRemoteDataSource.getJokes())
          .thenThrow(ServerException('Erro no servidor'));

      // act
      final result = await repository.getJokes();

      // assert
      expect(result, const Left(ServerFailure('Erro no servidor')));
    });
  });

  group('getNextJoke', () {
    test('deve retornar piada com menor viewCount', () async {
      // arrange
      when(mockLocalDataSource.getJokes()).thenAnswer((_) async => tJokeModels);

      // act
      final result = await repository.getNextJoke();

      // assert
      result.fold(
        (failure) => fail('Should return joke'),
        (joke) {
          expect(joke.id, 2); // ID 2 tem viewCount 3 (menor que 5)
          expect(joke.viewCount, 3);
        },
      );
    });

    test('deve retornar piada mais antiga em caso de empate', () async {
      // arrange
      final tiedJokes = [
        JokeModel(
          id: 3,
          question: 'Pergunta 3',
          answer: 'Resposta 3',
          viewCount: 5,
          deleted: false,
          createdAt: DateTime.utc(2025, 1, 1),
          updatedAt: DateTime.utc(2025, 1, 1),
        ),
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
      when(mockLocalDataSource.getJokes()).thenAnswer((_) async => tiedJokes);

      // act
      final result = await repository.getNextJoke();

      // assert
      result.fold(
        (failure) => fail('Should return joke'),
        (joke) => expect(joke.id, 1), // ID menor vence
      );
    });

    test('deve retornar CacheFailure quando não houver piadas', () async {
      // arrange
      when(mockLocalDataSource.getJokes()).thenAnswer((_) async => []);

      // act
      final result = await repository.getNextJoke();

      // assert
      expect(result, const Left(CacheFailure('Nenhuma piada disponível')));
    });

    test('deve ignorar piadas deletadas', () async {
      // arrange
      final jokesWithDeleted = [
        JokeModel(
          id: 1,
          question: 'Deletada',
          answer: 'Deletada',
          viewCount: 0,
          deleted: true,
          createdAt: DateTime.utc(2025, 1, 1),
          updatedAt: DateTime.utc(2025, 1, 1),
        ),
        JokeModel(
          id: 2,
          question: 'Ativa',
          answer: 'Ativa',
          viewCount: 10,
          deleted: false,
          createdAt: DateTime.utc(2025, 1, 1),
          updatedAt: DateTime.utc(2025, 1, 1),
        ),
      ];
      when(mockLocalDataSource.getJokes())
          .thenAnswer((_) async => jokesWithDeleted);

      // act
      final result = await repository.getNextJoke();

      // assert
      result.fold(
        (failure) => fail('Should return joke'),
        (joke) => expect(joke.id, 2),
      );
    });
  });

  group('incrementViewCount', () {
    test('deve incrementar viewCount com sucesso', () async {
      // arrange
      when(mockLocalDataSource.incrementViewCount(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.incrementViewCount(1);

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.incrementViewCount(1));
    });

    test('deve retornar CacheFailure quando houver erro', () async {
      // arrange
      when(mockLocalDataSource.incrementViewCount(any))
          .thenThrow(CacheException('Erro'));

      // act
      final result = await repository.incrementViewCount(1);

      // assert
      expect(result, const Left(CacheFailure('Erro')));
    });
  });

  group('resetViewCounters', () {
    test('deve resetar contadores com sucesso', () async {
      // arrange
      when(mockLocalDataSource.resetViewCounters()).thenAnswer((_) async => {});

      // act
      final result = await repository.resetViewCounters();

      // assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.resetViewCounters());
    });
  });

  group('createJoke', () {
    final tNewJoke = JokeModel(
      id: 3,
      question: 'Nova',
      answer: 'Nova',
      viewCount: 0,
      deleted: false,
      createdAt: DateTime.utc(2025, 1, 1),
      updatedAt: DateTime.utc(2025, 1, 1),
    );

    test('deve criar piada no remoto e cachear localmente', () async {
      // arrange
      when(mockRemoteDataSource.createJoke(
        question: anyNamed('question'),
        answer: anyNamed('answer'),
      )).thenAnswer((_) async => tNewJoke);
      when(mockLocalDataSource.getJokes()).thenAnswer((_) async => tJokeModels);
      when(mockLocalDataSource.cacheJokes(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.createJoke(
        question: 'Nova',
        answer: 'Nova',
      );

      // assert
      expect(result, Right(tNewJoke));
      verify(mockRemoteDataSource.createJoke(
        question: 'Nova',
        answer: 'Nova',
      ));
      verify(mockLocalDataSource.cacheJokes(any));
    });

    test('deve retornar ValidationFailure quando dados forem inválidos',
        () async {
      // arrange
      when(mockRemoteDataSource.createJoke(
        question: anyNamed('question'),
        answer: anyNamed('answer'),
      )).thenThrow(ValidationException('Inválido'));

      // act
      final result = await repository.createJoke(
        question: '',
        answer: '',
      );

      // assert
      expect(result, const Left(ValidationFailure('Inválido')));
    });
  });

  group('updateJoke', () {
    final tUpdatedJoke = tJokeModels[0].copyWith(
      question: 'Atualizada',
      answer: 'Atualizada',
    );

    test('deve atualizar no remoto e no cache local', () async {
      // arrange
      when(mockRemoteDataSource.updateJoke(
        id: anyNamed('id'),
        question: anyNamed('question'),
        answer: anyNamed('answer'),
      )).thenAnswer((_) async => tUpdatedJoke);
      when(mockLocalDataSource.getJokes()).thenAnswer((_) async => tJokeModels);
      when(mockLocalDataSource.cacheJokes(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.updateJoke(
        id: 1,
        question: 'Atualizada',
        answer: 'Atualizada',
      );

      // assert
      expect(result, Right(tUpdatedJoke));
      verify(mockRemoteDataSource.updateJoke(
        id: 1,
        question: 'Atualizada',
        answer: 'Atualizada',
      ));
    });
  });

  group('deleteJoke', () {
    test('deve deletar no remoto e marcar como deletada no cache', () async {
      // arrange
      when(mockRemoteDataSource.deleteJoke(any)).thenAnswer((_) async => {});
      when(mockLocalDataSource.deleteJoke(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.deleteJoke(1);

      // assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.deleteJoke(1));
      verify(mockLocalDataSource.deleteJoke(1));
    });
  });

  group('syncWithRemote', () {
    test('deve sincronizar dados remotos com cache local', () async {
      // arrange
      when(mockRemoteDataSource.getJokes())
          .thenAnswer((_) async => tJokeModels);
      when(mockLocalDataSource.getJokes()).thenAnswer((_) async => tJokeModels);
      when(mockRemoteDataSource.syncViewCounts(any))
          .thenAnswer((_) async => {});
      when(mockLocalDataSource.clearCache()).thenAnswer((_) async => {});
      when(mockLocalDataSource.cacheJokes(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.syncWithRemote();

      // assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.getJokes());
      verify(mockRemoteDataSource.syncViewCounts(any));
      verify(mockLocalDataSource.clearCache());
      verify(mockLocalDataSource.cacheJokes(tJokeModels));
    });

    test('deve retornar ServerFailure quando remoto falhar', () async {
      // arrange
      when(mockRemoteDataSource.getJokes()).thenThrow(ServerException('Erro'));

      // act
      final result = await repository.syncWithRemote();

      // assert
      expect(result, const Left(ServerFailure('Erro')));
    });
  });
}
