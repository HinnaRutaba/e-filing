import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordService {
  final AudioRecorder _recorder = AudioRecorder();

  String? _filePath; // full path to the recording (when using start -> file)
  bool _disposed = false;

  Future<bool> hasPermission() async {
    _ensureNotDisposed();
    return _recorder.hasPermission();
  }

  /// Start recording to a FILE on disk (NOT to stream).
  ///
  /// - [fileName] optional (without extension). If null, a timestamped name is used.
  /// - [encoder] defaults to AAC LC -> .m4a file.
  /// - [sampleRate], [bitRate], [numChannels] are tunables.
  ///
  /// Returns the full path of the output file.
  Future<String> startRecordingToFile({
    String? fileName,
    AudioEncoder encoder = AudioEncoder.aacLc,
    int sampleRate = 44100,
    int bitRate = 128000,
    int numChannels = 1,
  }) async {
    _ensureNotDisposed();

    if (!await hasPermission()) {
      throw Exception('Microphone permission not granted');
    }

    final dir = await getTemporaryDirectory();
    final ext = _extForEncoder(encoder); // e.g., m4a, opus, flac, wav
    final safeName = (fileName?.trim().isNotEmpty == true)
        ? fileName!.trim()
        : 'voice_${DateTime.now().millisecondsSinceEpoch}';
    final outPath = p.join(dir.path, '$safeName.$ext');

    final cfg = RecordConfig(
      encoder: encoder,
      sampleRate: sampleRate,
      bitRate: bitRate,
      numChannels: numChannels,
    );

    await _recorder.start(cfg, path: outPath);
    _filePath = outPath;
    return outPath;
  }

  /// Start recording to a STREAM of PCM frames (useful if you want to process audio bytes).
  /// Returns a Stream<Uint8List> of raw PCM frames.
  ///
  /// Note: When streaming, the encoder is typically PCM (e.g., pcm16bits).
  Future<Stream<Uint8List>> startRecordingToStream({
    int sampleRate = 44100,
    int numChannels = 1,
  }) async {
    _ensureNotDisposed();

    if (!await hasPermission()) {
      throw Exception('Microphone permission not granted');
    }

    final cfg = RecordConfig(
      // `pcm16bits` for raw PCM stream
      encoder: AudioEncoder.pcm16bits,
      sampleRate: sampleRate,
      numChannels: numChannels,
    );

    final stream = await _recorder.startStream(cfg);
    return stream;
  }

  /// Pause recording (file or stream).
  Future<void> pause() async {
    _ensureNotDisposed();
    if (await _recorder.isRecording()) {
      await _recorder.pause();
    }
  }

  /// Resume recording (file or stream).
  Future<void> resume() async {
    _ensureNotDisposed();
    if (await _recorder.isPaused()) {
      await _recorder.resume();
    }
  }

  /// Stop recording and return the recorded FILE (if recording to file).
  /// When recording to stream, this just stops and returns null.
  Future<File?> stop() async {
    _ensureNotDisposed();
    final path = await _recorder.stop();
    if (path == null) return null;
    _filePath = path;
    final file = File(path);
    return await file.exists() ? file : null;
  }

  /// Cancel current recording, discarding any file/blob.
  Future<void> cancel() async {
    _ensureNotDisposed();
    await _recorder.cancel();
    // Best-effort delete if we had a path
    if (_filePath != null) {
      final f = File(_filePath!);
      if (await f.exists()) {
        await f.delete();
      }
    }
    _filePath = null;
  }

  /// Whether the recorder is currently recording.
  Future<bool> isRecording() async {
    _ensureNotDisposed();
    return _recorder.isRecording();
  }

  /// Whether the recorder is currently paused.
  Future<bool> isPaused() async {
    _ensureNotDisposed();
    return _recorder.isPaused();
  }

  /// Full path of the last/active recording (file mode).
  String? get filePath => _filePath;

  /// Always call when done (e.g., in dispose()).
  Future<void> dispose() async {
    if (_disposed) return;
    await _recorder.dispose();
    _disposed = true;
  }

  // ---- helpers ----

  String _extForEncoder(AudioEncoder e) => switch (e) {
        AudioEncoder.aacLc => 'm4a',
        AudioEncoder.aacEld => 'm4a',
        AudioEncoder.aacHe => 'm4a',
        AudioEncoder.amrNb => 'amr',
        AudioEncoder.amrWb => 'amr',
        AudioEncoder.opus => 'opus',
        AudioEncoder.flac => 'flac',
        AudioEncoder.wav => 'wav',
        AudioEncoder.pcm16bits => 'wav',
      };

  void _ensureNotDisposed() {
    if (_disposed) {
      throw Exception('AudioRecordService is disposed');
    }
  }

  // Future<Duration> getAudioDuration(String filePath) async {
  //   final metadata = await FlutterMediaMetadataNew.getMetadata(filePath);
  //   final d = metadata.trackDuration ?? 0;
  //   return Duration(milliseconds: d);
  // }
}
