import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/joke_controller.dart';
import 'screens/home_screen.dart';
import 'services/supabase_service.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Credenciais devem estar em supabase_config.dart (não commitado)
    debugPrint('🔧 Inicializando Supabase...');
    debugPrint('URL: ${SupabaseConfig.url}');
    debugPrint('Key: ${SupabaseConfig.anonKey.substring(0, 10)}...');

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('❌ Timeout ao inicializar Supabase');
        throw Exception('Timeout na inicialização do Supabase');
      },
    );

    debugPrint('✅ Supabase inicializado com sucesso!');
  } catch (e) {
    debugPrint('❌ Erro ao inicializar Supabase: $e');
    // Continue mesmo com erro para mostrar mensagem ao usuário
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O que é o que é?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: HomeScreen(
        controller: JokeController(
          supabaseService: SupabaseService(Supabase.instance.client),
        ),
      ),
    );
  }
}
