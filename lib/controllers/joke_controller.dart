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
    final remoteJokes = await _supabaseService!.fetchJokes();
    // Mescla piadas locais e remotas, resolvendo por updatedAt
    Map<int, Joke> merged = {for (var j in _jokes) j.id: j};
    for (var rj in remoteJokes) {
      if (!merged.containsKey(rj.id) ||
          rj.updatedAt.isAfter(merged[rj.id]!.updatedAt)) {
        merged[rj.id] = rj;
      }
    }
    _jokes = merged.values.where((j) => !j.deleted).toList();
    await _saveJokes();
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
      // Seleciona a primeira piada não vista (ou menos vista)
      _currentJoke = unviewedJokes.first;
      _showAnswer = false;
    }
  }

  void toggleAnswer() {
    _showAnswer = !_showAnswer;
    notifyListeners();
  }

  Future<void> nextJoke() async {
    if (_currentJoke != null) {
      // Incrementa o contador da piada atual
      final index = _jokes.indexWhere((j) => j.id == _currentJoke!.id);
      if (index != -1) {
        _jokes[index] =
            _jokes[index].copyWith(viewCount: _jokes[index].viewCount + 1);
        await _saveJokes();
      }

      // Seleciona a próxima piada
      _selectNextJoke();
      notifyListeners();
      // Se todas as piadas foram vistas, reinicia barra e mostra mensagem
      if (_jokes.every((j) => j.viewCount > 0)) {
        await resetCounters();
        // TODO: Notificar tela para mostrar mensagem "Todas as piadas vistas! Reiniciando..."
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
