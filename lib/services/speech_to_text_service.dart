import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class STTModel {
  String lastWords;
  bool speechEnabled;

  STTModel({
    this.lastWords = '',
    this.speechEnabled = false,
  });

  STTModel copyWith({
    String? lastWords,
    bool? speechEnabled,
  }) {
    return STTModel(
      lastWords: lastWords ?? this.lastWords,
      speechEnabled: speechEnabled ?? this.speechEnabled,
    );
  }
}

/// DO - can dispose off file and Mark NFA
/// Secretary - Can only forward
/// Create Daak - Default Flag PUC-1
///

class SpeechToTextService extends BaseControllerState<STTModel> {
  SpeechToText speechToText = SpeechToText();

  SpeechToTextService(super.state, super.ref);

  void initSpeech() async {
    state = state.copyWith(speechEnabled: await speechToText.initialize());
  }

  void startListening() async {
    await speechToText.listen(onResult: _onSpeechResult);
  }

  void stopListening() async {
    await speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    state = state.copyWith(lastWords: result.recognizedWords);
  }
}
