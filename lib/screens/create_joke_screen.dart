import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/jokes/presentation/providers/admin_provider.dart';

class CreateJokeScreen extends StatefulWidget {
  const CreateJokeScreen({super.key});

  @override
  State<CreateJokeScreen> createState() => _CreateJokeScreenState();
}

class _CreateJokeScreenState extends State<CreateJokeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _createJoke() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.createJoke(
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Piada criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar piada: ${adminProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Piada'),
        backgroundColor: Colors.amber,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Crie uma nova piada "O que é o que é?"',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      labelText: 'Pergunta',
                      hintText: 'O que é o que é?\n...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.question_mark),
                    ),
                    maxLines: 5,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'A pergunta não pode estar vazia';
                      }
                      if (value.trim().length < 10) {
                        return 'A pergunta deve ter pelo menos 10 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      labelText: 'Resposta',
                      hintText: 'A resposta da piada...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lightbulb),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'A resposta não pode estar vazia';
                      }
                      if (value.trim().length < 2) {
                        return 'A resposta deve ter pelo menos 2 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _createJoke,
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Piada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
