import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/jokes/domain/entities/joke.dart';
import '../features/jokes/presentation/providers/admin_provider.dart';
import '../utils/device_utils.dart';

class EditJokeScreen extends StatefulWidget {
  final Joke joke;

  const EditJokeScreen({
    super.key,
    required this.joke,
  });

  @override
  State<EditJokeScreen> createState() => _EditJokeScreenState();
}

class _EditJokeScreenState extends State<EditJokeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  bool _isLoading = false;
  bool _isDeviceAllowed = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.joke.question);
    _answerController = TextEditingController(text: widget.joke.answer);
    _checkDevicePermission();
  }

  Future<void> _checkDevicePermission() async {
    final allowed = await DeviceUtils.isDeviceAllowed();
    if (mounted) {
      setState(() {
        _isDeviceAllowed = allowed;
      });

      if (!allowed) {
        _showUnauthorizedDialog();
      }
    }
  }

  void _showUnauthorizedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.red),
            SizedBox(width: 8),
            Text('Acesso Negado'),
          ],
        ),
        content: const Text(
          'Este dispositivo não tem permissão para editar piadas.\n\nApenas dispositivos autorizados podem acessar esta funcionalidade.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isDeviceAllowed) {
      _showUnauthorizedDialog();
      return;
    }

    setState(() => _isLoading = true);

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.updateJoke(
      id: widget.joke.id,
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Piada atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: ${adminProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteJoke() async {
    if (!_isDeviceAllowed) {
      _showUnauthorizedDialog();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja deletar esta piada?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    if (!mounted) return;

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.deleteJoke(widget.joke.id);

    if (!mounted) return;

    setState(() => _isLoading = false);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Piada deletada com sucesso!'),
          backgroundColor: Colors.orange,
        ),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar: ${adminProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Piada'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _deleteJoke,
            tooltip: 'Deletar piada',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'ID: ${widget.joke.id}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      labelText: 'Pergunta',
                      hintText: 'O que é o que é?\n...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.question_mark),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'A pergunta não pode estar vazia';
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'A resposta não pode estar vazia';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Alterações'),
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
