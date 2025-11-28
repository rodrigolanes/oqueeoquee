import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/increment_view_count.dart';

import 'get_next_joke_test.mocks.dart';

void main() {
  late IncrementViewCount usecase;
  late MockJokeRepository mockRepository;

  setUp(() {
    mockRepository = MockJokeRepository();
    usecase = IncrementViewCount(mockRepository);
  });

  const tJokeId = 1;
  const tParams = IncrementViewCountParams(jokeId: tJokeId);

  test('deve incrementar o contador de visualizações no repositório', () async {
    // arrange
    when(mockRepository.incrementViewCount(any))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Right(null));
    verify(mockRepository.incrementViewCount(tJokeId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('deve retornar failure quando repositório falhar', () async {
    // arrange
    when(mockRepository.incrementViewCount(any))
        .thenAnswer((_) async => const Left(CacheFailure('Erro')));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Left(CacheFailure('Erro')));
    verify(mockRepository.incrementViewCount(tJokeId));
  });

  group('IncrementViewCountParams', () {
    test('deve suportar igualdade de valores', () {
      // arrange
      const params1 = IncrementViewCountParams(jokeId: 1);
      const params2 = IncrementViewCountParams(jokeId: 1);

      // assert
      expect(params1, equals(params2));
    });

    test('props deve incluir jokeId', () {
      // arrange
      const params = IncrementViewCountParams(jokeId: 1);

      // assert
      expect(params.props, [1]);
    });
  });
}
