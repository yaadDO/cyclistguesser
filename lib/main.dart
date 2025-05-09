// lib/main.dart
import 'package:cyclistguesser/presentation/screens/game_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/cyclist_guess/cyclist_guess_bloc.dart';
import 'data/repositories/cyclist_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyclist Guesser',
      home: RepositoryProvider(
        create: (context) => CyclistRepository(client: http.Client(), firestore: null),
        child: BlocProvider(
          create: (context) => CyclistGuessBloc(
            repository: RepositoryProvider.of<CyclistRepository>(context),
          )..add(LoadRandomCyclist()),
          child: const GameScreen(),
        ),
      ),
    );
  }
}