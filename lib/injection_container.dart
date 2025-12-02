import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Data sources
import 'features/jokes/data/datasources/joke_local_datasource.dart';
import 'features/jokes/data/datasources/joke_local_datasource_impl.dart';
import 'features/jokes/data/datasources/joke_remote_datasource.dart';
import 'features/jokes/data/datasources/joke_remote_datasource_impl.dart';

// Repository
import 'features/jokes/data/repositories/joke_repository_impl.dart';
import 'features/jokes/domain/repositories/joke_repository.dart';

// Use cases
import 'features/jokes/domain/usecases/get_next_joke.dart';
import 'features/jokes/domain/usecases/increment_view_count.dart';
import 'features/jokes/domain/usecases/reset_view_counters.dart';
import 'features/jokes/domain/usecases/create_joke.dart';
import 'features/jokes/domain/usecases/update_joke.dart';
import 'features/jokes/domain/usecases/delete_joke.dart';
import 'features/jokes/domain/usecases/like_joke.dart';
import 'features/jokes/domain/usecases/dislike_joke.dart';

// Providers
import 'features/jokes/presentation/providers/joke_provider.dart';
import 'features/jokes/presentation/providers/admin_provider.dart';

final sl = GetIt.instance;

/// Inicializa todas as dependências do app
///
/// Deve ser chamado no main() antes de runApp()
Future<void> initializeDependencies() async {
  // ========== External ==========

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Supabase (já inicializado no main)
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ========== Data Sources ==========

  sl.registerLazySingleton<JokeLocalDataSource>(
    () => JokeLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<JokeRemoteDataSource>(
    () => JokeRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ========== Repository ==========

  sl.registerLazySingleton<JokeRepository>(
    () => JokeRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // ========== Use Cases ==========

  // User use cases
  sl.registerLazySingleton(() => GetNextJoke(sl()));
  sl.registerLazySingleton(() => IncrementViewCount(sl()));
  sl.registerLazySingleton(() => ResetViewCounters(sl()));
  sl.registerLazySingleton(() => LikeJoke(sl()));
  sl.registerLazySingleton(() => DislikeJoke(sl()));

  // Admin use cases
  sl.registerLazySingleton(() => CreateJoke(sl()));
  sl.registerLazySingleton(() => UpdateJoke(sl()));
  sl.registerLazySingleton(() => DeleteJoke(sl()));

  // ========== Providers ==========

  // JokeProvider - Factory (nova instância a cada chamada)
  sl.registerFactory(
    () => JokeProvider(
      getNextJokeUseCase: sl(),
      likeJokeUseCase: sl(),
      dislikeJokeUseCase: sl(),
      incrementViewCountUseCase: sl(),
      resetViewCountersUseCase: sl(),
    ),
  );

  // AdminProvider - Factory (nova instância a cada chamada)
  sl.registerFactory(
    () => AdminProvider(
      createJokeUseCase: sl(),
      updateJokeUseCase: sl(),
      deleteJokeUseCase: sl(),
    ),
  );
}

/// Reseta todas as dependências (útil para testes)
Future<void> resetDependencies() async {
  await sl.reset();
}
