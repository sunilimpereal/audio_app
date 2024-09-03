import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thence_app/core/constants/app_urls.dart';
import 'package:thence_app/modules/audio_player/ui/audio_player_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders AudioPlayerCard widget', (WidgetTester tester) async {
    // Arrange
    const testAudioUrl = AppUrls.audioUrl;

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AudioPlayerCard(audioUrl: testAudioUrl),
        ),
      ),
    );

    // Assert
    expect(find.byType(AudioPlayerCard), findsOneWidget);
  });
}
