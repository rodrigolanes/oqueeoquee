import '../../../../core/error/exceptions.dart';
import '../models/joke_model.dart';

/// Interface abstrata para fonte de dados local de piadas
///
/// Define o contrato para operações de persistência local (SharedPreferences)
abstract class JokeLocalDataSource {
  /// Busca todas as piadas armazenadas localmente
  ///
  /// Throws [CacheException] se houver erro ao ler do cache
  Future<List<JokeModel>> getJokes();

  /// Salva uma lista de piadas no cache local
  ///
  /// Throws [CacheException] se houver erro ao salvar no cache
  Future<void> cacheJokes(List<JokeModel> jokes);

  /// Incrementa o contador de visualizações de uma piada
  ///
  /// Throws [CacheException] se a piada não for encontrada ou erro ao salvar
  Future<void> incrementViewCount(int jokeId);

  /// Reseta todos os contadores de visualização para zero
  ///
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> resetViewCounters();

  /// Cria uma nova piada no cache local
  ///
  /// Throws [CacheException] se houver erro ao salvar
  Future<JokeModel> createJoke({
    required String question,
    required String answer,
  });

  /// Atualiza uma piada existente no cache local
  ///
  /// Throws [CacheException] se a piada não for encontrada ou erro ao salvar
  Future<JokeModel> updateJoke({
    required int id,
    required String question,
    required String answer,
  });

  /// Deleta uma piada (soft delete) do cache local
  ///
  /// Throws [CacheException] se a piada não for encontrada ou erro ao salvar
  Future<void> deleteJoke(int id);

  /// Limpa todo o cache local de piadas
  ///
  /// Usado para forçar sincronização com dados remotos
  Future<void> clearCache();
}
