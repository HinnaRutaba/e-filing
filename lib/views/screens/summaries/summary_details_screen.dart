import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/screens/summaries/summary_document_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class SummaryMovementEntry {
  final String status;
  final String stage;
  final String department;
  final String user;
  final bool current;
  const SummaryMovementEntry({
    required this.status,
    required this.stage,
    required this.department,
    required this.user,
    this.current = false,
  });
}

class SummaryDetailsScreen extends ConsumerStatefulWidget {
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
  final XFile? mainPdf;
  final List<FlagAndAttachmentModel> attachments;
  final List<SummaryMovementEntry> movementHistory;

  SummaryDetailsScreen({
    super.key,
    this.barcode = 'SUM/HD/2026/000002',
    this.summaryNumber = 'SUB38888',
    DateTime? summaryDate,
    this.department = 'Home Department',
    this.subject = 'SUB38888',
    this.htmlContent = _kFallbackHtml,
    this.recipientTitle = 'Mr. Secretary',
    this.recipientDesignation = 'Additional Chief Secretary (Home)',
    this.recipientDepartment = 'Home Department',
    DateTime? recipientTimestamp,
    this.destination = 'Governor House',
    XFile? mainPdf,
    List<FlagAndAttachmentModel>? attachments,
    this.movementHistory = const [
      SummaryMovementEntry(
        status: 'Current Pending',
        stage: 'Draft from Section',
        department: 'Home Department',
        user: 'Mr. Secretary',
        current: true,
      ),
    ],
  }) : summaryDate = summaryDate ?? _kDemoDate,
       recipientTimestamp = recipientTimestamp ?? _kDemoTimestamp,
       mainPdf = mainPdf ?? XFile('main_summary.pdf'),
       attachments = attachments ?? _demoAttachments();

  @override
  ConsumerState<SummaryDetailsScreen> createState() =>
      _SummaryDetailsScreenState();
}

final DateTime _kDemoDate = DateTime(2026, 4, 14);
final DateTime _kDemoTimestamp = DateTime(2026, 4, 14, 0, 0);

const String _kFallbackHtml = '''
<p>nb cdcbdnmcbdchndmc dscdbcnscbnmsdc sccscvbnsdc dm cmdvchncvnmdc nsc snmcv dnsmc dmnc dmn cdns cds</p>
''';

List<FlagAndAttachmentModel> _demoAttachments() => [
  FlagAndAttachmentModel(
    flagType: FlagModel(id: 1, title: 'A'),
    attachment: XFile('annexure_a.pdf'),
  ),
  FlagAndAttachmentModel(
    flagType: FlagModel(id: 2, title: 'B'),
    attachment: XFile('annexure_b.pdf'),
  ),
  FlagAndAttachmentModel(
    flagType: FlagModel(id: 3, title: 'C'),
    attachment: XFile('annexure_c.pdf'),
  ),
];

