import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/audio_player/audio_waved_player.dart';
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

  const VoiceNotesSection({
    super.key,
    required this.summaryId,
    required this.visibility,
  });

  @override
  ConsumerState<VoiceNotesSection> createState() => _VoiceNotesSectionState();
}

class _VoiceNotesSectionState extends ConsumerState<VoiceNotesSection> {
  bool _expanded = false;
  bool _loading = false;
  List<SummaryVoiceNoteModel> _voiceNotes = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final notes = await ref
        .read(summariesController.notifier)
        .listVoiceNotes(
          summaryId: widget.summaryId,
          visibility: widget.visibility,
        );
    if (mounted) {
      setState(() {
        _voiceNotes = notes;
        _loading = false;
      });
    }
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
    final ok = await ref
        .read(summariesController.notifier)
        .deleteVoiceNote(summaryId: widget.summaryId, voiceNoteId: note.id);
    if (ok && mounted) {
      setState(
        () => _voiceNotes = _voiceNotes.where((n) => n.id != note.id).toList(),
      );
    }
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
                      .fadeIn(
                        delay: (80 * i).ms,
                        duration: 300.ms,
                        curve: Curves.easeOut,
                      )
                      .slideX(
                        begin: -0.15,
                        end: 0,
                        delay: (80 * i).ms,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic,
                      ),
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
        border: Border.all(
          color: appColors.primaryDark.withValues(alpha: 0.25),
        ),
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
    final visibilityColor = isCm
        ? appColors.primaryDark
        : appColors.secondaryLight;
    final visibilityLabel = isCm ? 'CM' : 'Internal';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: appColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                    if (note.uploadedAt != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 12,
                            color: appColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          AppText.labelSmall(
                            DateTimeHelper.datFormatSlash(note.uploadedAt!),
                            color: appColors.textSecondary,
                            fontSize: 11,
                          ),
                        ],
                      ),
                    ],
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
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          WavedAudioPlayer(
            source: ap.UrlSource(note.streamUrl, mimeType: 'audio/x-wav'),
            iconColor: AppColors.white,
            iconBackgoundColor: appColors.primaryDark,
            playedColor: appColors.primaryDark,
            unplayedColor: appColors.primaryDark.withValues(alpha: 0.2),
            waveWidth: double.infinity,
            barWidth: 3,
            buttonSize: 36,
            showTiming: true,
            timingStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: appColors.textSecondary,
            ),
            onError: (_) {},
          ),
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
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.2),
        ),
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
