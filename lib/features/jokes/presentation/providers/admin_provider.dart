import 'package:flutter/foundation.dart';
import '../../domain/usecases/create_joke.dart';
import '../../domain/usecases/update_joke.dart';
import '../../domain/usecases/delete_joke.dart';

/// Provider para gerenciar funcionalidades administrativas
///
/// Usa Clean Architecture com use cases do domínio
class AdminProvider extends ChangeNotifier {
  final CreateJoke createJokeUseCase;
  final UpdateJoke updateJokeUseCase;
  final DeleteJoke deleteJokeUseCase;

  AdminProvider({
    required this.createJokeUseCase,
    required this.updateJokeUseCase,
    required this.deleteJokeUseCase,
  });

  // Estado
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Cria uma nova piada
  Future<bool> createJoke({
    required String question,
    required String answer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await createJokeUseCase(
      CreateJokeParams(question: question, answer: answer),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (joke) {
        _successMessage = 'Piada criada com sucesso!';
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Atualiza uma piada existente
  Future<bool> updateJoke({
    required int id,
    required String question,
    required String answer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await updateJokeUseCase(
      UpdateJokeParams(id: id, question: question, answer: answer),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (joke) {
        _successMessage = 'Piada atualizada com sucesso!';
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Deleta uma piada (soft delete)
  Future<bool> deleteJoke(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await deleteJokeUseCase(
      DeleteJokeParams(jokeId: id),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _successMessage = 'Piada deletada com sucesso!';
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Limpa mensagens de erro e sucesso
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Reseta o estado do provider
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
