import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class STTModel {
  String lastWords;
  bool speechEnabled;
  bool isListening;

  STTModel({
    this.lastWords = '',
    this.speechEnabled = false,
    this.isListening = false,
  });

  STTModel copyWith({
    String? lastWords,
    bool? speechEnabled,
    bool? isListening,
  }) {
    return STTModel(
      lastWords: lastWords ?? this.lastWords,
      speechEnabled: speechEnabled ?? this.speechEnabled,
      isListening: isListening ?? this.isListening,
    );
  }
}

class SpeechToTextService extends BaseControllerState<STTModel> {
  SpeechToText speechToText = SpeechToText();
  void Function(String)? _onWordsRecognized;

  SpeechToTextService(super.state, super.ref);

  void initSpeech() async {
    state = state.copyWith(speechEnabled: await speechToText.initialize());
  }

  void startListening({
    void Function(String)? onWordsRecognized,
    void Function(String)? onError,
  }) async {
    _onWordsRecognized = onWordsRecognized;
    // Dispose previous instance and create a fresh one
    speechToText = SpeechToText();
    final enabled = await speechToText.initialize(
      debugLogging: true,
      onError: (error) {
        state = state.copyWith(isListening: false);
        onError?.call('Speech error: ${error.errorMsg}');
      },
    );
    if (!enabled) {
      state = state.copyWith(speechEnabled: false, isListening: false);
      onError?.call(
        'Speech recognition is not available on this device.\n'
        'On Android emulators, use a "Google Play" system image.',
      );
      return;
    }
    state =
        state.copyWith(speechEnabled: true, isListening: true, lastWords: '');
    await speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  void stopListening() async {
    _onWordsRecognized = null;
    if (speechToText.isListening) {
      await speechToText.stop();
    }
    state = state.copyWith(isListening: false);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    state = state.copyWith(lastWords: result.recognizedWords);
    _onWordsRecognized?.call(result.recognizedWords);
  }
}
