import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/delete_joke.dart';

import 'get_next_joke_test.mocks.dart';

void main() {
  late DeleteJoke usecase;
  late MockJokeRepository mockRepository;

  setUp(() {
    mockRepository = MockJokeRepository();
    usecase = DeleteJoke(mockRepository);
  });

  const tJokeId = 1;
  const tParams = DeleteJokeParams(jokeId: tJokeId);

  test('deve deletar uma piada no repositório', () async {
    // arrange
    when(mockRepository.deleteJoke(any))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Right(null));
    verify(mockRepository.deleteJoke(tJokeId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('deve retornar failure quando repositório falhar', () async {
    // arrange
    when(mockRepository.deleteJoke(any))
        .thenAnswer((_) async => const Left(CacheFailure('Erro')));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Left(CacheFailure('Erro')));
    verify(mockRepository.deleteJoke(tJokeId));
  });

  group('DeleteJokeParams', () {
    test('deve suportar igualdade de valores', () {
      // arrange
      const params1 = DeleteJokeParams(jokeId: 1);
      const params2 = DeleteJokeParams(jokeId: 1);

      // assert
      expect(params1, equals(params2));
    });

    test('props deve incluir jokeId', () {
      // arrange
      const params = DeleteJokeParams(jokeId: 1);

      // assert
      expect(params.props, [1]);
    });
  });
}
