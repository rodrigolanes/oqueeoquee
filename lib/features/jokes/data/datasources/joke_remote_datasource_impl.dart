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
        throw const ValidationException(
            'Pergunta e resposta não podem estar vazias');
      }

      final now = DateTime.now();
      final data = {
        'question': question.trim(),
        'answer': answer.trim(),
        'deleted': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response =
          await supabaseClient.from('jokes').insert(data).select().single();

      return JokeModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
          'Erro ao criar piada (Postgrest): ${e.message}\nCódigo: ${e.code}\nDetalhes: ${e.details}');
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(
          'Erro ao criar piada: ${e.toString()}\nTipo: ${e.runtimeType}');
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
        throw const ValidationException(
            'Pergunta e resposta não podem estar vazias');
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
  Future<void> incrementLike(int jokeId) async {
    try {
      // Usa RPC (Remote Procedure Call) do Supabase para incremento atômico
      // ou faz update direto incrementando
      await supabaseClient.rpc('increment_like', params: {'joke_id': jokeId});
    } on PostgrestException catch (e) {
      // Fallback: se RPC não existir, usa SQL direto
      if (e.code == 'PGRST202' || e.message.contains('not found')) {
        try {
          // Busca valor atual, incrementa e salva
          final current = await supabaseClient
              .from('jokes')
              .select('like_count')
              .eq('id', jokeId)
              .single();

          final newCount = (current['like_count'] as int? ?? 0) + 1;

          await supabaseClient
              .from('jokes')
              .update({'like_count': newCount}).eq('id', jokeId);
        } catch (fallbackError) {
          throw ServerException('Erro ao dar like: $fallbackError');
        }
      } else {
        throw ServerException('Erro ao dar like: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Erro ao dar like: ${e.toString()}');
    }
  }

  @override
  Future<void> incrementDislike(int jokeId) async {
    try {
      // Usa RPC (Remote Procedure Call) do Supabase para incremento atômico
      await supabaseClient
          .rpc('increment_dislike', params: {'joke_id': jokeId});
    } on PostgrestException catch (e) {
      // Fallback: se RPC não existir, usa SQL direto
      if (e.code == 'PGRST202' || e.message.contains('not found')) {
        try {
          // Busca valor atual, incrementa e salva
          final current = await supabaseClient
              .from('jokes')
              .select('dislike_count')
              .eq('id', jokeId)
              .single();

          final newCount = (current['dislike_count'] as int? ?? 0) + 1;

          await supabaseClient
              .from('jokes')
              .update({'dislike_count': newCount}).eq('id', jokeId);
        } catch (fallbackError) {
          throw ServerException('Erro ao dar dislike: $fallbackError');
        }
      } else {
        throw ServerException('Erro ao dar dislike: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Erro ao dar dislike: ${e.toString()}');
    }
  }
}
