import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/usecases/usecase.dart';
import 'package:oqueeoquee/features/jokes/domain/entities/joke.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/get_next_joke.dart';

import 'get_next_joke_test.mocks.dart';

@GenerateMocks([JokeRepository])
void main() {
  late GetNextJoke usecase;
  late MockJokeRepository mockRepository;

  setUp(() {
    mockRepository = MockJokeRepository();
    usecase = GetNextJoke(mockRepository);
  });

  final tJoke = Joke(
    id: 1,
    question: 'O que é o que é?',
    answer: 'Uma piada de teste',
    viewCount: 0,
    deleted: false,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  test('deve buscar a próxima piada do repositório', () async {
    // arrange
    when(mockRepository.getNextJoke()).thenAnswer((_) async => Right(tJoke));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, Right(tJoke));
    verify(mockRepository.getNextJoke());
    verifyNoMoreInteractions(mockRepository);
  });
}
