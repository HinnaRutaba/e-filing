import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/attachment_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_brief_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/voice_note_upload_model.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/views/screens/gallery/gallery_view.dart';
import 'package:efiling_balochistan/views/screens/pdf_viewer.dart';
import 'package:efiling_balochistan/views/screens/sticky_tag_drawer.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/attachments_section.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_brief.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/voice_notes_section.dart';
import 'package:efiling_balochistan/views/screens/summaries/summary_document_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/remarks_sign_panel.dart';
import 'package:efiling_balochistan/views/widgets/signature_pad.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';

class SummaryDeskPager extends StatefulWidget {
  const SummaryDeskPager({
    super.key,
    required this.summaries,
    required this.pageController,
    required this.onPageChanged,
    required this.remarksPanelController,
    required this.bottomContent,
    this.panelWidthFactor = 0.8,
    this.tagsAlignment = const Alignment(0.0, -0.5),
    this.initialRemarksMode = RemarksPanelMode.type,
    this.initialPenColor = SignatureColor.darkBlue,
  });

  final List<SummaryDetailsModel> summaries;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final RemarksSignPanelController remarksPanelController;
  final Widget bottomContent;
  final double panelWidthFactor;
  final Alignment tagsAlignment;
  final RemarksPanelMode initialRemarksMode;
  final SignatureColor initialPenColor;

  @override
  State<SummaryDeskPager> createState() => _SummaryDeskPagerState();
}

class _SummaryDeskPagerState extends State<SummaryDeskPager> {
  final List<ScrollController> _scrollControllers = [];

  @override
  void initState() {
    super.initState();
    _syncControllers(widget.summaries.length);
  }

  @override
  void didUpdateWidget(SummaryDeskPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers(widget.summaries.length);
  }

  void _syncControllers(int count) {
    while (_scrollControllers.length < count) {
      _scrollControllers.add(ScrollController());
    }
    while (_scrollControllers.length > count) {
      _scrollControllers.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _viewAttachment(BuildContext context, AttachmentModel attachment) {
    if (attachment.fileUrl == null) {
      Toast.error(message: 'No file URL found for this attachment.');
      return;
    }
    final category = HelperUtils.getFileCategoryFromUrl(attachment.fileUrl!);
    if (category == FileCategory.pdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewer(
            url: attachment.fileUrl,
            title: attachment.originalName ?? 'Attachment',
          ),
        ),
      );
      return;
    }
    if (category == FileCategory.image) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GalleryView(imageUrls: [attachment.fileUrl!], initialIndex: 0),
        ),
      );
      return;
    }
    FilePickerService().downloadFile(
      context,
      attachment.fileUrl!,
      attachment.originalName ?? 'Attachment',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.pageController,
      itemCount: widget.summaries.length,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: widget.onPageChanged,
      itemBuilder: (_, i) {
        final details = widget.summaries[i];
        final summary = details.summary;
        final pageKey = ValueKey(summary?.id ?? i);
        final scrollCtrl = _scrollControllers[i];

        return StickyTagDrawer(
          panelWidth: MediaQuery.sizeOf(context).width * widget.panelWidthFactor,
          tagsAlignment: widget.tagsAlignment,
          mainContent: Scrollbar(
            controller: scrollCtrl,
            thickness: 10,
            trackVisibility: true,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
              child: Column(
                children: [
                  if (summary != null)
                    SummaryDocumentCard(
                      summary: summary,
                      remarkTrack: details.remarkTrack,
                      actions: details.actions,
                    ),
                  RemarksSignPanel(
                    key: pageKey,
                    controller: widget.remarksPanelController,
                    scrollController: scrollCtrl,
                    initialMode: widget.initialRemarksMode,
                    bottomContent: widget.bottomContent,
                    initiallyExpanded: true,
                    showHeading: false,
                    initialPenColor: widget.initialPenColor,
                    signPadWidth: 450,
                  ),
                ],
              ),
            ),
          ),
          tags: [
            StickyTag(
              text: 'Attachment (${details.attachments.length})',
              backgroundColor: AppColors.primary,
              panelContent: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: AttachmentsSection(
                    mainPdf: null,
                    attachments: details.attachments,
                    canAddMore: false,
                    canDelete: false,
                    onViewAttachment: (a) => _viewAttachment(context, a),
                    onDeleteAttachment: (_) {},
                  ),
                ),
              ),
            ),
            StickyTag(
              text: 'Brief (${details.briefs.length})',
              backgroundColor: Colors.orange,
              panelContent: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                physics: const BouncingScrollPhysics(),
                child: details.briefs.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: AppText.bodyMedium('No briefs available'),
                        ),
                      )
                    : Column(
                        children: [
                          for (int j = 0; j < details.briefs.length; j++) ...[
                            if (j > 0) const SizedBox(height: 12),
                            _buildBriefCard(details.briefs[j]),
                          ],
                        ],
                      ),
              ),
            ),
            StickyTag(
              text:
                  'Voice Notes (${details.voiceNotes.where((v) => v.visibility == VoiceNoteVisibility.cm).length})',
              backgroundColor: Colors.teal,
              panelContent: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: VoiceNotesSection(
                    summaryId: summary?.id,
                    visibility: VoiceNoteVisibility.cm,
                    canDelete: false,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBriefCard(SummaryBriefModel brief) {
    final paragraphs = (brief.briefNote ?? '').trim().isNotEmpty
        ? [brief.briefNote!]
        : <String>[];
    return SummaryBrief(
      paragraphs: paragraphs,
      authorName: brief.actor ?? '',
      authorDesignation: '',
      timestamp: brief.actedAt ?? DateTime.now(),
      note: 'For internal use only — will not appear on the printed summary.',
    );
  }
}
