import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/core/usecases/usecase.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/reset_view_counters.dart';

import 'get_next_joke_test.mocks.dart';

void main() {
  late ResetViewCounters usecase;
  late MockJokeRepository mockRepository;

  setUp(() {
    mockRepository = MockJokeRepository();
    usecase = ResetViewCounters(mockRepository);
  });

  test('deve resetar todos os contadores de visualização no repositório',
      () async {
    // arrange
    when(mockRepository.resetViewCounters())
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(null));
    verify(mockRepository.resetViewCounters());
    verifyNoMoreInteractions(mockRepository);
  });

  test('deve retornar failure quando repositório falhar', () async {
    // arrange
    when(mockRepository.resetViewCounters())
        .thenAnswer((_) async => const Left(CacheFailure('Erro')));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Left(CacheFailure('Erro')));
    verify(mockRepository.resetViewCounters());
  });
}
