// ignore_for_file: library_private_types_in_public_api

library waved_audio_player;

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:efiling_balochistan/views/widgets/audio_player/audio_player_error.dart';
import 'package:efiling_balochistan/views/widgets/audio_player/wave_form_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Audio cache manager for caching remote audio files
class AudioCacheManager {
  static final AudioCacheManager _instance = AudioCacheManager._internal();
  factory AudioCacheManager() => _instance;
  AudioCacheManager._internal();

  static const String _cacheDir = 'audio_cache';
  Directory? _cacheDirectory;

  Future<Directory> get cacheDirectory async {
    if (_cacheDirectory != null) return _cacheDirectory!;

    final tempDir = await getTemporaryDirectory();
    _cacheDirectory = Directory('${tempDir.path}/$_cacheDir');

    if (!await _cacheDirectory!.exists()) {
      await _cacheDirectory!.create(recursive: true);
    }

    return _cacheDirectory!;
  }

  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _extensionForMimeType(String? mimeType) {
    switch (mimeType) {
      case 'audio/mpeg':
      case 'audio/mp3':
        return '.mp3';
      case 'audio/aac':
        return '.aac';
      case 'audio/ogg':
        return '.ogg';
      case 'audio/x-wav':
      case 'audio/wav':
        return '.wav';
      default:
        return '.wav';
    }
  }

  Future<File> _getCacheFile(String url, {String? mimeType}) async {
    final cacheDir = await cacheDirectory;
    final cacheKey = _generateCacheKey(url);
    final ext = _extensionForMimeType(mimeType);
    return File('${cacheDir.path}/$cacheKey$ext');
  }

  Future<String?> getCachedFilePath(String url, {String? mimeType}) async {
    try {
      final cacheFile = await _getCacheFile(url, mimeType: mimeType);
      if (await cacheFile.exists()) return cacheFile.path;
    } catch (e) {}
    return null;
  }

  Future<String?> cacheAudio(
      String url, Uint8List audioBytes, {String? mimeType}) async {
    try {
      final cacheFile = await _getCacheFile(url, mimeType: mimeType);
      await cacheFile.writeAsBytes(audioBytes);
      return cacheFile.path;
    } catch (e) {}
    return null;
  }

  Future<void> clearCache() async {
    try {
      final cacheDir = await cacheDirectory;
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      _cacheDirectory = null;
    } catch (e) {}
  }
}

/// Controller to manage multiple audio players and ensure only one plays at a time
class AudioPlayerController {
  static final AudioPlayerController _instance =
      AudioPlayerController._internal();
  factory AudioPlayerController() => _instance;
  AudioPlayerController._internal();

  final Set<_WavedAudioPlayerState> _audioPlayers = {};
  _WavedAudioPlayerState? _currentlyPlaying;

  /// Register an audio player with the controller
  void registerPlayer(_WavedAudioPlayerState player) {
    _audioPlayers.add(player);
  }

  /// Unregister an audio player from the controller
  void unregisterPlayer(_WavedAudioPlayerState player) {
    _audioPlayers.remove(player);
    if (_currentlyPlaying == player) {
      _currentlyPlaying = null;
    }
  }

  /// Stop all other players and start the specified one
  void playExclusive(_WavedAudioPlayerState player) {
    // Stop the currently playing audio if it's different from the new one
    if (_currentlyPlaying != null && _currentlyPlaying != player) {
      _currentlyPlaying!._pauseAudioInternal();
    }

    // Set the new player as currently playing
    _currentlyPlaying = player;
  }

  /// Notify when a player stops
  void onPlayerStopped(_WavedAudioPlayerState player) {
    if (_currentlyPlaying == player) {
      _currentlyPlaying = null;
    }
  }

  /// Stop all audio players
  void stopAll() {
    for (var player in _audioPlayers) {
      player._pauseAudioInternal();
    }
    _currentlyPlaying = null;
  }
}

class WavedAudioPlayer extends StatefulWidget {
  final Source source;
  final Color playedColor;
  final Color unplayedColor;
  final Color iconColor;
  final Color iconBackgoundColor;
  final double barWidth;
  final double spacing;
  final double waveHeight;
  final double buttonSize;
  final double waveWidth;
  final bool showTiming;
  final TextStyle? timingStyle;
  final void Function(WavedAudioPlayerError)? onError;
  final Map<String, String>? headers;
  const WavedAudioPlayer({
    super.key,
    required this.source,
    this.playedColor = Colors.blue,
    this.unplayedColor = Colors.grey,
    this.iconColor = Colors.blue,
    this.iconBackgoundColor = Colors.white,
    this.barWidth = 2,
    this.spacing = 4,
    this.waveWidth = 200,
    this.buttonSize = 40,
    this.showTiming = true,
    this.timingStyle,
    this.onError,
    this.waveHeight = 35,
    this.headers,
  });

