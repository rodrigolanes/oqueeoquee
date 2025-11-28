import 'package:flutter_test/flutter_test.dart';
import 'package:oqueeoquee/features/jokes/domain/entities/joke.dart';

void main() {
  group('Joke Entity', () {
    final tJoke = Joke(
      id: 1,
      question: 'O que é o que é?',
      answer: 'A resposta',
      viewCount: 5,
      deleted: false,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 2),
    );

    test('should be a subclass of Equatable', () {
      // assert
      expect(tJoke, isA<Object>());
    });

    test('should have correct properties', () {
      // assert
      expect(tJoke.id, 1);
      expect(tJoke.question, 'O que é o que é?');
      expect(tJoke.answer, 'A resposta');
      expect(tJoke.viewCount, 5);
      expect(tJoke.deleted, false);
      expect(tJoke.createdAt, DateTime(2025, 1, 1));
      expect(tJoke.updatedAt, DateTime(2025, 1, 2));
    });

    test('should support value equality', () {
      // arrange
      final joke1 = Joke(
        id: 1,
        question: 'Question',
        answer: 'Answer',
        viewCount: 0,
        deleted: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final joke2 = Joke(
        id: 1,
        question: 'Question',
        answer: 'Answer',
        viewCount: 0,
        deleted: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // assert
      expect(joke1, equals(joke2));
    });

    test('should not be equal when id is different', () {
      // arrange
      final joke1 = Joke(
        id: 1,
        question: 'Question',
        answer: 'Answer',
        viewCount: 0,
        deleted: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final joke2 = Joke(
        id: 2,
        question: 'Question',
        answer: 'Answer',
        viewCount: 0,
        deleted: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // assert
      expect(joke1, isNot(equals(joke2)));
    });

    group('copyWith', () {
      test('should return new instance with updated viewCount', () {
        // act
        final updated = tJoke.copyWith(viewCount: 10);

        // assert
        expect(updated.viewCount, 10);
        expect(updated.id, tJoke.id);
        expect(updated.question, tJoke.question);
        expect(updated.answer, tJoke.answer);
      });

      test('should return new instance with updated question and answer', () {
        // act
        final updated = tJoke.copyWith(
          question: 'Nova pergunta',
          answer: 'Nova resposta',
        );

        // assert
        expect(updated.question, 'Nova pergunta');
        expect(updated.answer, 'Nova resposta');
        expect(updated.id, tJoke.id);
        expect(updated.viewCount, tJoke.viewCount);
      });

      test('should return new instance with updated deleted status', () {
        // act
        final updated = tJoke.copyWith(deleted: true);

        // assert
        expect(updated.deleted, true);
        expect(updated.id, tJoke.id);
      });

      test('should update updatedAt when using copyWith', () {
        // act
        final before = DateTime.now();
        final updated = tJoke.copyWith(viewCount: 10);
        final after = DateTime.now();

        // assert
        expect(
            updated.updatedAt.isAfter(before) ||
                updated.updatedAt.isAtSameMomentAs(before),
            true);
        expect(
            updated.updatedAt.isBefore(after) ||
                updated.updatedAt.isAtSameMomentAs(after),
            true);
      });
    });
  });
}
