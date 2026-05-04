import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/summaries/summary_voice_note_model.dart';
import 'package:efiling_balochistan/models/summaries/voice_note_upload_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceNotesSection extends ConsumerStatefulWidget {
  final int? summaryId;
  final VoiceNoteVisibility visibility;

  const VoiceNotesSection({super.key, required this.summaryId, required this.visibility});

  @override
  ConsumerState<VoiceNotesSection> createState() => _VoiceNotesSectionState();
}

class _VoiceNotesSectionState extends ConsumerState<VoiceNotesSection> {
  bool _expanded = false;
  bool _loading = false;
  List<SummaryVoiceNoteModel> _voiceNotes = const [];

  final ap.AudioPlayer _player = ap.AudioPlayer();
  int? _playingId;
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
        _playingId = null;
      });
    });
    _fetch();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final notes = await ref
        .read(summariesController.notifier)
        .listVoiceNotes(summaryId: widget.summaryId, visibility: widget.visibility);
    if (mounted) {
      setState(() {
        _voiceNotes = notes;
        _loading = false;
      });
    }
  }

  Future<void> _togglePlay(SummaryVoiceNoteModel note) async {
    if (_playingId == note.id && _isPlaying) {
      await _player.pause();
      return;
    }
    if (_playingId == note.id && !_isPlaying) {
      await _player.resume();
      return;
    }
    await _player.stop();
    setState(() {
      _playingId = note.id;
      _playedSeconds = 0;
    });
    await _player.play(ap.UrlSource(note.streamUrl));
  }

  Future<void> _delete(SummaryVoiceNoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Voice Note'),
        content: const Text('Are you sure you want to delete this voice note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (_playingId == note.id) {
      await _player.stop();
      setState(() {
        _playingId = null;
        _isPlaying = false;
        _playedSeconds = 0;
      });
    }
    final ok = await ref
        .read(summariesController.notifier)
        .deleteVoiceNote(summaryId: widget.summaryId, voiceNoteId: note.id);
    if (ok && mounted) {
      setState(() => _voiceNotes = _voiceNotes.where((n) => n.id != note.id).toList());
    }
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return _sidebarShell(
      context: context,
      header: 'Voice Notes',
      headerColor: appColors.primaryDark,
      trailing: _countBadge(context, _voiceNotes.length),
      child: _loading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: appColors.primaryDark,
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_voiceNotes.isEmpty)
                  AppText.bodySmall(
                    'No voice notes recorded.',
                    color: appColors.textSecondary,
                    fontSize: 12,
                  ),
                for (int i = 0; i < _voiceNotes.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _voiceNoteTile(context, _voiceNotes[i])
                      .animate()
                      .fadeIn(delay: (80 * i).ms, duration: 300.ms, curve: Curves.easeOut)
                      .slideX(begin: -0.15, end: 0, delay: (80 * i).ms, duration: 350.ms, curve: Curves.easeOutCubic),
                ],
              ],
            ),
    );
  }

  Widget _countBadge(BuildContext context, int count) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.primaryDark.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appColors.primaryDark.withValues(alpha: 0.25)),
      ),
      child: AppText.bodySmall(
        '$count note${count == 1 ? '' : 's'}',
        color: appColors.primaryDark,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _voiceNoteTile(BuildContext context, SummaryVoiceNoteModel note) {
    final appColors = context.appColors;
    final isCm = note.visibility == VoiceNoteVisibility.cm;
    final visibilityColor = isCm ? appColors.primaryDark : appColors.secondaryLight;
    final visibilityLabel = isCm ? 'CM' : 'Internal';
    final isThisPlaying = _playingId == note.id && _isPlaying;
    final isThisActive = _playingId == note.id;
    final displayedSec = isThisActive ? _playedSeconds : 0;
    final totalSec = note.durationSec;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: appColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appColors.secondaryLight.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _togglePlay(note),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appColors.primaryDark.withValues(alpha: isThisActive ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: appColors.primaryDark.withValues(alpha: 0.25)),
                  ),
                  child: Icon(
                    isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 20,
                    color: appColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText.bodySmall(
                            note.uploadedBy,
                            color: appColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _chip(context, visibilityLabel, visibilityColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: appColors.textSecondary),
                        const SizedBox(width: 4),
                        AppText.labelSmall(
                          isThisActive
                              ? '${_fmt(displayedSec)} / ${note.formattedDuration}'
                              : note.formattedDuration,
                          color: appColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        if (note.uploadedAt != null) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.calendar_month, size: 12, color: appColors.textSecondary),
                          const SizedBox(width: 4),
                          AppText.labelSmall(
                            DateTimeHelper.datFormatSlash(note.uploadedAt!),
                            color: appColors.textSecondary,
                            fontSize: 11,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _delete(note),
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                  ),
                  child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade400),
                ),
              ),
            ],
          ),
          if (isThisActive && totalSec > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: displayedSec / totalSec,
                minHeight: 3,
                backgroundColor: appColors.primaryDark.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(appColors.primaryDark),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: AppText.labelSmall(
        label,
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _sidebarShell({
    required BuildContext context,
    required String header,
    required Color headerColor,
    required Widget child,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.secondaryLight.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: headerColor.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText.bodyMedium(
                      header,
                      fontWeight: FontWeight.w700,
                      color: headerColor,
                    ),
                  ),
                  if (trailing != null) ...[trailing, const SizedBox(width: 8)],
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: headerColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
