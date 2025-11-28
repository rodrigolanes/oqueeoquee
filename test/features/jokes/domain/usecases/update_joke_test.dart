import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/features/jokes/domain/entities/joke.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';
import 'package:oqueeoquee/features/jokes/domain/usecases/update_joke.dart';

import 'get_next_joke_test.mocks.dart';

void main() {
  late UpdateJoke usecase;
  late MockJokeRepository mockRepository;

  setUp(() {
    mockRepository = MockJokeRepository();
    usecase = UpdateJoke(mockRepository);
  });

  const tId = 1;
  const tQuestion = 'O que é o que é atualizado?';
  const tAnswer = 'Uma piada atualizada';
  const tParams = UpdateJokeParams(
    id: tId,
    question: tQuestion,
    answer: tAnswer,
  );

  final tJoke = Joke(
    id: tId,
    question: tQuestion,
    answer: tAnswer,
    viewCount: 5,
    deleted: false,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 2),
  );

  test('deve atualizar uma piada existente no repositório', () async {
    // arrange
    when(mockRepository.updateJoke(
      id: anyNamed('id'),
      question: anyNamed('question'),
      answer: anyNamed('answer'),
    )).thenAnswer((_) async => Right(tJoke));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, Right(tJoke));
    verify(mockRepository.updateJoke(
      id: tId,
      question: tQuestion,
      answer: tAnswer,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('deve retornar failure quando repositório falhar', () async {
    // arrange
    when(mockRepository.updateJoke(
      id: anyNamed('id'),
      question: anyNamed('question'),
      answer: anyNamed('answer'),
    )).thenAnswer((_) async => const Left(ValidationFailure('Erro')));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Left(ValidationFailure('Erro')));
    verify(mockRepository.updateJoke(
      id: tId,
      question: tQuestion,
      answer: tAnswer,
    ));
  });

  group('UpdateJokeParams', () {
    test('deve suportar igualdade de valores', () {
      // arrange
      const params1 = UpdateJokeParams(
        id: 1,
        question: 'Pergunta',
        answer: 'Resposta',
      );
      const params2 = UpdateJokeParams(
        id: 1,
        question: 'Pergunta',
        answer: 'Resposta',
      );

      // assert
      expect(params1, equals(params2));
    });

    test('props deve incluir id, question e answer', () {
      // arrange
      const params = UpdateJokeParams(
        id: 1,
        question: 'Pergunta',
        answer: 'Resposta',
      );

      // assert
      expect(params.props, [1, 'Pergunta', 'Resposta']);
    });
  });
}
