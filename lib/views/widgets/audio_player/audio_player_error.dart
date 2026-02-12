class WavedAudioPlayerError extends Error {
  final String message;

  WavedAudioPlayerError(this.message);

  @override
  String toString() => "WavedAudioPlayerError: $message";
}
