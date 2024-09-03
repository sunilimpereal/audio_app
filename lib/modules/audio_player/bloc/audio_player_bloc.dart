import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:thence_app/core/utils/waveform_utils.dart';

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _localFilePath;
  List<double>? waveformAmplitudes;

  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    on<AudioPlayerInitialized>(_onInitialized);
    on<AudioPlayerPlay>(_onPlay);
    on<AudioPlayerPause>(_onPause);
    on<AudioPlayerStop>(_onStop);
    on<AudioPlayerLoadWaveform>(_onLoadWaveform);
  }

  void _onInitialized(
      AudioPlayerInitialized event, Emitter<AudioPlayerState> emit) async {
    emit(AudioPlayerLoading());
    try {
      _localFilePath = await _downloadAudio(event.audioPath);
      emit(AudioPlayerReady(audioPath: _localFilePath!));
    } catch (e, stackTrace) {
      log('Error initializing audio: $e', stackTrace: stackTrace);
      emit(AudioPlayerError(error: 'Failed to load audio'));
    }
  }

  void _onPlay(AudioPlayerPlay event, Emitter<AudioPlayerState> emit) async {
    if (_localFilePath != null) {
      try {
        if (_isPlaying) {
          await audioPlayer.pause();
          final position = (await audioPlayer.getCurrentPosition()) ?? Duration.zero;
          emit(AudioPlayerPaused(position: position));
        } else {
          await audioPlayer.play(DeviceFileSource(_localFilePath!));
          emit(AudioPlayerPlaying(position: Duration.zero));
        }
        _isPlaying = !_isPlaying;
      } catch (e, stackTrace) {
        log('Error playing audio: $e', stackTrace: stackTrace);
        emit(AudioPlayerError(error: 'Failed to play audio'));
      }
    } else {
      emit(AudioPlayerError(error: 'Audio file not available'));
    }
  }

  void _onPause(AudioPlayerPause event, Emitter<AudioPlayerState> emit) async {
    if (_isPlaying) {
      try {
        final currentPosition = await audioPlayer.getCurrentPosition();
        await audioPlayer.pause();
        emit(AudioPlayerPaused(position: currentPosition ?? Duration.zero));
        _isPlaying = false;
      } catch (e, stackTrace) {
        log('Error pausing audio: $e', stackTrace: stackTrace);
        emit(AudioPlayerError(error: 'Failed to pause audio'));
      }
    }
  }

  void _onStop(AudioPlayerStop event, Emitter<AudioPlayerState> emit) async {
    try {
      await audioPlayer.stop();
      _isPlaying = false;
      emit(AudioPlayerStopped());
    } catch (e, stackTrace) {
      log('Error stopping audio: $e', stackTrace: stackTrace);
      emit(AudioPlayerError(error: 'Failed to stop audio'));
    }
  }

  void _onLoadWaveform(
      AudioPlayerLoadWaveform event, Emitter<AudioPlayerState> emit) async {
    emit(AudioPlayerLoading());
    try {
      _localFilePath ??= await _downloadAudio(event.url);
      waveformAmplitudes = await extractWaveformAmplitudes(_localFilePath!);
      emit(AudioPlayerWaveformLoaded(waveformAmplitudes: waveformAmplitudes!));
    } catch (e, stackTrace) {
      log('Error loading waveform: $e', stackTrace: stackTrace);
      emit(AudioPlayerError(error: 'Failed to load waveform'));
    }
  }

  Future<String> _downloadAudio(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${url.split('/').last}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw HttpException('Failed to download audio: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      log('Error downloading audio: $e', stackTrace: stackTrace);
      throw Exception('Failed to download audio');
    }
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}
