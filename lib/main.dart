import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection_container.dart' as di;
import 'features/jokes/presentation/providers/joke_provider.dart';
import 'features/jokes/presentation/providers/admin_provider.dart';
import 'screens/home_screen.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Credenciais devem estar em supabase_config.dart (não commitado)
    debugPrint('🔧 Inicializando Supabase...');

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

    // Inicializa injeção de dependências
    debugPrint('🔧 Inicializando Dependency Injection...');
    await di.initializeDependencies();
    debugPrint('✅ Dependency Injection inicializado!');
  } catch (e) {
    debugPrint('❌ Erro ao inicializar app: $e');
    // Continue mesmo com erro para mostrar mensagem ao usuário
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<JokeProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminProvider>()),
      ],
      child: MaterialApp(
        title: 'O que é o que é?',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
