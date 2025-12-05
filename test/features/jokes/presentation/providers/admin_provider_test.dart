import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/features/jokes/domain/entities/joke.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/create_joke.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/update_joke.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/delete_joke.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/get_all_jokes.dart';
import 'package:oqueeoquee/features/jokes/presentation/providers/admin_provider.dart';

import 'admin_provider_test.mocks.dart';

@GenerateMocks([CreateJoke, UpdateJoke, DeleteJoke, GetAllJokes])
void main() {
  late AdminProvider provider;
  late MockCreateJoke mockCreateJoke;
  late MockUpdateJoke mockUpdateJoke;
  late MockDeleteJoke mockDeleteJoke;
  late MockGetAllJokes mockGetAllJokes;

  setUp(() {
    mockCreateJoke = MockCreateJoke();
    mockUpdateJoke = MockUpdateJoke();
    mockDeleteJoke = MockDeleteJoke();
    mockGetAllJokes = MockGetAllJokes();
    provider = AdminProvider(
      createJokeUseCase: mockCreateJoke,
      updateJokeUseCase: mockUpdateJoke,
      deleteJokeUseCase: mockDeleteJoke,
      getAllJokesUseCase: mockGetAllJokes,
    );
  });

  final tJoke = Joke(
    id: 1,
    question: 'Pergunta teste',
    answer: 'Resposta teste',
    viewCount: 0,
    deleted: false,
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );

  group('Estado inicial', () {
    test('deve ter valores iniciais corretos', () {
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.successMessage, isNull);
    });
  });

  group('createJoke', () {
    test('deve criar piada com sucesso', () async {
      // arrange
      when(mockCreateJoke(any)).thenAnswer((_) async => Right(tJoke));

      // act
      final result = await provider.createJoke(
        question: 'Nova pergunta',
        answer: 'Nova resposta',
      );

      // assert
      expect(result, true);
      expect(provider.successMessage, 'Piada criada com sucesso!');
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, false);
      verify(mockCreateJoke(any));
    });

    test('deve retornar false e setar errorMessage quando falhar', () async {
      // arrange
      when(mockCreateJoke(any)).thenAnswer(
        (_) async => const Left(ValidationFailure('Erro de validação')),
      );

      // act
      final result = await provider.createJoke(
        question: '',
        answer: '',
      );

      // assert
      expect(result, false);
      expect(provider.errorMessage, 'Erro de validação');
      expect(provider.successMessage, isNull);
      expect(provider.isLoading, false);
    });

    test('deve setar isLoading durante operação', () async {
      // arrange
      when(mockCreateJoke(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => Right(tJoke),
        ),
      );

      // act
      final future = provider.createJoke(
        question: 'Pergunta',
        answer: 'Resposta',
      );

      // assert - durante
      expect(provider.isLoading, true);

      await future;

      // assert - depois
      expect(provider.isLoading, false);
    });

    test('deve notificar listeners', () async {
      // arrange
      when(mockCreateJoke(any)).thenAnswer((_) async => Right(tJoke));
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // act
      await provider.createJoke(
        question: 'Pergunta',
        answer: 'Resposta',
      );

      // assert
      expect(notifyCount, greaterThan(0));
    });
  });

  group('updateJoke', () {
    test('deve atualizar piada com sucesso', () async {
      // arrange
      when(mockUpdateJoke(any)).thenAnswer((_) async => Right(tJoke));

      // act
      final result = await provider.updateJoke(
        id: 1,
        question: 'Pergunta atualizada',
        answer: 'Resposta atualizada',
      );

      // assert
      expect(result, true);
      expect(provider.successMessage, 'Piada atualizada com sucesso!');
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, false);
      verify(mockUpdateJoke(any));
    });

    test('deve retornar false e setar errorMessage quando falhar', () async {
      // arrange
      when(mockUpdateJoke(any)).thenAnswer(
        (_) async => const Left(ServerFailure('Erro no servidor')),
      );

      // act
      final result = await provider.updateJoke(
        id: 1,
        question: 'Pergunta',
        answer: 'Resposta',
      );

      // assert
      expect(result, false);
      expect(provider.errorMessage, 'Erro no servidor');
      expect(provider.successMessage, isNull);
    });
  });

  group('deleteJoke', () {
    test('deve deletar piada com sucesso', () async {
      // arrange
      when(mockDeleteJoke(any)).thenAnswer((_) async => const Right(null));

      // act
      final result = await provider.deleteJoke(1);

      // assert
      expect(result, true);
      expect(provider.successMessage, 'Piada deletada com sucesso!');
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, false);
      verify(mockDeleteJoke(any));
    });

    test('deve retornar false e setar errorMessage quando falhar', () async {
      // arrange
      when(mockDeleteJoke(any)).thenAnswer(
        (_) async => const Left(CacheFailure('Erro ao deletar')),
      );

      // act
      final result = await provider.deleteJoke(1);

      // assert
      expect(result, false);
      expect(provider.errorMessage, 'Erro ao deletar');
      expect(provider.successMessage, isNull);
    });
  });

  group('clearMessages', () {
    test('deve limpar mensagens de erro e sucesso', () async {
      // arrange
      when(mockCreateJoke(any)).thenAnswer((_) async => Right(tJoke));
      await provider.createJoke(question: 'P', answer: 'R');
      expect(provider.successMessage, isNotNull);

      // act
      provider.clearMessages();

      // assert
      expect(provider.errorMessage, isNull);
      expect(provider.successMessage, isNull);
    });

    test('deve notificar listeners', () {
      // arrange
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // act
      provider.clearMessages();

      // assert
      expect(notifyCount, 1);
    });
  });

  group('reset', () {
    test('deve resetar todo o estado', () async {
      // arrange
      when(mockCreateJoke(any)).thenAnswer((_) async => Right(tJoke));
      await provider.createJoke(question: 'P', answer: 'R');

      // act
      provider.reset();

      // assert
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.successMessage, isNull);
    });

    test('deve notificar listeners', () {
      // arrange
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // act
      provider.reset();

      // assert
      expect(notifyCount, 1);
    });
  });
}
