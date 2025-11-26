import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/jokes_data.dart';
import '../models/joke.dart';
import '../services/supabase_service.dart';

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
    await _loadJokes();
    await _syncWithSupabase();
    _selectNextJoke();
    notifyListeners();
  }

  Future<void> _syncWithSupabase() async {
    if (_supabaseService == null) return;
    try {
      final remoteJokes = await _supabaseService!.fetchJokes();
      // Calcula o menor view_count local para novas piadas
      final minLocalCount = _jokes.isNotEmpty
          ? _jokes.map((j) => j.viewCount).reduce((a, b) => a < b ? a : b)
          : 0;

      // Mescla piadas remotas preservando view_count local
      Map<int, Joke> merged = {for (var j in _jokes) j.id: j};
      for (var rj in remoteJokes) {
        if (!merged.containsKey(rj.id)) {
          // Piada nova do servidor - adiciona com o menor contador local
          merged[rj.id] = rj.copyWith(viewCount: minLocalCount);
        } else if (rj.updatedAt.isAfter(merged[rj.id]!.updatedAt)) {
          // Piada atualizada no servidor - preserva view_count local
          final localViewCount = merged[rj.id]!.viewCount;
          merged[rj.id] = rj.copyWith(viewCount: localViewCount);
        }
        // Se piada local é mais recente, mantém como está
      }
      _jokes = merged.values.where((j) => !j.deleted).toList();
      await _saveJokes();
    } catch (e) {
      debugPrint('Erro ao sincronizar com Supabase: $e');
      // Continua com piadas locais se falhar
    }
  }

  Future<void> _loadJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jokesJson = prefs.getString('jokes');

    if (jokesJson != null) {
      final List<dynamic> jokesList = json.decode(jokesJson);
      _jokes = jokesList.map((j) => Joke.fromJson(j)).toList();
    } else {
      _jokes = JokesData.getInitialJokes();
      await _saveJokes();
    }
  }

  Future<void> _saveJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final String jokesJson =
        json.encode(_jokes.map((j) => j.toJson()).toList());
    await prefs.setString('jokes', jokesJson);
  }

  void _selectNextJoke() {
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
}
