import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Supported spoken languages for VoiceBill.
/// Keys are display names shown in the dropdown, values are locale IDs
/// speech_to_text expects.
class VoiceLocale {
  static const Map<String, String> options = {
    'English (India)': 'en_IN',
    'Hindi': 'hi_IN',
    'Bengali': 'bn_IN',
  };
}

/// Wraps the speech_to_text plugin: handles mic permission, init,
/// starting/stopping listening, and streaming partial/final results.
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;

  /// Requests mic permission and initializes the recognizer.
  /// Returns true if ready to listen.
  Future<bool> init() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return false;

    _isInitialized = await _speech.initialize(
      onError: (error) => print('SpeechService error: $error'),
      onStatus: (status) => print('SpeechService status: $status'),
    );
    return _isInitialized;
  }

  /// Starts listening in [localeId] (e.g. "hi_IN"). Calls [onResult] with
  /// the live transcript each time it updates, and [final] indicates
  /// whether recognition is done for this utterance.
  Future<void> listen({
    required String localeId,
    required void Function(String transcript, bool isFinal) onResult,
  }) async {
    if (!_isInitialized) {
      final ok = await init();
      if (!ok) return;
    }

    await _speech.listen(
      localeId: localeId,
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  Future<void> cancel() async {
    await _speech.cancel();
  }
}
