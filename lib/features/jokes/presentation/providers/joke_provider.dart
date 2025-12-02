import 'package:flutter/foundation.dart';
import '../../domain/entities/joke.dart';
import '../../domain/usecases/get_next_joke.dart';
import '../../domain/usecases/increment_view_count.dart';
import '../../domain/usecases/reset_view_counters.dart';
import '../../domain/usecases/like_joke.dart';
import '../../domain/usecases/dislike_joke.dart';
import '../../../../core/usecases/usecase.dart';

/// Provider para gerenciar estado de piadas do usuário
///
/// Usa Clean Architecture com use cases do domínio
class JokeProvider extends ChangeNotifier {
  final GetNextJoke getNextJokeUseCase;
  final IncrementViewCount incrementViewCountUseCase;
  final ResetViewCounters resetViewCountersUseCase;
  final LikeJoke likeJokeUseCase;
  final DislikeJoke dislikeJokeUseCase;

  JokeProvider({
    required this.getNextJokeUseCase,
    required this.incrementViewCountUseCase,
    required this.resetViewCountersUseCase,
    required this.likeJokeUseCase,
    required this.dislikeJokeUseCase,
  });

  // Estado
  Joke? _currentJoke;
  bool _isLoading = false;
  String? _errorMessage;
  bool _answerRevealed = false;
  final Set<int> _votedJokes = {}; // IDs das piadas votadas na sessão atual

  // Getters
  Joke? get currentJoke => _currentJoke;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get answerRevealed => _answerRevealed;
  bool get hasJoke => _currentJoke != null;

  /// Verifica se a piada atual já foi votada (like ou dislike)
  bool get hasVoted {
    if (_currentJoke == null) return false;
    return _votedJokes.contains(_currentJoke!.id);
  }

  /// Carrega a próxima piada
  Future<void> loadNextJoke() async {
    _isLoading = true;
    _errorMessage = null;
    _answerRevealed = false;
    notifyListeners();

    final result = await getNextJokeUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _currentJoke = null;
        _isLoading = false;
        notifyListeners();
      },
      (joke) {
        _currentJoke = joke;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Revela a resposta da piada atual
  void revealAnswer() {
    if (_currentJoke != null && !_answerRevealed) {
      _answerRevealed = true;
      notifyListeners();

      // Incrementa contador de visualização
      _incrementCurrentJokeViewCount();
    }
  }

  /// Incrementa viewCount da piada atual
  Future<void> _incrementCurrentJokeViewCount() async {
    if (_currentJoke == null) return;

    final jokeId = _currentJoke!.id;
    final result = await incrementViewCountUseCase(
      IncrementViewCountParams(jokeId: jokeId),
    );

    result.fold(
      (failure) {
        // Log silencioso do erro, não afeta UX
        debugPrint('Erro ao incrementar contador: ${failure.message}');
      },
      (_) {
        // Contador incrementado com sucesso
        debugPrint('ViewCount incrementado para piada $jokeId');
      },
    );
  }

  /// Reseta todos os contadores de visualização
  Future<void> resetCounters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await resetViewCountersUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (_) {
        _isLoading = false;
        notifyListeners();
        // Recarrega próxima piada após reset
        loadNextJoke();
      },
    );
  }

  /// Limpa o erro atual
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reseta o estado do provider

  /// Dá like na piada atual
  Future<void> likeJoke() async {
    if (_currentJoke == null || hasVoted) return;

    final jokeId = _currentJoke!.id;
    final result = await likeJokeUseCase(LikeJokeParams(jokeId: jokeId));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        // Adiciona ao Set de votados e notifica listeners para ocultar botões
        _votedJokes.add(jokeId);
        notifyListeners();
      },
    );
  }

  /// Dá dislike na piada atual
  Future<void> dislikeJoke() async {
    if (_currentJoke == null || hasVoted) return;

    final jokeId = _currentJoke!.id;
    final result = await dislikeJokeUseCase(DislikeJokeParams(jokeId: jokeId));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        // Adiciona ao Set de votados e notifica listeners para ocultar botões
        _votedJokes.add(jokeId);
        notifyListeners();
      },
    );
  }

  void reset() {
    _currentJoke = null;
    _isLoading = false;
    _errorMessage = null;
    _answerRevealed = false;
    notifyListeners();
  }
}