class _SummaryDetailsScreenState extends ConsumerState<SummaryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      isdash: false,
      title: "Summary Details",
      actions: [
        AppOutlineButton(
          onPressed: _onPrint,
          text: 'Print Summary',
          icon: Icons.print_outlined,
          color: AppColors.primaryDark,
          width: 160,
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 900;
          final content = _documentCard();
          final sidebar = _sidebar();

          if (wide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 16),
                  SizedBox(width: 280, child: sidebar),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content, const SizedBox(height: 16), sidebar],
            ),
          );
        },
      ),
    );
  }

  void _onPrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print Summary — not wired up yet')),
    );
  }

  Widget _documentCard() {
    return SummaryDocumentCard(
      barcode: widget.barcode,
      summaryNumber: widget.summaryNumber,
      summaryDate: widget.summaryDate,
      department: widget.department,
      subject: widget.subject,
      htmlContent: widget.htmlContent,
      recipientTitle: widget.recipientTitle,
      recipientDesignation: widget.recipientDesignation,
      recipientDepartment: widget.recipientDepartment,
      recipientTimestamp: widget.recipientTimestamp,
      destination: widget.destination,
    );
  }

  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _attachmentsCard(),
        const SizedBox(height: 16),
        _movementCard(),
      ],
    );
  }

  Widget _attachmentsCard() {
    final flagAttachments = widget.attachments
        .where((e) => e.flagType != null || e.attachment != null)
        .toList(growable: false);
    final hasMain = widget.mainPdf != null;
    final isEmpty = !hasMain && flagAttachments.isEmpty;

    return _sidebarShell(
      header: 'Attachments',
      headerColor: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasMain) ...[
            _attachmentRow(
              label: 'Main Summary PDF',
              fileName: widget.mainPdf!.name,
              isMain: true,
              onView: () => _onViewMainPdf(),
            ),
            if (flagAttachments.isNotEmpty) const SizedBox(height: 8),
          ],
          for (int i = 0; i < flagAttachments.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _attachmentRow(
              label: flagAttachments[i].flagType?.title ?? '?',
              fileName: flagAttachments[i].attachment?.name,
              onView: () => _onViewAttachment(flagAttachments[i]),
              onDelete: () => _confirmDeleteAttachment(flagAttachments[i]),
            ),
          ],
          if (isEmpty)
            AppText.bodySmall(
              'No attachments.',
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _attachmentRow({
    required String label,
    String? fileName,
    bool isMain = false,
    required VoidCallback onView,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          if (isMain)
            const Icon(
              Icons.picture_as_pdf_rounded,
              size: 18,
              color: AppColors.error,
            )
          else
            Container(
              width: 26,
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
          Expanded(
            child: AppText.bodySmall(
              isMain ? label : (fileName ?? label),
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (!isMain && onDelete != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onDelete,
              child: Icon(
                Icons.delete_forever,
                color: Colors.red[700],
                size: 24,
              ),
            ),
          ],
          const SizedBox(width: 8),
          _viewButton(onTap: onView),
        ],
      ),
    );
  }

  Widget _viewButton({required VoidCallback onTap}) {
    return Material(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.remove_red_eye_outlined,
                size: 13,
                color: AppColors.white,
              ),
              const SizedBox(width: 4),
              AppText.bodySmall(
                'View',
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onViewAttachment(FlagAndAttachmentModel item) {
    final name = item.attachment?.name ?? item.flagType?.title ?? 'attachment';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Viewing $name')));
  }

  void _onViewMainPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${widget.mainPdf?.name ?? 'Main Summary PDF'}'),
      ),
    );
  }

  Future<void> _confirmDeleteAttachment(FlagAndAttachmentModel item) async {
    final name =
        item.attachment?.name ?? item.flagType?.title ?? 'this attachment';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red[700]),
              const SizedBox(width: 10),
              const Expanded(child: Text('Delete attachment?')),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '"$name"',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '? This action cannot be undone.'),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            AppTextLinkButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              text: "Cancel",
              color: Colors.grey[700],
            ),
            AppOutlineButton(
              width: 120,
              onPressed: () => Navigator.of(ctx).pop(true),
              text: "Delete",
              color: Colors.red[500]!,
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    setState(() => widget.attachments.remove(item));
  }

  Widget _movementCard() {
    final current = widget.movementHistory
        .where((e) => e.current)
        .toList(growable: false);
    final past = widget.movementHistory
        .where((e) => !e.current)
        .toList(growable: false);

    return _sidebarShell(
      header: 'Movement Timeline',
      headerColor: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (past.isEmpty)
            AppText.bodySmall(
              'No movement history yet.',
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          for (final entry in past) ...[
            _movementEntry(entry),
            const SizedBox(height: 8),
          ],
          if (current.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final entry in current) _movementEntry(entry),
          ],
        ],
      ),
    );
  }

  Widget _movementEntry(SummaryMovementEntry entry) {
    final accent = entry.current ? AppColors.primary : AppColors.secondaryLight;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.current
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              AppText.bodySmall(
                entry.status,
                color: accent == AppColors.primary
                    ? AppColors.primaryDark
                    : AppColors.secondaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppText.bodyMedium(
            entry.stage,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
          const SizedBox(height: 4),
          AppText.bodySmall(
            'Department: ${entry.department}',
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          AppText.bodySmall(
            'User: ${entry.user}',
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget _sidebarShell({
    required String header,
    required Color headerColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
                AppText.bodyMedium(
                  header,
                  fontWeight: FontWeight.w700,
                  color: headerColor,
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}
