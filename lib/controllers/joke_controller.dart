import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/joke.dart';
import '../services/supabase_service.dart';
import '../utils/database_migration.dart';

class JokeController extends ChangeNotifier {
  List<Joke> _jokes = [];
  Joke? _currentJoke;
  bool _showAnswer = false;
  SupabaseService? _supabaseService;

  VoidCallback? onAllJokesViewed;

  List<Joke> get jokes => _jokes;
  Joke? get currentJoke => _currentJoke;
  bool get showAnswer => _showAnswer;

  JokeController({SupabaseService? supabaseService}) {
    _supabaseService = supabaseService;
    _initialize();
  }

  Future<void> _initialize() async {
    // Executar migrações do banco antes de carregar
    await DatabaseMigration.migrate();

    await _loadJokes();
    await _syncWithSupabase();
    _selectNextJoke();
    notifyListeners();
  }

  Future<void> _syncWithSupabase() async {
    if (_supabaseService == null) {
      debugPrint('ERRO: Supabase não configurado!');
      return;
    }

    try {
      final remoteJokes = await _supabaseService!.fetchJokes();

      if (remoteJokes.isEmpty) {
        debugPrint('AVISO: Supabase está vazio, nenhuma piada encontrada');
        return;
      }

      // Calcula o menor view_count local para novas piadas
      final minLocalCount = _jokes.isNotEmpty
          ? _jokes.map((j) => j.viewCount).reduce((a, b) => a < b ? a : b)
          : 0;

      // Mescla piadas remotas preservando view_count local
      Map<int, Joke> merged = {};

      // Primeiro, adiciona todas as piadas locais (preserva viewCount)
      for (var localJoke in _jokes) {
        merged[localJoke.id] = localJoke;
      }

      // Depois, atualiza/adiciona piadas do servidor
      for (var remoteJoke in remoteJokes) {
        if (!merged.containsKey(remoteJoke.id)) {
          // Piada nova do servidor - adiciona com o menor contador local
          merged[remoteJoke.id] = remoteJoke.copyWith(viewCount: minLocalCount);
        } else {
          // Piada já existe localmente
          final localJoke = merged[remoteJoke.id]!;

          // Se a piada remota foi atualizada, atualiza question/answer mas preserva viewCount
          if (remoteJoke.updatedAt.isAfter(localJoke.updatedAt) ||
              remoteJoke.question != localJoke.question ||
              remoteJoke.answer != localJoke.answer ||
              remoteJoke.deleted != localJoke.deleted) {
            merged[remoteJoke.id] = Joke(
              id: remoteJoke.id,
              question: remoteJoke.question,
              answer: remoteJoke.answer,
              viewCount: localJoke.viewCount, // Preserva contador local
              deleted: remoteJoke.deleted, // Atualiza status de deleted
              createdAt: remoteJoke.createdAt,
              updatedAt: remoteJoke.updatedAt,
            );
          }
        }
      }

      // Filtra piadas deletadas
      _jokes = merged.values.where((j) => !j.deleted).toList();
      await _saveJokes();

      debugPrint('Sincronização concluída: ${_jokes.length} piadas ativas');
    } catch (e) {
      debugPrint('ERRO ao sincronizar com Supabase: $e');
      // Continua com dados locais se houver
    }
  }

  Future<void> _loadJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jokesJson = prefs.getString('jokes');

