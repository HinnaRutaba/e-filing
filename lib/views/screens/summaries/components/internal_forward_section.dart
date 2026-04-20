import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/summaries/summary_internal_forward_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_internal_forward_remark_model.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/html_reader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InternalForwardSection extends StatelessWidget {
  final List<SummaryInternalForwardModel> forwards;

  const InternalForwardSection({super.key, required this.forwards});

  @override
  Widget build(BuildContext context) {
    if (forwards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Internal Forwards',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: forwards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              _ForwardThread(forward: forwards[index]),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ForwardThread extends StatelessWidget {
  final SummaryInternalForwardModel forward;

  const _ForwardThread({required this.forward});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ForwardBubble(forward: forward),
        if (forward.remarks.isNotEmpty) ...[
          _ThreadConnector(),
          _RemarksList(remarks: forward.remarks),
        ],
      ],
    );
  }
}

class _ForwardBubble extends StatelessWidget {
  final SummaryInternalForwardModel forward;

  const _ForwardBubble({required this.forward});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final fromUser = forward.forwardedBy ?? '-';
    final toUser = forward.forwardedTo ?? '-';
    final fromDesignation = forward.forwardedByDesignation ?? '';
    final toDesignation = forward.forwardedToDesignation ?? '';
    final status = forward.statusLabel ?? '-';
    final date = forward.submittedAt ?? forward.createdAt;
    final instruction = forward.instruction ?? '';

    return Container(
      decoration: BoxDecoration(
        color: appColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _userChip(
                context,
                fromUser,
                fromDesignation,
                color: appColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.undo_rounded,
                size: 14,
                color: appColors.textSecondary,
              ),
              const SizedBox(width: 8),
              _userChip(
                context,
                toUser,
                toDesignation,
                color: appColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodySmall(
                'Instruction',
                color: theme.colorScheme.error,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
              HtmlReader(html: instruction.isEmpty ? '-' : instruction),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statusPill(context, status),
              const Spacer(),
              if (date != null)
                AppText.bodySmall(
                  DateFormat('dd MMM yyyy, hh:mm a').format(date),
                  color: appColors.textSecondary,
                  fontSize: 11,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userChip(
    BuildContext context,
    String name,
    String designation, {
    required Color color,
  }) {
    final appColors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: color,
          child: Icon(Icons.person, size: 12, color: appColors.accent),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bodySmall(
              name,
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            if (designation.isNotEmpty)
              AppText.labelSmall(
                designation,
                color: appColors.textSecondary,
                fontSize: 10,
              ),
          ],
        ),
      ],
    );
  }

  Widget _statusPill(BuildContext context, String status) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.undo_rounded, size: 12, color: theme.colorScheme.error),
          const SizedBox(width: 4),
          AppText.bodySmall(
            status,
            color: theme.colorScheme.error,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}

class _ThreadConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: 12,
                color: AppColors.secondary.withValues(alpha: .3),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.4),
                ),
              ),
              Container(
                width: 2,
                height: 4,
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            'Remarks',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemarksList extends StatelessWidget {
  final List<SummaryInternalForwardRemarkModel> remarks;

  const _RemarksList({required this.remarks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < remarks.length; i++) ...[
            _RemarkBubble(remark: remarks[i], index: i),
            if (i < remarks.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Container(
                  width: 2,
                  height: 6,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _RemarkBubble extends StatefulWidget {
  final SummaryInternalForwardRemarkModel remark;
  final int index;

  const _RemarkBubble({required this.remark, required this.index});

  @override
  State<_RemarkBubble> createState() => _RemarkBubbleState();
}

class _RemarkBubbleState extends State<_RemarkBubble> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remark = widget.remark;
    final initials = HelperUtils.firstTwoLetters(remark.submittedBy ?? '');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            initials.isNotEmpty ? initials : '?',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 2, right: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header — always visible, tap to toggle
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                remark.submittedBy ?? '-',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (remark.submittedByDesignation != null &&
                                  remark.submittedByDesignation!
                                      .trim()
                                      .isNotEmpty)
                                Text(
                                  remark.submittedByDesignation!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (remark.remarkType != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              remark.remarkType!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Collapsible body
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 8, thickness: 0.5),

                        // Para / heading
                        if ((remark.paraNumber != null &&
                                remark.paraNumber!.trim().isNotEmpty) ||
                            (remark.heading != null &&
                                remark.heading!.trim().isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                if (remark.paraNumber != null &&
                                    remark.paraNumber!.trim().isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Para ${remark.paraNumber}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                if (remark.heading != null &&
                                    remark.heading!.trim().isNotEmpty)
                                  Expanded(
                                    child: Text(
                                      remark.heading!,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        // Content
                        if (remark.content != null &&
                            remark.content!.trim().isNotEmpty)
                          HtmlReader(html: remark.content ?? ''),
                      ],
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
