import '../../../../core/error/exceptions.dart';
import '../models/joke_model.dart';

/// Interface abstrata para fonte de dados remota de piadas
///
/// Define o contrato para operações com API remota (Supabase)
abstract class JokeRemoteDataSource {
  /// Busca todas as piadas do servidor remoto
  ///
  /// Throws [ServerException] se houver erro na comunicação
  /// Throws [NetworkException] se não houver conexão
  Future<List<JokeModel>> getJokes();

  /// Cria uma nova piada no servidor remoto (admin only)
  ///
  /// Throws [ServerException] se houver erro ao criar
  /// Throws [ValidationException] se os dados forem inválidos
  Future<JokeModel> createJoke({
    required String question,
    required String answer,
  });

  /// Atualiza uma piada existente no servidor remoto (admin only)
  ///
  /// Throws [ServerException] se houver erro ao atualizar
  /// Throws [ValidationException] se os dados forem inválidos
  Future<JokeModel> updateJoke({
    required int id,
    required String question,
    required String answer,
  });

  /// Deleta uma piada no servidor remoto (soft delete - admin only)
  ///
  /// Throws [ServerException] se houver erro ao deletar
  Future<void> deleteJoke(int id);

  /// Incrementa o contador de likes de uma piada
  ///
  /// Throws [ServerException] se houver erro ao incrementar
  /// Throws [NetworkException] se não houver conexão
  Future<void> incrementLike(int jokeId);

  /// Incrementa o contador de dislikes de uma piada
  ///
  /// Throws [ServerException] se houver erro ao incrementar
  /// Throws [NetworkException] se não houver conexão
  Future<void> incrementDislike(int jokeId);
}
