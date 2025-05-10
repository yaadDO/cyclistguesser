import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/cyclist_guess/rider_bloc.dart';
import '../../bloc/cyclist_guess/rider_state.dart';
import '../../data/models/rider.dart';
import '../../data/repositories/country_code_map.dart';
import 'package:http/http.dart' as http;

class GuessCyclistScreen extends StatelessWidget {
  const GuessCyclistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess the Pro Cyclist'),
        actions: [
          BlocBuilder<RiderBloc, RiderState>(
            builder: (context, state) {
              // Get score from any state
              final score = state.score;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$score', style: const TextStyle(fontSize: 18)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<RiderBloc, RiderState>(
        builder: (context, state) {
          return FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: state is RiderLoading
                ? null
                : () => context.read<RiderBloc>().add(FetchRiderEvent()),
            child: state is RiderLoading
                ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
                : const Icon(Icons.refresh),
          );
        },
      ),
      body: BlocConsumer<RiderBloc, RiderState>(
        listener: (context, state) {
          if (state is RiderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is RiderInitial) {
            context.read<RiderBloc>().add(FetchRiderEvent());
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RiderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RiderLoaded || state is GuessChecked) {
            final rider = state is RiderLoaded
                ? (state).rider
                : (state as GuessChecked).rider;
            final isChecked = state is GuessChecked;

            return Column(
              children: [
                Expanded(
                  child: _CluesView(
                    rider: rider,
                    isChecked: isChecked,
                    isCorrect: isChecked ? (state).isCorrect : null,
                  ),
                ),
                if (isChecked) _buildResultBanner(state.isCorrect),
              ],
            );
          }
          if (state is RiderError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildResultBanner(bool isCorrect) {
    return Container(
      color: isCorrect ? Colors.green : Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
            isCorrect ? 'Correct! 🎉' : 'Try Again! ❌',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}

class _CluesView extends StatefulWidget {
  final Rider rider;
  final bool isChecked;
  final bool? isCorrect;

  const _CluesView({
    required this.rider,
    this.isChecked = false,
    this.isCorrect,
  });

  @override
  __CluesViewState createState() => __CluesViewState();
}

class __CluesViewState extends State<_CluesView> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  Timer? _debounceTimer;
  FocusNode _searchFocusNode = FocusNode();
  Timer? _autoRefreshTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _autoRefreshTimer?.cancel();
    _controller.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _cancelTimersAndClear() {
    _debounceTimer?.cancel();
    _autoRefreshTimer?.cancel();
    _controller.clear();
    setState(() => _suggestions = []);
  }

  @override
  void didUpdateWidget(covariant _CluesView oldWidget) {
    if (oldWidget.rider != widget.rider) {
      _cancelTimersAndClear();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'http://192.168.18.2:5000/search-riders?query=$query'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() => _suggestions = data);
      }
    } catch (e) {
      setState(() => _suggestions = []);
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(query);
    });
  }

  void _submitGuess() {
    final guess = _controller.text.trim();
    if (guess.isEmpty) return;

    context.read<RiderBloc>().add(SubmitGuessEvent(guess));
    _cancelTimersAndClear();
    _searchFocusNode.unfocus();

    _autoRefreshTimer = Timer(const Duration(seconds: 5), () {
      context.read<RiderBloc>().add(FetchRiderEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClueTile('Nationality',
              getFullCountryName(widget.rider.nationality)),
          _buildClueTile('Team', widget.rider.team),
          _buildClueTile('Age', widget.rider.age.toString()),
          _buildClueTile('Weight Range',
              '${_getWeightRange(widget.rider.weight)} kg'),

          if (widget.isChecked) ...[
            const SizedBox(height: 20),
            Text(
              'Correct Answer: ${widget.rider.name}',
              style: TextStyle(
                fontSize: 18,
                color: widget.isCorrect! ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 2,
            ),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 20),
          _buildSearchField(),
          _buildSuggestionsList(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check, size: 24),
        label: const Text('SUBMIT GUESS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: widget.isChecked || _controller.text.isEmpty
              ? Colors.grey[400]
              : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: widget.isChecked ? null : _submitGuess,
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter Cyclist Name:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _searchFocusNode,
          enabled: !widget.isChecked,
          decoration: InputDecoration(
            hintText: 'Start typing...',
            border: const OutlineInputBorder(),
            suffixIcon: _controller.text.isNotEmpty && !widget.isChecked
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _cancelTimersAndClear,
            )
                : null,
          ),
          onChanged: widget.isChecked ? null : _onSearchChanged,
          onSubmitted: widget.isChecked ? null : (_) => _submitGuess(),
        ),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final rider = _suggestions[index];
          return ListTile(
            title: Text(rider['name']),
            dense: true,
            onTap: () {
              _controller.text = rider['name'];
              _submitGuess();
            },
          );
        },
      ),
    );
  }

  Widget _buildClueTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$title: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          Text(value,
              style: TextStyle(
                  color: widget.isChecked
                      ? (widget.isCorrect!
                      ? Colors.green
                      : Colors.red)
                      : Colors.blueGrey)),
        ],
      ),
    );
  }

  String _getWeightRange(double weight) {
    int lower = (weight ~/ 5) * 5;
    return '$lower-${lower + 5}';
  }
}