import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/features/jokes/domain/entities/joke.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/get_next_joke.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/increment_view_count.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/reset_view_counters.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/like_joke.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/dislike_joke.dart';
import 'package:oqueeoquee/features/jokes/presentation/providers/joke_provider.dart';

import 'joke_provider_test.mocks.dart';

@GenerateMocks([GetNextJoke, IncrementViewCount, ResetViewCounters, LikeJoke, DislikeJoke])
void main() {
  late JokeProvider provider;
  late MockGetNextJoke mockGetNextJoke;
  late MockIncrementViewCount mockIncrementViewCount;
  late MockResetViewCounters mockResetViewCounters;
  late MockLikeJoke mockLikeJoke;
  late MockDislikeJoke mockDislikeJoke;

  setUp(() {
    mockGetNextJoke = MockGetNextJoke();
    mockIncrementViewCount = MockIncrementViewCount();
    mockResetViewCounters = MockResetViewCounters();
    mockLikeJoke = MockLikeJoke();
    mockDislikeJoke = MockDislikeJoke();
    provider = JokeProvider(
      getNextJokeUseCase: mockGetNextJoke,
      incrementViewCountUseCase: mockIncrementViewCount,
      resetViewCountersUseCase: mockResetViewCounters,
      likeJokeUseCase: mockLikeJoke,
      dislikeJokeUseCase: mockDislikeJoke,
    );
  });

  final tJoke = Joke(
    id: 1,
    question: 'O que é o que é?',
    answer: 'Uma piada',
    viewCount: 5,
    deleted: false,
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );

  group('Estado inicial', () {
    test('deve ter valores iniciais corretos', () {
      expect(provider.currentJoke, isNull);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.answerRevealed, false);
      expect(provider.hasJoke, false);
    });
  });

  group('loadNextJoke', () {
    test('deve carregar piada com sucesso', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer((_) async => Right(tJoke));

      // act
      await provider.loadNextJoke();

      // assert
      expect(provider.currentJoke, tJoke);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.answerRevealed, false);
      expect(provider.hasJoke, true);
      verify(mockGetNextJoke(any));
    });

    test('deve setar isLoading durante carregamento', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => Right(tJoke),
        ),
      );

      // act
      final future = provider.loadNextJoke();

      // assert - durante
      expect(provider.isLoading, true);

      await future;

      // assert - depois
      expect(provider.isLoading, false);
    });

    test('deve limpar answerRevealed ao carregar nova piada', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer((_) async => Right(tJoke));
      when(mockIncrementViewCount(any))
          .thenAnswer((_) async => const Right(null));

      // Revela resposta da primeira piada
      await provider.loadNextJoke();
      provider.revealAnswer();
      expect(provider.answerRevealed, true);

      // act - carrega nova piada
      await provider.loadNextJoke();

      // assert
      expect(provider.answerRevealed, false);
    });

    test('deve setar errorMessage quando falhar', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer(
        (_) async => const Left(CacheFailure('Erro ao buscar piada')),
      );

      // act
      await provider.loadNextJoke();

      // assert
      expect(provider.errorMessage, 'Erro ao buscar piada');
      expect(provider.currentJoke, isNull);
      expect(provider.isLoading, false);
    });

    test('deve notificar listeners', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer((_) async => Right(tJoke));
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // act
      await provider.loadNextJoke();

      // assert
      expect(notifyCount, greaterThan(0));
    });
  });

  group('revealAnswer', () {
    test('deve revelar resposta quando há piada', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer((_) async => Right(tJoke));
      when(mockIncrementViewCount(any))
          .thenAnswer((_) async => const Right(null));
      await provider.loadNextJoke();

      // act
      provider.revealAnswer();

      // assert
      expect(provider.answerRevealed, true);
    });

    test('deve incrementar viewCount ao revelar', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer((_) async => Right(tJoke));
      when(mockIncrementViewCount(any))
          .thenAnswer((_) async => const Right(null));
      await provider.loadNextJoke();

      // act
      provider.revealAnswer();

      // Aguarda processamento assíncrono
      await Future.delayed(const Duration(milliseconds: 10));

      // assert
      verify(mockIncrementViewCount(const IncrementViewCountParams(jokeId: 1)));
    });

    test('não deve fazer nada quando não há piada', () {
      // act
      provider.revealAnswer();

      // assert
      expect(provider.answerRevealed, false);
      verifyNever(mockIncrementViewCount(any));
    });

    test('não deve incrementar contador novamente se já revelado', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer((_) async => Right(tJoke));
      when(mockIncrementViewCount(any))
          .thenAnswer((_) async => const Right(null));
      await provider.loadNextJoke();

      // act
      provider.revealAnswer();
      await Future.delayed(const Duration(milliseconds: 10));
      provider.revealAnswer(); // Segunda chamada

      // assert
      verify(mockIncrementViewCount(any)).called(1); // Apenas uma vez
    });

    test('deve notificar listeners', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer((_) async => Right(tJoke));
      when(mockIncrementViewCount(any))
          .thenAnswer((_) async => const Right(null));
      await provider.loadNextJoke();

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // act
      provider.revealAnswer();

      // assert
      expect(notifyCount, 1);
    });
  });

  group('resetCounters', () {
    test('deve resetar contadores e recarregar piada', () async {
      // arrange
      when(mockResetViewCounters(any))
          .thenAnswer((_) async => const Right(null));
      when(mockGetNextJoke(any)).thenAnswer((_) async => Right(tJoke));

      // act
      await provider.resetCounters();

      // Aguarda o loadNextJoke completar
      await Future.delayed(const Duration(milliseconds: 10));

      // assert
      verify(mockResetViewCounters(any));
      verify(mockGetNextJoke(any)); // Recarrega após reset
    });

    test('deve setar errorMessage quando falhar', () async {
      // arrange
      when(mockResetViewCounters(any)).thenAnswer(
        (_) async => const Left(CacheFailure('Erro ao resetar')),
      );

      // act
      await provider.resetCounters();

      // assert
      expect(provider.errorMessage, 'Erro ao resetar');
      expect(provider.isLoading, false);
      verifyNever(mockGetNextJoke(any)); // Não recarrega se falhou
    });
  });

  group('clearError', () {
    test('deve limpar mensagem de erro', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer(
        (_) async => const Left(CacheFailure('Erro')),
      );
      await provider.loadNextJoke();
      expect(provider.errorMessage, isNotNull);

      // act
      provider.clearError();

      // assert
      expect(provider.errorMessage, isNull);
    });

    test('deve notificar listeners', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer(
        (_) async => const Left(CacheFailure('Erro')),
      );
      await provider.loadNextJoke();

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // act
      provider.clearError();

      // assert
      expect(notifyCount, 1);
    });
  });

  group('reset', () {
    test('deve resetar todo o estado', () async {
      // arrange
      when(mockGetNextJoke(any)).thenAnswer((_) async => Right(tJoke));
      when(mockIncrementViewCount(any))
          .thenAnswer((_) async => const Right(null));
      await provider.loadNextJoke();
      provider.revealAnswer();

      // act
      provider.reset();

      // assert
      expect(provider.currentJoke, isNull);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.answerRevealed, false);
      expect(provider.hasJoke, false);
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
