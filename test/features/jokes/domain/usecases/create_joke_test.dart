import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/features/jokes/domain/entities/joke.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/create_joke.dart';

import 'get_next_joke_test.mocks.dart';

void main() {
  late CreateJoke usecase;
  late MockJokeRepository mockRepository;

  setUp(() {
    mockRepository = MockJokeRepository();
    usecase = CreateJoke(mockRepository);
  });

  const tQuestion = 'O que é o que é?';
  const tAnswer = 'Uma piada';
  const tParams = CreateJokeParams(
    question: tQuestion,
    answer: tAnswer,
  );

  final tJoke = Joke(
    id: 1,
    question: tQuestion,
    answer: tAnswer,
    viewCount: 0,
    deleted: false,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  test('deve criar uma nova piada no repositório', () async {
    // arrange
    when(mockRepository.createJoke(
      question: anyNamed('question'),
      answer: anyNamed('answer'),
    )).thenAnswer((_) async => Right(tJoke));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, Right(tJoke));
    verify(mockRepository.createJoke(
      question: tQuestion,
      answer: tAnswer,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('deve retornar failure quando repositório falhar', () async {
    // arrange
    when(mockRepository.createJoke(
      question: anyNamed('question'),
      answer: anyNamed('answer'),
    )).thenAnswer((_) async => const Left(ValidationFailure('Erro')));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Left(ValidationFailure('Erro')));
    verify(mockRepository.createJoke(
      question: tQuestion,
      answer: tAnswer,
    ));
  });

  group('CreateJokeParams', () {
    test('deve suportar igualdade de valores', () {
      // arrange
      const params1 = CreateJokeParams(
        question: 'Pergunta',
        answer: 'Resposta',
      );
      const params2 = CreateJokeParams(
        question: 'Pergunta',
        answer: 'Resposta',
      );

      // assert
      expect(params1, equals(params2));
    });

    test('props deve incluir question e answer', () {
      // arrange
      const params = CreateJokeParams(
        question: 'Pergunta',
        answer: 'Resposta',
      );

      // assert
      expect(params.props, ['Pergunta', 'Resposta']);
    });
  });
}
