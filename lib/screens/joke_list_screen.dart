import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/jokes/presentation/providers/admin_provider.dart';
import '../features/jokes/domain/entities/joke.dart';
import 'edit_joke_screen.dart';

class JokeListScreen extends StatefulWidget {
  const JokeListScreen({super.key});

  @override
  State<JokeListScreen> createState() => _JokeListScreenState();
}

class _JokeListScreenState extends State<JokeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllJokes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Piadas'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar lista',
            onPressed: () {
              context.read<AdminProvider>().loadAllJokes();
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (adminProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar piadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      adminProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        adminProvider.loadAllJokes();
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
            );
          }

          final jokes = adminProvider.jokes;
          final activeJokes = adminProvider.activeJokes;
          final totalJokes = adminProvider.totalJokes;

          if (jokes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma piada encontrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header com estatísticas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.green.shade200, width: 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      icon: Icons.list,
                      label: 'Total',
                      value: totalJokes.toString(),
                      color: Colors.blue,
                    ),
                    _StatCard(
                      icon: Icons.check_circle,
                      label: 'Ativas',
                      value: activeJokes.toString(),
                      color: Colors.green,
                    ),
                    _StatCard(
                      icon: Icons.delete,
                      label: 'Deletadas',
                      value: (totalJokes - activeJokes).toString(),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),

              // Lista de piadas
              Expanded(
                child: ListView.builder(
                  itemCount: jokes.length,
                  itemBuilder: (context, index) {
                    final joke = jokes[index];
                    return _JokeListItem(
                      joke: joke,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditJokeScreen(joke: joke),
                          ),
                        );
                        if (result == true && mounted) {
                          adminProvider.loadAllJokes();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _JokeListItem extends StatelessWidget {
  final Joke joke;
  final VoidCallback onTap;

  const _JokeListItem({
    required this.joke,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: joke.deleted ? 1 : 2,
      color: joke.deleted ? Colors.grey.shade100 : Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: joke.deleted ? Colors.grey : Colors.green,
          child: Text(
            '#${joke.id}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          joke.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: joke.deleted ? Colors.grey.shade600 : Colors.black87,
            decoration: joke.deleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              joke.answer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: joke.deleted ? Colors.grey.shade500 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.visibility, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${joke.viewCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          joke.deleted ? Icons.delete_forever : Icons.edit,
          color: joke.deleted ? Colors.red.shade300 : Colors.blue,
        ),
      ),
    );
  }
}