  @override
  _WavedAudioPlayerState createState() => _WavedAudioPlayerState();
}

class _WavedAudioPlayerState extends State<WavedAudioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayerController _controller = AudioPlayerController();
  final AudioCacheManager _cacheManager = AudioCacheManager();
  List<double> waveformData = [];
  Duration audioDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  bool isPlaying = false;
  bool isPausing = true;
  bool hasCompleted = false;
  Uint8List? _audioBytes;
  String? _cachedFilePath;
  double _playbackSpeed = 1.0;

  Source get _playbackSource => _cachedFilePath != null
      ? DeviceFileSource(_cachedFilePath!, mimeType: widget.source.mimeType)
      : BytesSource(_audioBytes!, mimeType: widget.source.mimeType);

  static const List<double> _speeds = [1.0, 1.5, 2.0, 0.75];

  @override
  void initState() {
    super.initState();
    _controller.registerPlayer(this);
    _loadWaveform();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _controller.unregisterPlayer(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadWaveform() async {
    try {
      if (_audioBytes == null) {
        if (widget.source is AssetSource) {
          _audioBytes = await _loadAssetAudioWaveform(
            (widget.source as AssetSource).path,
          );
        } else if (widget.source is UrlSource) {
          final urlSrc = widget.source as UrlSource;
          final result = await _loadRemoteAudio(urlSrc.url, mimeType: urlSrc.mimeType);
          _audioBytes = result.$1;
          _cachedFilePath = result.$2;
        } else if (widget.source is DeviceFileSource) {
          _cachedFilePath = (widget.source as DeviceFileSource).path;
          _audioBytes = await _loadDeviceFileAudioWaveform(_cachedFilePath!);
        } else if (widget.source is BytesSource) {
          _audioBytes = (widget.source as BytesSource).bytes;
        }
        if (_audioBytes == null) return;
        waveformData = _extractWaveformData(_audioBytes!);
        setState(() {});
      }
      if (_cachedFilePath != null) {
        await _audioPlayer.setSource(DeviceFileSource(_cachedFilePath!,
            mimeType: widget.source.mimeType));
      } else if (_audioBytes != null) {
        await _audioPlayer.setSource(
            BytesSource(_audioBytes!, mimeType: widget.source.mimeType));
      }
    } catch (e) {
      _callOnError(WavedAudioPlayerError("Error loading audio: $e"));
    }
  }

  Future<Uint8List?> _loadDeviceFileAudioWaveform(String filePath) async {
    try {
      final File file = File(filePath);
      final Uint8List audioBytes = await file.readAsBytes();
      return audioBytes;
    } catch (e) {
      _callOnError(WavedAudioPlayerError("Error loading file audio: $e"));
    }
    return null;
  }

  Future<Uint8List?> _loadAssetAudioWaveform(String path) async {
    try {
      final ByteData bytes = await rootBundle.load(path);
      return bytes.buffer.asUint8List();
    } catch (e) {
      _callOnError(WavedAudioPlayerError("Error loading asset audio: $e"));
    }
    return null;
  }

  Future<(Uint8List?, String?)> _loadRemoteAudio(String url,
      {String? mimeType}) async {
    try {
      final cachedPath =
          await _cacheManager.getCachedFilePath(url, mimeType: mimeType);
      if (cachedPath != null) {
        final bytes = await File(cachedPath).readAsBytes();
        return (bytes, cachedPath);
      }
      final HttpClient httpClient = HttpClient();
      final HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      widget.headers?.forEach((key, value) => request.headers.set(key, value));
      final HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        final Uint8List audioBytes =
            await consolidateHttpClientResponseBytes(response);
        httpClient.close();
        final savedPath =
            await _cacheManager.cacheAudio(url, audioBytes, mimeType: mimeType);
        return (audioBytes, savedPath);
      } else {
        _callOnError(WavedAudioPlayerError(
            "Failed to load audio: ${response.statusCode}"));
        httpClient.close();
      }
    } catch (e) {
      _callOnError(WavedAudioPlayerError("Error loading audio: $e"));
    }
    return (null, null);
  }

  _callOnError(WavedAudioPlayerError error) {
    if (widget.onError == null) return;

    widget.onError!(error);
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
        // Notify controller when audio stops
        if (state == PlayerState.paused || state == PlayerState.stopped) {
          _controller.onPlayerStopped(this);
        }
      }
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        isPausing = false;
        hasCompleted = true;
        currentPosition = audioDuration; // Set to end position
      });
      _controller.onPlayerStopped(this);
      // Don't release - keep the source loaded for replay
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        audioDuration = duration;
        isPausing = true;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
        isPausing = true;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return "${twoDigits(hours)}:$minutes:$seconds"; // Format as HH:MM:SS
    } else {
      return "$minutes:$seconds"; // Format as MM:SS
    }
  }

  List<double> _extractWaveformData(Uint8List audioBytes) {
    List<double> waveData = [];
    final targetBars = widget.waveWidth.isInfinite
        ? 100.0
        : widget.waveWidth / (widget.barWidth + widget.spacing);
    int step = targetBars > 0
        ? (audioBytes.length / targetBars).floor()
        : 1;
    if (step <= 0) step = 1;
    for (int i = 0; i < audioBytes.length; i += step) {
      waveData.add(audioBytes[i] / 255);
    }
    waveData.add(audioBytes[audioBytes.length - 1] / 255);
    return waveData;
  }

  void _onWaveformTap(double tapX, double width) {
    double tapPercent = tapX / width;
    Duration newPosition = audioDuration * tapPercent;
    _audioPlayer.seek(newPosition);
  }

  void _playAudio() async {
    if (_audioBytes == null) return;

    // Use controller to stop other players and play this one
    _controller.playExclusive(this);

    // If audio has completed, restart from beginning
    if (hasCompleted) {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(_playbackSource);
      setState(() {
        hasCompleted = false;
        currentPosition = Duration.zero;
      });
      await _audioPlayer.resume();
    } else {
      // Normal play/resume logic
      isPausing
          ? _audioPlayer.resume()
          : _audioPlayer.play(_playbackSource);
    }
  }

  /// Internal pause method called by controller (doesn't update state)
  void _pauseAudioInternal() async {
    _audioPlayer.pause();
    isPausing = true;
    if (mounted) {
      setState(() {
        isPlaying = false;
      });
    }
  }

  void _pauseAudio() async {
    _pauseAudioInternal();
    _controller.onPlayerStopped(this);
  }

  void _cycleSpeed() {
    final nextIndex =
        (_speeds.indexOf(_playbackSpeed) + 1) % _speeds.length;
    setState(() => _playbackSpeed = _speeds[nextIndex]);
    _audioPlayer.setPlaybackRate(_playbackSpeed);
  }

  String get _speedLabel {
    if (_playbackSpeed == _playbackSpeed.truncateToDouble()) {
      return '${_playbackSpeed.toInt()}x';
    }
    return '${_playbackSpeed}x';
  }

  Widget _waveformWidget(double resolvedWaveWidth) {
    final painter = WaveformPainter(
      waveformData,
      currentPosition.inMilliseconds /
          (audioDuration.inMilliseconds == 0
              ? 1
              : audioDuration.inMilliseconds),
      playedColor: widget.playedColor,
      unplayedColor: widget.unplayedColor,
      barWidth: widget.barWidth,
    );
    final canvas = GestureDetector(
      onTapDown: (details) =>
          _onWaveformTap(details.localPosition.dx, resolvedWaveWidth),
      child: CustomPaint(
        size: Size(resolvedWaveWidth, widget.waveHeight),
        painter: painter,
      ),
    );
    return widget.waveWidth.isInfinite ? Expanded(child: canvas) : canvas;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWaveWidth = widget.waveWidth.isInfinite
            ? constraints.maxWidth.isInfinite
                ? 200.0
                : constraints.maxWidth
            : widget.waveWidth;
        return (waveformData.isNotEmpty)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      isPlaying ? _pauseAudio() : _playAudio();
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: widget.iconColor,
                      size: 4 * widget.buttonSize / 5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _waveformWidget(resolvedWaveWidth),
                  if (widget.showTiming) const SizedBox(width: 10),
                  if (widget.showTiming)
                    Center(
                      child: Text(
                        _formatDuration(currentPosition),
                        style: widget.timingStyle,
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _cycleSpeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.iconBackgoundColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.playedColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        _speedLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.playedColor,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: resolvedWaveWidth + widget.buttonSize,
                height: max(widget.waveHeight, widget.buttonSize),
                child: Center(
                  child: LinearProgressIndicator(
                    color: widget.playedColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              );
      },
    );
  }
}
