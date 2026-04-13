import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SummaryPreviewSheet extends StatelessWidget {
  final String content;
  final String? department;
  final DateTime summaryDate;
  final String subject;
  final XFile? mainPdf;
  final List<FlagAndAttachmentModel> attachments;
  final List<DaakModel> linkedDaak;
  final List<FileModel> linkedFiles;
  final VoidCallback onSubmit;

  const SummaryPreviewSheet({
    super.key,
    required this.content,
    required this.department,
    required this.summaryDate,
    required this.subject,
    required this.mainPdf,
    required this.attachments,
    required this.linkedDaak,
    required this.linkedFiles,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final dept = department ?? 'Home Department';
    final dateText =
        'Dated Quetta the ${DateFormat('d MMMM yyyy').format(summaryDate)}';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Material(
        color: AppColors.background,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _documentCard(
                        department: dept,
                        dateText: dateText,
                        subject: subject,
                      ),
                      const SizedBox(height: 14),
                      _attachmentsCard(),
                    ],
                  ),
                ),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      color: AppColors.secondaryDark,
      child: Row(
        children: [
          IconButton(
            onPressed: () => RouteHelper.pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyMedium(
                'Summary Preview',
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
              AppText.bodySmall(
                'This is how the secretary will see your draft',
                color: AppColors.white.withValues(alpha: 0.85),
                //fontSize: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _documentCard({
    required String department,
    required String dateText,
    required String subject,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Image.asset('assets/govt1.png', height: 56)),
          const SizedBox(height: 10),
          AppText.titleMedium(
            'GOVERNMENT OF BALOCHISTAN',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 2),
          AppText.titleMedium(
            department.toUpperCase(),
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: AppText.bodySmall(
              dateText,
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          AppText.titleMedium(
            'Summary for Honorable Chief Minister, Balochistan',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            underline: true,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyMedium('Subject:', fontWeight: FontWeight.w700),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.bodyMedium(
                  subject.isEmpty ? '—' : subject.toUpperCase(),
                  fontWeight: FontWeight.w700,
                  underline: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,

            decoration: BoxDecoration(
              //color: AppColors.cardColorLight,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: content.trim().isEmpty
                      ? AppText.bodyMedium(
                          'No content provided yet.',
                          color: AppColors.textSecondary,
                        )
                      : HtmlWidget(
                          content,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                          renderMode: RenderMode.column,
                        ),
                ),
                const Divider(color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppText.bodyMedium(
                        department,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText.bodySmall(
                        'Additional Secretary-II',
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(8),
                  child: AppText.labelSmall(
                    DateTimeHelper.dayNameDMYFormat(summaryDate),

                    color: AppColors.textPrimary,
                  ),
                ),
                const Divider(color: Colors.grey),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.forward_rounded,
                        color: AppColors.secondaryDark,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      AppText.bodyMedium(
                        department,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (linkedDaak.isNotEmpty || linkedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final d in linkedDaak) _linkedRefRow(d.subject ?? 'Daak'),
            for (final f in linkedFiles) _linkedRefRow(f.subject ?? 'File'),
          ],
        ],
      ),
    );
  }

  Widget _linkedRefRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AppText.bodySmall(
              text,
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentsCard() {
    final flagAttachments = attachments
        .where((a) => a.attachment != null)
        .toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                size: 16,
                color: AppColors.secondaryDark,
              ),
              const SizedBox(width: 6),
              AppText.bodyMedium(
                'Attachments',
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryDark,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _attachmentRow(label: 'Main PDF', name: mainPdf?.name, isMain: true),
          for (final a in flagAttachments)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _attachmentRow(
                label: a.flagType?.title ?? '?',
                name: a.attachment?.name,
                isMain: false,
              ),
            ),
        ],
      ),
    );
  }

  Widget _attachmentRow({
    required String label,
    required String? name,
    required bool isMain,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (isMain)
            const Icon(Icons.picture_as_pdf, size: 18, color: AppColors.error)
          else
            Container(
              width: 28,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                ),
              ),
              child: AppText.bodySmall(
                label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryDark,
              ),
            ),
          const SizedBox(width: 10),
          if (isMain)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppText.bodySmall(
                'Main PDF',
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          Expanded(
            child: AppText.bodySmall(
              name ?? 'Not attached',
              color: name == null
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontSize: 12,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.secondaryLight.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AppText.bodySmall(
                  'This is a draft preview. Attachments will be visible after saving.',
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AppOutlineButton(
                onPressed: () => RouteHelper.pop(),
                text: 'Close',
                color: Colors.red[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppSolidButton(
                  onPressed: () {
                    RouteHelper.pop();
                    onSubmit();
                  },
                  text: 'Looks Good — Submit',
                  icon: Icons.check_circle_outline,
                  width: double.infinity,
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
