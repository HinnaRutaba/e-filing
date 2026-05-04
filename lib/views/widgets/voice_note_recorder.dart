import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/services/record_audio_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

enum _RecorderState { idle, recording, recorded }

class VoiceNoteRecorder extends StatefulWidget {
  final void Function(String filePath, int durationSec) onVoiceNoteReady;
  final VoidCallback onVoiceNoteCleared;

  const VoiceNoteRecorder({
    super.key,
    required this.onVoiceNoteReady,
    required this.onVoiceNoteCleared,
  });

  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder> {
  _RecorderState _state = _RecorderState.idle;

  final AudioRecordService _recordService = AudioRecordService();
  final RecorderController _recorderController = RecorderController();
  final ap.AudioPlayer _player = ap.AudioPlayer();

  int _elapsedSeconds = 0;
  Timer? _timer;

  String? _recordedPath;
  int _recordedDurationSec = 0;
  bool _isPlaying = false;
  int _playedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == ap.PlayerState.playing);
    });
    _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() => _playedSeconds = pos.inSeconds);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _playedSeconds = 0;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorderController.dispose();
    _recordService.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      await _recordService.startRecordingToFile(encoder: AudioEncoder.wav);
      _recorderController.record();
      _elapsedSeconds = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsedSeconds++);
      });
      setState(() => _state = _RecorderState.recording);
    } catch (_) {}
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    await _recorderController.stop();
    final file = await _recordService.stop();
    if (!mounted) return;
    if (file != null) {
      _recordedPath = file.path;
      _recordedDurationSec = _elapsedSeconds;
      widget.onVoiceNoteReady(file.path, _elapsedSeconds);
      setState(() => _state = _RecorderState.recorded);
    } else {
      setState(() => _state = _RecorderState.idle);
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    await _recorderController.stop();
    await _recordService.cancel();
    if (!mounted) return;
    setState(() {
      _state = _RecorderState.idle;
      _elapsedSeconds = 0;
    });
  }

  Future<void> _discardRecording() async {
    await _player.stop();
    if (_recordedPath != null) {
      final f = File(_recordedPath!);
      if (await f.exists()) await f.delete();
    }
    _recordedPath = null;
    _recordedDurationSec = 0;
    _playedSeconds = 0;
    widget.onVoiceNoteCleared();
    if (!mounted) return;
    setState(() => _state = _RecorderState.idle);
  }

  Future<void> _togglePlay() async {
    if (_recordedPath == null) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(ap.DeviceFileSource(_recordedPath!));
    }
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: switch (_state) {
        _RecorderState.idle => _buildIdle(),
        _RecorderState.recording => _buildRecording(),
        _RecorderState.recorded => _buildRecorded(),
      },
    );
  }

  Widget _buildIdle() {
    return GestureDetector(
      key: const ValueKey('idle'),
      onTap: _startRecording,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryDark.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.secondaryLight.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_none_rounded,
                size: 20,
                color: AppColors.secondaryLight,
              ),
            ),
            const SizedBox(width: 12),
            AppText.bodySmall(
              'Tap to record a voice note (optional)',
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecording() {
    return Container(
      key: const ValueKey('recording'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AudioWaveforms(
              size: const Size(double.infinity, 40),
              recorderController: _recorderController,
              enableGesture: false,
              waveStyle: const WaveStyle(
                waveColor: Colors.red,
                extendWaveform: true,
                showMiddleLine: false,
              ),
            ),
          ),
          const SizedBox(width: 10),
          AppText.bodySmall(
            _fmt(_elapsedSeconds),
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stop_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorded() {
    final progress = _recordedDurationSec > 0
        ? (_playedSeconds / _recordedDurationSec).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      key: const ValueKey('recorded'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.secondaryLight.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondaryLight,
                    ),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                AppText.bodySmall(
                  '${_fmt(_playedSeconds)} / ${_fmt(_recordedDurationSec)}',
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.mic_rounded,
            size: 15,
            color: AppColors.secondaryLight,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _discardRecording,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