    if (jokesJson != null) {
      try {
        final List<dynamic> jokesList = json.decode(jokesJson);
        _jokes = jokesList.map((j) => Joke.fromJson(j)).toList();
      } catch (e) {
        // Erro ao parsear JSON - pode ser formato antigo ou corrompido
        debugPrint('ERRO ao carregar piadas salvas: $e');
        debugPrint('Limpando dados corrompidos...');

        // Limpa dados corrompidos - piadas virão do Supabase
        await prefs.remove('jokes');
        _jokes = [];
      }
    }
    // Se não houver dados salvos, _jokes fica vazio até sincronizar com Supabase
  }

  Future<void> _saveJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final String jokesJson =
        json.encode(_jokes.map((j) => j.toJson()).toList());
    await prefs.setString('jokes', jokesJson);
  }

  void _selectNextJoke() {
    // Se não há piadas, não faz nada
    if (_jokes.isEmpty) {
      _currentJoke = null;
      debugPrint('Nenhuma piada disponível');
      return;
    }

    // Encontra o menor contador
    int minCount =
        _jokes.map((j) => j.viewCount).reduce((a, b) => a < b ? a : b);

    // Pega todas as piadas com o menor contador
    final unviewedJokes = _jokes.where((j) => j.viewCount == minCount).toList();

    if (unviewedJokes.isNotEmpty) {
      // Seleciona aleatoriamente uma piada não vista (ou menos vista)
      unviewedJokes.shuffle();
      _currentJoke = unviewedJokes.first;
      _showAnswer = false;
    }
  }

  void toggleAnswer() {
    _showAnswer = !_showAnswer;

    // Se está mostrando a resposta E é a última piada não vista
    if (_showAnswer) {
      final unviewedCount = _jokes.where((j) => j.viewCount == 0).length;
      if (unviewedCount == 1 && _currentJoke?.viewCount == 0) {
        // Esta é a última piada não vista, notifica quando mostrar a resposta
        onAllJokesViewed?.call();
      }
    }

    notifyListeners();
  }

  Future<void> nextJoke() async {
    if (_currentJoke != null) {
      // Incrementa o contador da piada atual (apenas local)
      final index = _jokes.indexWhere((j) => j.id == _currentJoke!.id);
      if (index != -1) {
        _jokes[index] = _jokes[index].copyWith(
          viewCount: _jokes[index].viewCount + 1,
        );
        await _saveJokes();
        // view_count NÃO é sincronizado - permanece apenas no aparelho
      }

      // Verifica se todas as piadas foram vistas ANTES de selecionar a próxima
      if (_jokes.every((j) => j.viewCount > 0)) {
        // Reseta sem notificar - a notificação já foi feita no toggleAnswer
        await resetCounters();
      } else {
        // Seleciona a próxima piada
        _selectNextJoke();
        notifyListeners();
      }
    }
  }

  Future<void> resetCounters() async {
    _jokes = _jokes.map((j) => j.copyWith(viewCount: 0)).toList();
    await _saveJokes();
    _selectNextJoke();
    notifyListeners();
  }

  int get totalJokes => _jokes.length;

  int get viewedJokes => _jokes.where((j) => j.viewCount > 0).length;

  // ==================== ADMIN METHODS ====================
  // Métodos disponíveis apenas para dispositivos autorizados

  /// Cria uma nova piada e sincroniza com Supabase
  Future<void> createJoke(String question, String answer) async {
    if (_supabaseService == null) {
      throw Exception('Supabase não configurado');
    }

    // Encontra o próximo ID disponível
    final maxId = _jokes.isEmpty
        ? 0
        : _jokes.map((j) => j.id).reduce((a, b) => a > b ? a : b);
    final newJoke = Joke(
      id: maxId + 1,
      question: question,
      answer: answer,
      viewCount: 0,
      deleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Salva no Supabase primeiro
      await _supabaseService!.addJoke(newJoke);

      // Se sucesso, adiciona localmente
      _jokes.add(newJoke);
      await _saveJokes();

      notifyListeners();
      debugPrint('Piada criada com sucesso: ID ${newJoke.id}');
    } catch (e) {
      debugPrint('ERRO ao criar piada: $e');
      rethrow;
    }
  }

  /// Atualiza uma piada existente e sincroniza com Supabase
  Future<void> updateJoke(int id, String question, String answer) async {
    if (_supabaseService == null) {
      throw Exception('Supabase não configurado');
    }

    final index = _jokes.indexWhere((j) => j.id == id);
    if (index == -1) {
      throw Exception('Piada não encontrada');
    }

    final updatedJoke = _jokes[index].copyWith(
      question: question,
      answer: answer,
      updatedAt: DateTime.now(),
    );

    try {
      // Atualiza no Supabase primeiro
      await _supabaseService!.updateJoke(updatedJoke);

      // Se sucesso, atualiza localmente
      _jokes[index] = updatedJoke;
      await _saveJokes();

      // Se era a piada atual, atualiza
      if (_currentJoke?.id == id) {
        _currentJoke = updatedJoke;
      }

      notifyListeners();
      debugPrint('Piada atualizada com sucesso: ID $id');
    } catch (e) {
      debugPrint('ERRO ao atualizar piada: $e');
      rethrow;
    }
  }

  /// Deleta logicamente uma piada e sincroniza com Supabase
  Future<void> deleteJoke(int id) async {
    if (_supabaseService == null) {
      throw Exception('Supabase não configurado');
    }

    final index = _jokes.indexWhere((j) => j.id == id);
    if (index == -1) {
      throw Exception('Piada não encontrada');
    }

    try {
      // Deleta no Supabase primeiro (soft delete)
      await _supabaseService!.deleteJoke(id);

      // Se sucesso, remove localmente
      _jokes.removeAt(index);
      await _saveJokes();

      // Se era a piada atual, seleciona outra
      if (_currentJoke?.id == id) {
        _selectNextJoke();
      }

      notifyListeners();
      debugPrint('Piada deletada com sucesso: ID $id');
    } catch (e) {
      debugPrint('ERRO ao deletar piada: $e');
      rethrow;
    }
  }

  /// Retorna todas as piadas (incluindo deletadas) - apenas para admin
  List<Joke> getAllJokesIncludingDeleted() {
    return List.unmodifiable(_jokes);
  }
}
