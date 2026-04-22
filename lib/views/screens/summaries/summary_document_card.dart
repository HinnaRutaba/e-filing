import 'dart:typed_data';

import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_actions_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_remark_track_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:efiling_balochistan/views/widgets/handwritten_strokes_view.dart';
import 'package:efiling_balochistan/views/widgets/html_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

class SummaryDocumentCard extends ConsumerStatefulWidget {
  final SummaryModel summary;
  final List<SummaryRemarkTrackModel> remarkTrack;
  final SummaryActionsModel? actions;
  final Widget? forwardingSection;

  const SummaryDocumentCard({
    super.key,
    required this.summary,
    required this.remarkTrack,
    this.actions,
    this.forwardingSection,
  });

  @override
  ConsumerState<SummaryDocumentCard> createState() =>
      _SummaryDocumentCardState();
}

class _SummaryDocumentCardState extends ConsumerState<SummaryDocumentCard> {
  bool _signExpanded = false;
  Uint8List? _signatureImage;
  late final SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    debugPrint("REMARK_______${widget.remarkTrack.length}");
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: AppColors.textPrimary,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  SummaryModel get _s => widget.summary;
  DateTime get _summaryDate => _s.createdAt ?? _s.summaryDate ?? DateTime.now();
  String get _summaryNo => _s.summaryNo ?? '';
  String get _department => _s.originatingDepartment ?? '';
  String get _subject => _s.subject ?? '';
  String get _htmlContent => _s.body ?? '';

