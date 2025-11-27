import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/joke_controller.dart';
import '../utils/device_utils.dart';
import 'create_joke_screen.dart';
import 'debug_screen.dart';
import 'edit_joke_screen.dart';

class HomeScreen extends StatefulWidget {
  final JokeController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isDeviceAllowed = false;
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

    widget.controller.addListener(_onJokeChanged);

    _checkDeviceAllowed();

    widget.controller.onAllJokesViewed = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você viu todas as piadas! Reiniciando...'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    };
  }

  Future<void> _checkDeviceAllowed() async {
    final allowed = await DeviceUtils.isDeviceAllowed();
    if (mounted) {
      setState(() {
        _isDeviceAllowed = allowed;
      });
    }
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

  void _onJokeChanged() {
    if (mounted) {
      setState(() {});
      if (!widget.controller.showAnswer) {
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onJokeChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joke = widget.controller.currentJoke;
    final showAnswer = widget.controller.showAnswer;
    final viewedJokes = widget.controller.viewedJokes;
    final totalJokes = widget.controller.totalJokes;

    return Scaffold(
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
              if (confirm == true) {
                widget.controller.resetCounters();
              }
            },
          ),
        ],
      ),
      body: joke == null
          ? const Center(child: CircularProgressIndicator())
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
                    // Indicador de progresso
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Vistas: ${viewedJokes + 1}/$totalJokes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (viewedJokes + 1) / totalJokes,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.5),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green),
                                minHeight: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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
                                    widget.controller.toggleAnswer();
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                joke.answer,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade700,
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
                          if (_isDeviceAllowed) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final result = await navigator.push<bool>(
                                      MaterialPageRoute(
                                        builder: (context) => CreateJokeScreen(
                                          controller: widget.controller,
                                        ),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Piada adicionada com sucesso!'),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Nova Piada'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final result = await navigator.push<bool>(
                                      MaterialPageRoute(
                                        builder: (context) => EditJokeScreen(
                                          joke: joke,
                                          controller: widget.controller,
                                        ),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Piada atualizada/deletada!'),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (!showAnswer)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    widget.controller.toggleAnswer(),
                                icon: const Icon(Icons.visibility),
                                label: const Text(
                                  'Ver Resposta',
                                  style: TextStyle(fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
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
                                onPressed: () => widget.controller.nextJoke(),
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text(
                                  'Próxima Piada',
                                  style: TextStyle(fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
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
  }
}
