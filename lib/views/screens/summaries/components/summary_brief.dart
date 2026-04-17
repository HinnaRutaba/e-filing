import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SummaryBrief extends StatelessWidget {
  final String title;
  final String? note;
  final List<String> paragraphs;
  final String authorName;
  final String authorDesignation;
  final DateTime timestamp;

  const SummaryBrief({
    super.key,
    this.title = 'Brief on Summary',
    this.note,
    required this.paragraphs,
    required this.authorName,
    required this.authorDesignation,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Colors.orange.shade700;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(accent),
          if (note != null) _buildNote(),
          _buildBody(),
          _buildFooter(accent),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        border: Border(
          bottom: BorderSide(color: accent.withValues(alpha: 0.25)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_outlined, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: AppText.titleMedium(
              title,
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: accent.withValues(alpha: 0.75),
          ),
        ],
      ),
    );
  }

  Widget _buildNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: AppColors.secondaryLight.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Text(
        note!,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < paragraphs.length; i++) ...[
            AppText.bodyMedium(
              paragraphs[i],
              color: AppColors.textPrimary,
              height: 1.55,
            ),
            if (i != paragraphs.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D6),
        border: Border(top: BorderSide(color: accent.withValues(alpha: 0.2))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.titleSmall(
                  authorName,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                //const SizedBox(height: 4),
                AppText.labelLarge(
                  authorDesignation,
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppText.labelSmall(
            DateTimeHelper.fullDayMonthNameWithTime(DateTime.now()),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
