import 'dart:typed_data';

import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:efiling_balochistan/views/widgets/html_reader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

class SummaryDocumentCard extends StatefulWidget {
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
  State<SummaryDocumentCard> createState() => _SummaryDocumentCardState();
}

class _SummaryDocumentCardState extends State<SummaryDocumentCard> {
  bool _signExpanded = false;
  Uint8List? _signatureImage;
  late final SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final dateText =
        'Dated Quetta the ${DateFormat('d MMMM, yyyy').format(widget.summaryDate)}';

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
                      widget.department.toUpperCase(),
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
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText.bodyMedium(
                            widget.subject.isEmpty
                                ? '—'
                                : widget.subject.toUpperCase(),
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
                    const SizedBox(height: 28),
                    _signaturePad(),
                    const SizedBox(height: 8),
                    _signatoryBlock(),
                    const SizedBox(height: 24),
                    AppText.bodyMedium(
                      widget.destination,
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
          _verticalLabel('BARCODE: ${widget.barcode}'),
          const SizedBox(height: 12),
          Container(width: 28, height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _verticalLabel(
            'SUMMARY NO: ${widget.summaryNumber}\n${DateFormat('dd-MM-yyyy').format(widget.summaryDate)}',
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
    final hasContent = widget.htmlContent.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: hasContent
          ? HtmlReader(
              html: widget.htmlContent,
              textStyle: const TextStyle(
                color: AppColors.black,
                fontFamily: fileFont,
              ),
            )
          : AppText.bodyMedium(
              'No content provided.',
              color: AppColors.textSecondary,
            ),
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

  Widget _signatoryBlock() {
    final stamp = DateFormat(
      'h:mm a EEE d MMM yyyy',
    ).format(widget.recipientTimestamp);
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AppText.bodyMedium(
            widget.recipientTitle,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: fileFont,
          ),
          const SizedBox(height: 2),
          AppText.bodySmall(
            '(${widget.recipientDesignation})',
            color: Colors.grey[900],
            fontSize: 12,
            fontFamily: fileFont,
          ),
          AppText.bodySmall(
            widget.recipientDepartment,
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
