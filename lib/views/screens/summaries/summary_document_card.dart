import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/html_reader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryDocumentCard extends StatelessWidget {
  final String barcode;
  final String summaryNumber;
  final DateTime summaryDate;
  final String department;
  final String subject;
  final String htmlContent;
  final String recipientTitle;
  final String recipientDesignation;
  final String recipientDepartment;
  final DateTime recipientTimestamp;
  final String destination;

  const SummaryDocumentCard({
    super.key,
    required this.barcode,
    required this.summaryNumber,
    required this.summaryDate,
    required this.department,
    required this.subject,
    required this.htmlContent,
    required this.recipientTitle,
    required this.recipientDesignation,
    required this.recipientDepartment,
    required this.recipientTimestamp,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final dateText =
        'Dated Quetta the ${DateFormat('d MMMM, yyyy').format(summaryDate)}';

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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _barcodeStrip(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
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
                      department.toUpperCase(),
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: fileFont,
                    ),
                    const SizedBox(height: 16),
                    AppText.titleMedium(
                      'Summary for Honorable Chief Minister, Balochistan',
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w700,
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText.bodyMedium(
                            subject.isEmpty ? '—' : subject.toUpperCase(),
                            fontWeight: FontWeight.w700,
                            underline: true,
                            fontFamily: fileFont,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _htmlBody(),
                    const SizedBox(height: 28),
                    _signatoryBlock(),
                    const SizedBox(height: 24),
                    AppText.bodyMedium(
                      destination,
                      fontWeight: FontWeight.w700,
                      underline: true,
                      color: AppColors.textPrimary,
                      fontFamily: fileFont,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barcodeStrip() {
    return Container(
      width: 44,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.primaryDark, width: 4),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _verticalLabel('BARCODE: $barcode'),
          const SizedBox(height: 12),
          Container(width: 28, height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _verticalLabel(
            'SUMMARY NO: $summaryNumber\n${DateFormat('dd-MM-yyyy').format(summaryDate)}',
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
    final hasContent = htmlContent.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: hasContent
          ? HtmlReader(html: htmlContent)
          : AppText.bodyMedium(
              'No content provided.',
              color: AppColors.textSecondary,
            ),
    );
  }

  Widget _signatoryBlock() {
    final stamp = DateFormat(
      'h:mm a EEE d MMM yyyy',
    ).format(recipientTimestamp);
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AppText.bodyMedium(
            recipientTitle,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: fileFont,
          ),
          const SizedBox(height: 2),
          AppText.bodySmall(
            '($recipientDesignation)',
            color: Colors.grey[900],
            fontSize: 12,
            fontFamily: fileFont,
          ),
          AppText.bodySmall(
            recipientDepartment,
            color: Colors.grey[900],
            fontSize: 12,
            fontFamily: fileFont,
          ),
          const SizedBox(height: 2),
          AppText.bodySmall(
            stamp,
            color: Colors.grey[900],
            fontSize: 12,
            fontFamily: fileFont,
          ),
        ],
      ),
    );
  }
}
