import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/joke.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

  Future<List<Joke>> fetchJokes() async {
    final response = await client
        .from('jokes')
        .select()
        .eq('deleted', false)
        .order('created_at', ascending: true);
    return (response as List).map((json) => Joke.fromJson(json)).toList();
  }

  Future<void> addJoke(Joke joke) async {
    await client.from('jokes').insert(joke.toJson());
  }

  Future<void> updateJoke(Joke joke) async {
    await client.from('jokes').update(joke.toJson()).eq('id', joke.id);
  }

  Future<void> deleteJoke(int id) async {
    await client.from('jokes').update({
      'deleted': true,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('id', id);
  }
}
