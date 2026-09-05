import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/remote/movie_remote_datasource.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'domain/repositories/movie_repository.dart';
import 'presentation/blocs/home/home_bloc.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(const HzFilmesApp());
}

class HzFilmesApp extends StatelessWidget {
  const HzFilmesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Injeção de dependências manual (simples e clara)
    final dioClient = DioClient();
    final remoteDataSource = MovieRemoteDataSourceImpl(dioClient);
    final MovieRepository movieRepository = MovieRepositoryImpl(remoteDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(movieRepository)..add(LoadHomeData()),
        ),
      ],
      child: MaterialApp(
        title: 'HZ Filmes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomePage(),
      ),
    );
  }
}