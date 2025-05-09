import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/cyclist_guess/cyclist_guess_bloc.dart';
import '../../data/models/cyclist.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guess the Cyclist')),
      body: BlocConsumer<CyclistGuessBloc, CyclistGuessState>(
        listener: (context, state) {
          if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Loaded) {
            return _GameContent(cyclist: state.cyclist);
          }
          if (state is GuessCorrect) {
            // Show success UI and reload new cyclist
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<CyclistGuessBloc>().add(LoadRandomCyclist());
            });
            return const Center(child: Text('Correct!'));
          }
          return const Center(child: Text('Start guessing!'));
        },
      ),
    );
  }
}

class _GameContent extends StatelessWidget {
  final Cyclist cyclist;

  const _GameContent({required this.cyclist});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildClueItem(Icons.work, 'Role: ${cyclist.role}'),
          _buildClueItem(Icons.cake, 'Age: ${cyclist.age}'),
          _buildClueItem(Icons.groups, 'Team: ${cyclist.team}'),
          _buildClueItem(Icons.flag, 'Nationality: ${cyclist.nationality}'),
          _buildClueItem(Icons.monitor_weight, 'Weight: ${cyclist.weight}kg'),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Enter cyclist name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              context.read<CyclistGuessBloc>().add(SubmitGuess(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClueItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
    );
  }
}