import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thence_app/modules/audio_player/bloc/audio_player_bloc.dart';
import 'package:thence_app/modules/audio_player/ui/audio_player_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thence App Audio Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => AudioPlayerBloc(),
        child: const AudioPlayerScreen(),
      ),
    );
  }
}
