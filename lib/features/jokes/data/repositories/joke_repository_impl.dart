import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/joke.dart';
import '../../domain/repositories/joke_repository.dart';
import '../datasources/joke_local_datasource.dart';
import '../datasources/joke_remote_datasource.dart';

/// Implementação concreta do JokeRepository
///
/// Coordena dados locais e remotos, gerencia cache e sincronização
class JokeRepositoryImpl implements JokeRepository {
  final JokeLocalDataSource localDataSource;
  final JokeRemoteDataSource remoteDataSource;

  JokeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Joke>>> getJokes() async {
    try {
      // Tenta buscar do cache local primeiro
      final localJokes = await localDataSource.getJokes();

      if (localJokes.isNotEmpty) {
        return Right(localJokes);
      }

      // Se cache vazio, busca do remoto e cacheia
      try {
        final remoteJokes = await remoteDataSource.getJokes();
        await localDataSource.cacheJokes(remoteJokes);
        return Right(remoteJokes);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Joke>> getNextJoke() async {
    try {
      // Primeiro garante que temos piadas (busca do remoto se cache vazio)
      final jokesResult = await getJokes();

      return jokesResult.fold(
        (failure) => Left(failure),
        (jokes) {
          // Filtra piadas não deletadas
          final activeJokes = jokes.where((joke) => !joke.deleted).toList();

          if (activeJokes.isEmpty) {
            return const Left(CacheFailure('Nenhuma piada ativa disponível'));
          }

          // Estratégia: retorna a piada com menor viewCount
          activeJokes.sort((a, b) => a.viewCount.compareTo(b.viewCount));

          // Se houver empate, usa a mais antiga (menor ID)
          final minViewCount = activeJokes.first.viewCount;

          Joke? leastViewed;
          for (final joke in activeJokes) {
            if (joke.viewCount == minViewCount) {
              if (leastViewed == null || joke.id < leastViewed.id) {
                leastViewed = joke;
              }
            }
          }

          return Right(leastViewed!);
        },
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(int jokeId) async {
    try {
      await localDataSource.incrementViewCount(jokeId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetViewCounters() async {
    try {
      await localDataSource.resetViewCounters();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Joke>> createJoke({
    required String question,
    required String answer,
  }) async {
    try {
      // Cria no servidor remoto primeiro
      final remoteJoke = await remoteDataSource.createJoke(
        question: question,
        answer: answer,
      );

      // Adiciona ao cache local
      final localJokes = await localDataSource.getJokes();
      localJokes.add(remoteJoke);
      await localDataSource.cacheJokes(localJokes);

      return Right(remoteJoke);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Joke>> updateJoke({
    required int id,
    required String question,
    required String answer,
  }) async {
    try {
      // Atualiza no servidor remoto primeiro
      final updatedJoke = await remoteDataSource.updateJoke(
        id: id,
        question: question,
        answer: answer,
      );

      // Atualiza no cache local
      final localJokes = await localDataSource.getJokes();
      final index = localJokes.indexWhere((joke) => joke.id == id);

      if (index != -1) {
        localJokes[index] = updatedJoke;
        await localDataSource.cacheJokes(localJokes);
      }

      return Right(updatedJoke);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteJoke(int id) async {
    try {
      // Deleta no servidor remoto primeiro
      await remoteDataSource.deleteJoke(id);

      // Marca como deletado no cache local
      await localDataSource.deleteJoke(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> syncWithRemote() async {
    try {
      // Busca piadas remotas
      final remoteJokes = await remoteDataSource.getJokes();

      // Sincroniza viewCounts locais com servidor
      final localJokes = await localDataSource.getJokes();
      if (localJokes.isNotEmpty) {
        await remoteDataSource.syncViewCounts(localJokes);
      }

      // Atualiza cache local com dados remotos
      await localDataSource.clearCache();
      await localDataSource.cacheJokes(remoteJokes);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
