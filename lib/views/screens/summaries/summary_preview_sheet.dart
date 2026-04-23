import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_daak_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_file_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/html_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SummaryPreviewSheet extends StatelessWidget {
  final String content;
  final String? department;
  final DateTime summaryDate;
  final String subject;
  final XFile? mainPdf;
  final List<FlagAndAttachmentModel> attachments;
  final List<SummaryDaakModel> linkedDaak;
  final List<SummaryFileModel> linkedFiles;
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
        color: context.appColors.surfaceMuted,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _documentCard(
                        context: context,
                        department: dept,
                        dateText: dateText,
                        subject: subject,
                      ),
                      const SizedBox(height: 14),
                      _attachmentsCard(context),
                    ],
                  ),
                ),
              ),
              _footer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      color: appColors.secondaryDark,
      child: Row(
        children: [
          IconButton(
            onPressed: () => RouteHelper.pop(),
            icon: Icon(Icons.arrow_back, color: appColors.accent, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyMedium(
                'Summary Preview',
                color: appColors.accent,
                fontWeight: FontWeight.w700,
              ),
              AppText.bodySmall(
                'This is how the secretary will see your draft',
                color: appColors.accent.withValues(alpha: 0.85),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _documentCard({
    required BuildContext context,
    required String department,
    required String dateText,
    required String subject,
  }) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withValues(alpha: 0.08),
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
              AppText.bodyMedium(
                'Subject:',
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.bodyMedium(
                  subject.isEmpty ? '—' : subject.toUpperCase(),
                  fontWeight: FontWeight.w700,
                  underline: true,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: appColors.border),
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
                      : HtmlReader(html: content),
                ),
                Divider(color: appColors.border),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Consumer(
                    builder: (context, ref, _) {
                      ActiveUserDesg? userDesg = ref
                          .read(summariesController)
                          .meta
                          ?.activeUserDesg;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppText.bodyMedium(
                            userDesg?.department ?? '---',
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 2),
                          AppText.bodySmall(
                            userDesg?.designation ?? '---',
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Divider(color: appColors.border),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(8),
                  child: AppText.labelSmall(
                    DateTimeHelper.dayNameDMYFormat(summaryDate),
                    color: AppColors.textPrimary,
                  ),
                ),
                Divider(color: appColors.border),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.forward_rounded,
                        color: appColors.secondaryDark,
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
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _linkedRefRow(BuildContext context, String text) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AppText.bodySmall(
              text,
              color: appColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentsCard(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final flagAttachments = attachments
        .where((a) => a.attachment != null)
        .toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withValues(alpha: 0.08),
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
              const Icon(Icons.attach_file_rounded, size: 16),
              const SizedBox(width: 6),
              AppText.bodyMedium('Attachments', fontWeight: FontWeight.w700),
            ],
          ),
          const SizedBox(height: 10),
          _attachmentRow(
            context: context,
            label: 'Main PDF',
            name: mainPdf?.name,
            isMain: true,
          ),
          for (final a in flagAttachments)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _attachmentRow(
                context: context,
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
    required BuildContext context,
    required String label,
    required String? name,
    required bool isMain,
  }) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: appColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (isMain)
            Icon(Icons.picture_as_pdf, size: 18, color: theme.colorScheme.error)
          else
            Container(
              width: 28,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                ),
              ),
              child: AppText.bodySmall(
                label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: appColors.secondaryLight,
              ),
            ),
          const SizedBox(width: 10),
          if (isMain)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppText.bodySmall(
                'Main PDF',
                color: appColors.secondaryLight,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          Expanded(
            child: AppText.bodySmall(
              name ?? 'Not attached',
              color: name == null
                  ? appColors.textSecondary
                  : appColors.textPrimary,
              fontSize: 12,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: appColors.secondaryLight.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: appColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AppText.bodySmall(
                  'This is a draft preview. Attachments will be visible after saving.',
                  color: appColors.textSecondary,
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
                color: theme.colorScheme.error,
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
                  backgroundColor: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
