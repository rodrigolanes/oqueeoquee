import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../features/jokes/presentation/providers/joke_provider.dart';
import 'debug_screen.dart';
import 'create_joke_screen.dart';
import 'edit_joke_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _titleTapCount = 0;
  DateTime? _lastTitleTap;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // Carrega primeira piada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JokeProvider>().loadNextJoke();
    });
  }

  void _onTitleTap() {
    final now = DateTime.now();

    // Reseta contador se passou mais de 2 segundos desde o último toque
    if (_lastTitleTap != null && now.difference(_lastTitleTap!).inSeconds > 2) {
      _titleTapCount = 0;
    }

    _lastTitleTap = now;
    _titleTapCount++;

    if (_titleTapCount >= 3) {
      _titleTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DebugScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JokeProvider>(
      builder: (context, jokeProvider, _) {
        final joke = jokeProvider.currentJoke;
        final showAnswer = jokeProvider.answerRevealed;
        final isLoading = jokeProvider.isLoading;
        final errorMessage = jokeProvider.errorMessage;

        // Anima quando nova piada carrega
        if (joke != null && !showAnswer) {
          _animationController.forward(from: 0.0);
        }

        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.amber, Colors.amber.shade300],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        '🤔',
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'O que é o que é?',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle, color: Colors.green),
                  title: const Text('Criar Nova Piada'),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateJokeScreen(),
                      ),
                    );
                    if (result == true && mounted) {
                      jokeProvider.loadNextJoke();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Editar Piada Atual'),
                  enabled: joke != null,
                  onTap: joke == null
                      ? null
                      : () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditJokeScreen(joke: joke),
                            ),
                          );
                          if (result == true && mounted) {
                            jokeProvider.loadNextJoke();
                          }
                        },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.orange),
                  title: const Text('Debug'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DebugScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            title: GestureDetector(
              onTap: _onTitleTap,
              child: const Text('O que é o que é? 🤔'),
            ),
            centerTitle: true,
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black87,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Resetar contadores',
                onPressed: () async {
                  final jokeProvider = context.read<JokeProvider>();

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Resetar contadores'),
                      content: const Text(
                          'Deseja resetar todos os contadores e começar novamente?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Resetar'),
                        ),
                      ],
                    ),
                  );

                  if (!mounted) return;

                  if (confirm == true) {
                    jokeProvider.resetCounters();
                  }
                },
              ),
            ],
          ),
          body: joke == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      // Mostra erro se houver
                      if (errorMessage != null && !isLoading) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Card(
                            color: Colors.orange.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(Icons.cloud_off,
                                      size: 48, color: Colors.orange.shade700),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Não foi possível carregar as piadas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    errorMessage,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      jokeProvider.loadNextJoke();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Tentar Novamente'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.amber,
                        Colors.amber.shade100,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Card da piada
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      if (!showAnswer) {
                                        jokeProvider.revealAnswer();
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '😄',
                                            style: TextStyle(fontSize: 48),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            joke.question,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                          if (showAnswer) ...[
                                            const SizedBox(height: 32),
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.green.shade200,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    'Resposta:',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    joke.answer,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Botões de ação
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              if (!showAnswer)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        jokeProvider.revealAnswer(),
                                    icon: const Icon(Icons.visibility),
                                    label: const Text(
                                      'Ver Resposta',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        jokeProvider.loadNextJoke(),
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text(
                                      'Próxima Piada',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