  @override
  Widget build(BuildContext context) {
    final dateText =
        'Dated Quetta the ${DateTimeHelper.dateFormatddMMYYWithTime(_summaryDate)}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _barcodeStrip(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.primaryDark, width: 4),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppText.labelSmall(
                      dateText,
                      color: AppColors.textSecondary,
                      fontFamily: fileFont,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: Image.asset('assets/govt1.png', height: 48)),
                  const SizedBox(height: 8),
                  AppText.titleMedium(
                    'GOVERNMENT OF BALOCHISTAN',
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    fontFamily: fileFont,
                  ),
                  const SizedBox(height: 2),
                  AppText.titleMedium(
                    _department.toUpperCase(),
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: fileFont,
                  ),
                  const SizedBox(height: 16),
                  AppText.titleMedium(
                    'Summary for Honorable Chief Minister, Balochistan',
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w800,
                    underline: true,
                    color: AppColors.textPrimary,
                    fontFamily: fileFont,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bodyMedium(
                        'Subject:',
                        fontWeight: FontWeight.w700,
                        fontFamily: fileFont,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText.bodyMedium(
                          _subject.isEmpty ? '—' : _subject.toUpperCase(),
                          fontWeight: FontWeight.w700,
                          underline: true,
                          fontFamily: fileFont,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _htmlBody(),
                  if (!(widget.actions?.isDisposed ?? false)) ...[
                    const SizedBox(height: 8),
                    if (ref
                            .read(summariesController)
                            .meta
                            ?.activeUserDesg
                            ?.roleEnum !=
                        ActiveUserDesgRole.deo)
                      _signaturePad(),
                    if (_signatureImage != null &&
                        widget.forwardingSection != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: widget.forwardingSection!,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                  Builder(
                    builder: (_) {
                      final signedTracks = widget.remarkTrack
                          .where((t) => t.actionType == 'signed_and_forwarded')
                          .toList();
                      if (signedTracks.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText.bodyMedium(
                              widget.summary.currentHolder ?? '',
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: fileFont,
                            ),
                            AppText.bodySmall(
                              '(${widget.summary.currentHolderDesignation})',
                              color: Colors.grey[900],
                              fontSize: 12,
                              fontFamily: fileFont,
                            ),

                            AppText.bodySmall(
                              widget.summary.currentDepartment!,
                              color: Colors.grey[900],
                              fontSize: 12,
                              fontFamily: fileFont,
                            ),
                            if (widget.summary.updatedAt != null)
                              AppText.labelSmall(
                                DateTimeHelper.dateFormatddMMYYWithTime(
                                  widget.summary.updatedAt!,
                                ),
                              ),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: AppText.bodyMedium(
                                widget.summary.draftTargetDepartment ?? '',
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: fileFont,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          for (final track in signedTracks) ...[
                            _remarkTrackBlock(track),
                            const SizedBox(height: 18),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barcodeStrip() {
    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _verticalLabel('BARCODE: $_summaryNo'),
          const SizedBox(height: 12),
          Container(width: 28, height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _verticalLabel(
            'SUMMARY NO: $_summaryNo\n${DateFormat('dd-MM-yyyy').format(_summaryDate)}',
          ),
        ],
      ),
    );
  }

  Widget _verticalLabel(String text) {
    return RotatedBox(
      quarterTurns: 3,
      child: AppText.labelSmall(
        text,
        textAlign: TextAlign.center,
        fontFamily: fileFont,
        color: Colors.grey[900],
      ),
    );
  }

  Widget _htmlBody() {
    final hasContent = _htmlContent.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: hasContent
          ? HtmlReader(
              html: _htmlContent,
              textStyle: const TextStyle(
                color: AppColors.black,
                fontFamily: fileFont,
                fontSize: 14,
              ),
            )
          : AppText.bodyMedium(
              'No content provided.',
              color: AppColors.textSecondary,
            ),
    );
  }

  Widget _remarkTrackBlock(SummaryRemarkTrackModel track) {
    final hasHtmlRemarks =
        (track.remarks ?? '').trim().isNotEmpty &&
        track.remarks!.trim() != '[handwritten remark]';
    final hasHandwritten =
        (track.hasHandwritten ?? false) &&
        (track.handwrittenStrokes?.strokes.isNotEmpty ?? false);
    final hasSignature = (track.signatureUrl ?? '').isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasHtmlRemarks)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: HtmlReader(
              html: track.remarks!,
              textStyle: const TextStyle(
                color: AppColors.black,
                fontFamily: fileFont,
              ),
            ),
          ),
        if (hasHandwritten)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: HandwrittenStrokesView(
              strokes: track.handwrittenStrokes!,
              fallbackColor: AppColors.textPrimary.toString(),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasSignature)
                Image.network(
                  track.signatureUrl!,
                  fit: BoxFit.contain,
                  width: 80,
                  height: 80,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                ),
              AppText.bodyMedium(
                track.actorName ?? '',
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: fileFont,
              ),
              if ((track.actorDesignation ?? '').isNotEmpty)
                AppText.bodySmall(
                  '(${track.actorDesignation})',
                  color: Colors.grey[900],
                  fontSize: 12,
                  fontFamily: fileFont,
                ),
              if ((track.fromDepartment ?? '').isNotEmpty)
                AppText.bodySmall(
                  track.fromDepartment!,
                  color: Colors.grey[900],
                  fontSize: 12,
                  fontFamily: fileFont,
                ),
              if (track.actedAtDisplay != null)
                AppText.labelSmall(track.actedAtDisplay!),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium(
                      track.toUserDesignation ?? '',
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: fileFont,
                    ),

                    AppText.bodySmall(
                      '${track.toDepartment}',
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontFamily: fileFont,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _signaturePad() {
    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 280),
        sizeCurve: Curves.easeOutCubic,
        firstCurve: Curves.easeOut,
        secondCurve: Curves.easeIn,
        alignment: Alignment.centerRight,
        crossFadeState: _signExpanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: _signatureImage != null
            ? _signedPreview()
            : _collapsedPad(),
        secondChild: _expandedPad(),
      ),
    );
  }

  Widget _collapsedPad() {
    return InkWell(
      onTap: () => setState(() => _signExpanded = true),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 140,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.secondaryLight.withValues(alpha: 0.45),
            style: BorderStyle.solid,
          ),
          color: AppColors.secondaryLight.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppColors.secondaryDark,
            ),
            const SizedBox(width: 6),
            AppText.labelLarge(
              'Tap to sign',
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _signedPreview() {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => _signExpanded = true),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 140,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.secondaryLight.withValues(alpha: 0.45),
              ),
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Image.memory(_signatureImage!, fit: BoxFit.contain),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.secondaryLight.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: AppColors.secondaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandedPad() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.white,
            ),
          ),
          Container(
            color: AppColors.secondaryLight.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                AppText.labelSmall(
                  'Sign above',
                  color: AppColors.textSecondary,
                ),
                const Spacer(),
                AppTextLinkButton(
                  onPressed: () {
                    _signatureController.clear();
                    setState(() => _signatureImage = null);
                  },
                  icon: Icons.refresh,
                  text: "Clear",
                  color: AppColors.secondaryDark,
                ),
                AppTextLinkButton(
                  onPressed: () async {
                    if (_signatureController.isNotEmpty) {
                      final bytes = await _signatureController.toPngBytes();
                      if (!mounted) return;
                      setState(() {
                        _signatureImage = bytes;
                        _signExpanded = false;
                      });
                    } else {
                      setState(() => _signExpanded = false);
                    }
                  },
                  icon: Icons.check,
                  text: "Done",
                  color: AppColors.secondaryDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
