import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/joke_remote_datasource.dart';
import '../models/joke_model.dart';

/// Implementação concreta do JokeRemoteDataSource usando Supabase
class JokeRemoteDataSourceImpl implements JokeRemoteDataSource {
  final SupabaseClient supabaseClient;

  JokeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<JokeModel>> getJokes() async {
    try {
      final response = await supabaseClient
          .from('jokes')
          .select()
          .eq('deleted', false)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => JokeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Erro no servidor: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao buscar piadas: ${e.toString()}');
    }
  }

  @override
  Future<JokeModel> createJoke({
    required String question,
    required String answer,
  }) async {
    try {
      if (question.trim().isEmpty || answer.trim().isEmpty) {
        throw ValidationException('Pergunta e resposta não podem estar vazias');
      }

      final now = DateTime.now();
      final data = {
        'question': question.trim(),
        'answer': answer.trim(),
        'view_count': 0,
        'deleted': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await supabaseClient
          .from('jokes')
          .insert(data)
          .select()
          .single();

      return JokeModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Erro ao criar piada: ${e.message}');
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException('Erro ao criar piada: ${e.toString()}');
    }
  }

  @override
  Future<JokeModel> updateJoke({
    required int id,
    required String question,
    required String answer,
  }) async {
    try {
      if (question.trim().isEmpty || answer.trim().isEmpty) {
        throw ValidationException('Pergunta e resposta não podem estar vazias');
      }

      final data = {
        'question': question.trim(),
        'answer': answer.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabaseClient
          .from('jokes')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return JokeModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Erro ao atualizar piada: ${e.message}');
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException('Erro ao atualizar piada: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteJoke(int id) async {
    try {
      await supabaseClient.from('jokes').update({
        'deleted': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException('Erro ao deletar piada: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao deletar piada: ${e.toString()}');
    }
  }

  @override
  Future<void> syncViewCounts(List<JokeModel> localJokes) async {
    try {
      // Prepara batch de updates para sincronizar viewCounts
      for (final joke in localJokes) {
        await supabaseClient.from('jokes').update({
          'view_count': joke.viewCount,
          'updated_at': joke.updatedAt.toIso8601String(),
        }).eq('id', joke.id);
      }
    } on PostgrestException catch (e) {
      throw ServerException('Erro ao sincronizar contadores: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao sincronizar contadores: ${e.toString()}');
    }
  }
}
