part of 'audio_player_bloc.dart';

@immutable
abstract class AudioPlayerEvent {}

// Event to initialize the audio player with a specific audio file
class AudioPlayerInitialized extends AudioPlayerEvent {
  final String audioPath;

  AudioPlayerInitialized({required this.audioPath});
}

// Event to play the audio
class AudioPlayerPlay extends AudioPlayerEvent {}

// Event to pause the audio
class AudioPlayerPause extends AudioPlayerEvent {}

// Event to stop the audio
class AudioPlayerStop extends AudioPlayerEvent {}

class AudioPlayerLoadWaveform extends AudioPlayerEvent {
  final String url;

  AudioPlayerLoadWaveform({required this.url});
}


// Event to handle audio player errors
class AudioPlayerErrorOccurred extends AudioPlayerEvent {
  final String error;

  AudioPlayerErrorOccurred({required this.error});
}
