import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/views/screens/sticky_tag_drawer.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_brief.dart';
import 'package:efiling_balochistan/views/screens/summaries/summary_document_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/remarks_sign_panel.dart';
import 'package:flutter/material.dart';

class SummaryDeskPager extends StatelessWidget {
  const SummaryDeskPager({
    super.key,
    required this.summaries,
    required this.pageController,
    required this.onPageChanged,
    required this.remarksPanelController,
    required this.mainScrollController,
    required this.bottomContent,
    this.panelWidthFactor = 0.8,
    this.tagsAlignment = const Alignment(0.0, -0.5),
    this.initialRemarksMode = RemarksPanelMode.type,
  });

  final List<SummaryModel> summaries;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final RemarksSignPanelController remarksPanelController;
  final ScrollController mainScrollController;
  final Widget bottomContent;
  final double panelWidthFactor;
  final Alignment tagsAlignment;
  final RemarksPanelMode initialRemarksMode;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: summaries.length,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: onPageChanged,
      itemBuilder: (_, i) {
        final summary = summaries[i];
        final pageKey = PageStorageKey<int>(i);
        return StickyTagDrawer(
          panelWidth: MediaQuery.sizeOf(context).width * panelWidthFactor,
          tagsAlignment: tagsAlignment,
          mainContent: Scrollbar(
            controller: mainScrollController,
            thickness: 10,
            trackVisibility: true,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: mainScrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
              child: Column(
                children: [
                  SummaryDocumentCard(summary: summary, remarkTrack: const []),
                  RemarksSignPanel(
                    key: pageKey,
                    controller: remarksPanelController,
                    scrollController: mainScrollController,
                    initialMode: initialRemarksMode,
                    bottomContent: bottomContent,
                  ),
                ],
              ),
            ),
          ),
          tags: [
            StickyTag(
              text: 'Attachment',
              backgroundColor: AppColors.primary,
              panelContent: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Center(
                    child: AppText.bodyMedium('No attachments available'),
                  ),
                ),
              ),
            ),
            StickyTag(
              text: 'Brief',
              backgroundColor: Colors.orange,
              panelContent: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                physics: const BouncingScrollPhysics(),
                child: SummaryBrief(
                  note:
                      'Will not appear on the printed summary as it will be meant for internal departments.',
                  paragraphs: const [
                    '03. Furthermore, it is submitted that the initial presentation, all suggested changes have been incorporated, and the system is now ready for deployment. As an initial step, it is proposed to deploy the E-Filing System in the Admin Section of the Chief Minister Secretariat as a pilot project. Upon successful implementation and evaluation, the system can be expanded to the entire Chief Minister Secretariat and eventually deployed across other government departments.',
                    '04. In this regard, it is kindly requested to approve the deployment of the E-Filing System in the Admin Section of the Chief Minister Secretariat as a pilot project and provide directions for its phased expansion.',
                  ],
                  authorName: 'Mumtaz Haider Khan',
                  authorDesignation: 'Deputy Coordinator (CM)',
                  timestamp: DateTime(2025, 4, 14, 16, 27),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
