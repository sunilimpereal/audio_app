import 'package:flutter/material.dart';
import 'package:thence_app/core/constants/app_colors.dart';
import 'package:thence_app/core/constants/app_urls.dart';
import 'package:thence_app/modules/audio_player/ui/audio_player_card.dart';

class AudioPlayerScreen extends StatelessWidget {

  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gradientStart, 
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.gradientStart, 
              AppColors.gradientEnd, 
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: AudioPlayerCard(audioUrl: AppUrls.audioUrl),
            ),
          ),
        ),
      ),
    );
  }
}
