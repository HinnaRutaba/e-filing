enum VoiceNoteVisibility {
  cm('cm'),
  internal('internal');

  final String value;
  const VoiceNoteVisibility(this.value);
}

enum VoiceNoteContext {
  forwardToCM('forward_to_cm'),
  shareInternal('share_internal');

  final String value;
  const VoiceNoteContext(this.value);
}

class VoiceNoteUploadModel {
  final List<int> audioBytes;
  final String audioFilename;
  final VoiceNoteVisibility visibility;
  final int durationSec;
  final VoiceNoteContext? context;

  const VoiceNoteUploadModel({
    required this.audioBytes,
    required this.audioFilename,
    required this.visibility,
    required this.durationSec,
    this.context,
  });

  Map<String, dynamic> toJson(int userDesgId) => {
    'userDesgID': userDesgId,
    'visibility': visibility.value,
    'duration_sec': durationSec,
    if (context != null) 'context': context!.value,
  };
}
