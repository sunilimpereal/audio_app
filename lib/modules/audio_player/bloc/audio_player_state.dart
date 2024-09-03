part of 'audio_player_bloc.dart';

@immutable
abstract class AudioPlayerState {}

// Initial state before any action is taken
class AudioPlayerInitial extends AudioPlayerState {}

// State when the audio is loading/preparing to play
class AudioPlayerLoading extends AudioPlayerState {}

// State when the audio is ready to play
class AudioPlayerReady extends AudioPlayerState {
  final String audioPath;

  AudioPlayerReady({required this.audioPath});
}

// State when the audio is playing
class AudioPlayerPlaying extends AudioPlayerState {
  final Duration position;

  AudioPlayerPlaying({required this.position});
}

// State when the audio is paused
class AudioPlayerPaused extends AudioPlayerState {
  final Duration position;

  AudioPlayerPaused({required this.position});
}

// State when the audio is stopped
class AudioPlayerStopped extends AudioPlayerState {}

class AudioPlayerWaveformLoaded extends AudioPlayerState {
  final List<double>? waveformAmplitudes;
  AudioPlayerWaveformLoaded({required this.waveformAmplitudes});
}

// State when the audio is seeking to a different position
class AudioPlayerSeeking extends AudioPlayerState {
  final Duration position;

  AudioPlayerSeeking({required this.position});
}

// State when an error occurs
class AudioPlayerError extends AudioPlayerState {
  final String error;

  AudioPlayerError({required this.error});
}
