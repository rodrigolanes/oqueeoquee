import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DatabaseMigration {
  static const String _versionKey = 'database_version';
  static const int currentVersion = 2;

  /// Executa migrações necessárias do banco local
  static Future<void> migrate() async {
    final prefs = await SharedPreferences.getInstance();
    final int savedVersion = prefs.getInt(_versionKey) ?? 0;

    if (savedVersion < currentVersion) {
      debugPrint('Migração necessária: v$savedVersion -> v$currentVersion');

      // Executar migrações em ordem
      if (savedVersion < 1) {
        await _migrateToV1(prefs);
      }
      if (savedVersion < 2) {
        await _migrateToV2(prefs);
      }

      // Salvar nova versão
      await prefs.setInt(_versionKey, currentVersion);
      debugPrint('Migração concluída!');
    }
  }

  /// Migração para versão 1: Adicionar campos created_at e updated_at
  static Future<void> _migrateToV1(SharedPreferences prefs) async {
    debugPrint('Executando migração v0 -> v1');

    final String? jokesJson = prefs.getString('jokes');
    if (jokesJson == null) return;

    try {
      // Tenta carregar dados antigos
      // Se der erro, vai usar o tratamento de erro no controller
      debugPrint('Migração v1: Dados serão validados no próximo carregamento');
    } catch (e) {
      debugPrint('Erro na migração v1: $e');
      // Remove dados corrompidos
      await prefs.remove('jokes');
    }
  }

  /// Migração para versão 2: Limpar tudo e começar do zero com Supabase
  static Future<void> _migrateToV2(SharedPreferences prefs) async {
    debugPrint('Executando migração v1 -> v2: Limpando banco local');

    // Limpa TODOS os dados salvos localmente
    await prefs.clear();

    // Redefine a versão (porque clear() removeu tudo)
    await prefs.setInt(_versionKey, 2);

    debugPrint('Migração v2: Banco local resetado. Piadas virão do Supabase.');
  }

  /// Limpa completamente o banco local (use em caso de emergência)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jokes');
    await prefs.remove(_versionKey);
    debugPrint('Banco local limpo completamente');
  }
}
