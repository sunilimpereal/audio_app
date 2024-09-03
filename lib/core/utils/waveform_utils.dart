import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

/// Reduces the number of samples in a waveform to a fixed target of 90 samples.
/// If the waveform has fewer than or equal to 90 elements, it interpolates values.
/// Otherwise, it averages groups of values to reduce the size.
List<double> reduceWaveformTo90Samples(List<double> waveform) {
  const int targetSamples = 90;
  
  // Handle empty waveform input
  if (waveform.isEmpty) {
    return [];
  }

  List<double> reducedWaveform = [];

  if (waveform.length <= targetSamples) {
    // Interpolation for waveforms with fewer samples than the target
    double scale = (waveform.length - 1) / (targetSamples - 1);
    for (int i = 0; i < targetSamples; i++) {
      double index = i * scale;
      int lowerIndex = index.floor();
      int upperIndex = index.ceil();
      double fraction = index - lowerIndex;
      double value = waveform[lowerIndex] * (1 - fraction) +
          waveform[upperIndex] * fraction;
      reducedWaveform.add(value);
    }
  } else {
    // Averaging for waveforms with more samples than the target
    double binSize = waveform.length / targetSamples;
    for (int i = 0; i < targetSamples; i++) {
      int start = (i * binSize).floor();
      int end = ((i + 1) * binSize).ceil();
      double sum = 0;
      for (int j = start; j < end; j++) {
        sum += waveform[j];
      }
      reducedWaveform.add(sum / (end - start));
    }
  }

  return reducedWaveform;
}

/// Extracts waveform amplitudes from an audio file using FFmpeg.
/// This function extracts PCM data from the audio file and processes it to 
/// obtain a list of normalized amplitude values.
Future<List<double>> extractWaveformAmplitudes(String filePath) async {
  final tempDir = await getTemporaryDirectory();
  final pcmFilePath = '${tempDir.path}/audio.pcm';

  // FFmpeg command to extract PCM data from the audio file
  final command = '-i $filePath -ac 1 -f s16le -ar 44100 -y $pcmFilePath';
  final session = await FFmpegKit.execute(command);
  final returnCode = await session.getReturnCode();

  // Check if the FFmpeg command was successful
  if (returnCode!.isValueSuccess()) {
    final pcmFile = File(pcmFilePath);

    // Process the PCM data to extract waveform amplitudes
    return _processPcmData(pcmFile);
  } else {
    // Handle extraction failure
    throw Exception('Failed to extract waveform data');
  }
}

/// Processes the raw PCM data to extract amplitude values.
/// Converts the byte data into 16-bit signed integers and normalizes the 
/// amplitude to a range between -1 and 1.
List<double> _processPcmData(File pcmFile) {
  final bytes = pcmFile.readAsBytesSync();
  final amplitudes = <double>[];

  for (int i = 0; i < bytes.length; i += 2) {
    // Combine two bytes into a 16-bit signed integer
    int sample = bytes[i] | (bytes[i + 1] << 8);
    if (sample >= 32768) sample -= 65536;

    // Normalize the sample to a range of -1 to 1
    amplitudes.add(sample / 32768.0);
  }

  return amplitudes;
}
