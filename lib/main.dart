import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hz_filmes/data/datasources/local/activity_local_datasource.dart';
import 'package:hz_filmes/domain/repositories/services/recommendation_service.dart';
import 'package:hz_filmes/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:flutter/services.dart';

import 'presentation/pages/splash_page.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/remote/movie_remote_datasource.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'domain/repositories/movie_repository.dart';
import 'presentation/blocs/home/home_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  runApp(const HzFilmesApp());
}

class HzFilmesApp extends StatelessWidget {
  const HzFilmesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dioClient = DioClient();
    final remoteDataSource = MovieRemoteDataSourceImpl(dioClient);
    final MovieRepository movieRepository = MovieRepositoryImpl(
      remoteDataSource,
    );
    final activityDataSource = ActivityLocalDataSource();
    final recommendationService = RecommendationService(
      movieRepository: movieRepository,
      activityDataSource: activityDataSource,
    );

    return RepositoryProvider<MovieRepository>.value(
      value: movieRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc(
              movieRepository,
              recommendationService,
            )..add(LoadHomeData()),
          ),
          BlocProvider(
            create: (context) => FavoritesBloc()..add(LoadFavorites()),
          ),
          
        ],
        child: MaterialApp(
          title: 'HzFilmes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const SplashPage(),
        ),
      ),
    );
  }
}
