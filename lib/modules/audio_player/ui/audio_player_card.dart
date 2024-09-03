import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thence_app/core/constants/app_colors.dart';
import 'package:thence_app/core/constants/app_dimensions.dart';
import 'package:thence_app/core/constants/app_strings.dart';
import 'package:thence_app/core/utils/waveform_utils.dart';
import 'package:thence_app/core/widgets/equilizer_painter.dart';
import '../bloc/audio_player_bloc.dart';

class AudioPlayerCard extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerCard({super.key, required this.audioUrl});

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    final audioPlayerBloc = context.read<AudioPlayerBloc>();

    // Initialize the audio player and load waveform
    audioPlayerBloc.add(AudioPlayerInitialized(audioPath: widget.audioUrl));
    audioPlayerBloc.add(AudioPlayerLoadWaveform(url: widget.audioUrl));

    // Listen to audio player's position and duration changes
    audioPlayerBloc.audioPlayer.onDurationChanged.listen(_onDurationChanged);
    audioPlayerBloc.audioPlayer.onPositionChanged.listen(_onPositionChanged);
    audioPlayerBloc.audioPlayer.onPlayerStateChanged
        .listen(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    context.read<AudioPlayerBloc>().audioPlayer.dispose();
    super.dispose();
  }

  void _onDurationChanged(Duration duration) {
    setState(() {
      _totalDuration = duration;
    });
  }

  void _onPositionChanged(Duration position) {
    setState(() {
      _currentPosition = position;
    });
  }

  void _onPlayerStateChanged(PlayerState playerState) {
    if (playerState == PlayerState.completed) {
      context
          .read<AudioPlayerBloc>()
          .add(AudioPlayerInitialized(audioPath: widget.audioUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final progress = _totalDuration.inMilliseconds > 0
            ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
            : 0.0;

        return Material(
          elevation: AppDimensions.cardElevation,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              _buildProgressBar(progress),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildContent(state),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(AudioPlayerState state) {
    if (state is AudioPlayerLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
    } else if (state is AudioPlayerError) {
      return _buildErrorText(state);
    } else {
      return Row(
        children: [
          _buildPlayPauseButton(state),
          const SizedBox(width: 16),
          _buildWaveform(),
        ],
      );
    }
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: AppDimensions.progressBarMinHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        color: AppColors.primaryColor.withOpacity(0.1),
      ),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppColors.progressBarBackground,
        valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.progressBarForeground.withOpacity(0.1)),
        minHeight: AppDimensions.progressBarMinHeight,
      ),
    );
  }

  Widget _buildPlayPauseButton(AudioPlayerState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: AppColors.primaryColor,
      ),
      child: IconButton(
        icon: Icon(
          state is AudioPlayerPlaying ? Icons.pause : Icons.play_arrow,
          size: AppDimensions.iconSize,
          color: Colors.white,
        ),
        onPressed: () {
          if (state is AudioPlayerPlaying) {
            context.read<AudioPlayerBloc>().add(AudioPlayerPause());
          } else {
            context.read<AudioPlayerBloc>().add(AudioPlayerPlay());
          }
        },
      ),
    );
  }

  Widget _buildWaveform() {
    final waveformAmplitudes =
        context.read<AudioPlayerBloc>().waveformAmplitudes ?? [];
    final reducedWaveform = reduceWaveformTo90Samples(waveformAmplitudes);

    return Expanded(
      child: EqualizerVisualizer(
        waveform: reducedWaveform,
        barColor: Colors.blueAccent,
        barWidthFactor: 2.0,
        barHeightFactor: 30.0,
        barSpacingFactor: 1.0,
      ),
    );
  }

  Widget _buildErrorText(AudioPlayerError state) {
    return Center(
      child: Text(
        '${AppStrings.errorPrefix}${state.error}',
        style: const TextStyle(color: AppColors.errorText, fontSize: 14),
      ),
    );
  }
}
