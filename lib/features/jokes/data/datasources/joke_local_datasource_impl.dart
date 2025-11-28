import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/joke_local_datasource.dart';
import '../models/joke_model.dart';

const CACHED_JOKES_KEY = 'CACHED_JOKES';

/// Implementação concreta do JokeLocalDataSource usando SharedPreferences
class JokeLocalDataSourceImpl implements JokeLocalDataSource {
  final SharedPreferences sharedPreferences;

  JokeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<JokeModel>> getJokes() async {
    try {
      final jsonString = sharedPreferences.getString(CACHED_JOKES_KEY);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => JokeModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Erro ao ler piadas do cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheJokes(List<JokeModel> jokes) async {
    try {
      final jsonList = jokes.map((joke) => joke.toJson()).toList();
      final jsonString = json.encode(jsonList);

      final success = await sharedPreferences.setString(
        CACHED_JOKES_KEY,
        jsonString,
      );

      if (!success) {
        throw CacheException('Falha ao salvar piadas no cache');
      }
    } catch (e) {
      throw CacheException('Erro ao salvar piadas no cache: ${e.toString()}');
    }
  }

  @override
  Future<void> incrementViewCount(int jokeId) async {
    try {
      final jokes = await getJokes();
      final index = jokes.indexWhere((joke) => joke.id == jokeId);

      if (index == -1) {
        throw CacheException('Piada com ID $jokeId não encontrada');
      }

      jokes[index] = jokes[index].copyWith(
        viewCount: jokes[index].viewCount + 1,
      );

      await cacheJokes(jokes);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Erro ao incrementar contador: ${e.toString()}');
    }
  }

  @override
  Future<void> resetViewCounters() async {
    try {
      final jokes = await getJokes();
      final resetJokes =
          jokes.map((joke) => joke.copyWith(viewCount: 0)).toList();

      await cacheJokes(resetJokes);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Erro ao resetar contadores: ${e.toString()}');
    }
  }

  @override
  Future<JokeModel> createJoke({
    required String question,
    required String answer,
  }) async {
    try {
      final jokes = await getJokes();

      // Gera novo ID baseado no maior ID existente
      final newId = jokes.isEmpty
          ? 1
          : jokes.map((j) => j.id).reduce((a, b) => a > b ? a : b) + 1;

      final now = DateTime.now();
      final newJoke = JokeModel(
        id: newId,
        question: question,
        answer: answer,
        viewCount: 0,
        deleted: false,
        createdAt: now,
        updatedAt: now,
      );

      jokes.add(newJoke);
      await cacheJokes(jokes);

      return newJoke;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Erro ao criar piada: ${e.toString()}');
    }
  }

  @override
  Future<JokeModel> updateJoke({
    required int id,
    required String question,
    required String answer,
  }) async {
    try {
      final jokes = await getJokes();
      final index = jokes.indexWhere((joke) => joke.id == id);

      if (index == -1) {
        throw CacheException('Piada com ID $id não encontrada');
      }

      final updatedJoke = jokes[index].copyWith(
        question: question,
        answer: answer,
      );

      jokes[index] = updatedJoke;
      await cacheJokes(jokes);

      return updatedJoke;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Erro ao atualizar piada: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteJoke(int id) async {
    try {
      final jokes = await getJokes();
      final index = jokes.indexWhere((joke) => joke.id == id);

      if (index == -1) {
        throw CacheException('Piada com ID $id não encontrada');
      }

      jokes[index] = jokes[index].copyWith(deleted: true);
      await cacheJokes(jokes);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Erro ao deletar piada: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final success = await sharedPreferences.remove(CACHED_JOKES_KEY);

      if (!success) {
        throw CacheException('Falha ao limpar cache');
      }
    } catch (e) {
      throw CacheException('Erro ao limpar cache: ${e.toString()}');
    }
  }
}
