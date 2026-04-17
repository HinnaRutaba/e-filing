import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class DaakCorrespondenceCard extends StatefulWidget {
  final DaakMovementModel? movement;

  const DaakCorrespondenceCard({super.key, required this.movement});
  @override
  State<DaakCorrespondenceCard> createState() => _DaakCorrespondenceCardState();
}

class _DaakCorrespondenceCardState extends State<DaakCorrespondenceCard> {
  bool _isExpanded = true;

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    if (widget.movement == null) return const SizedBox.shrink();
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: widget.movement?.actionType?.color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: _toggle,
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildCollapsed(),
            secondChild: _buildExpanded(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsed() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.titleSmall(
                widget.movement?.fromUser ?? 'Unknown',
                fontWeight: FontWeight.w600,
              ),
              Text(
                widget.movement?.remarks ?? '---',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
      ],
    );
  }

  Widget _buildExpanded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.titleSmall(
                    widget.movement?.fromUser ?? 'Unknown',
                    fontWeight: FontWeight.w600,
                  ),
                  AppText.labelMedium(
                    "To: ${widget.movement?.toUser ?? 'Unknown'}",
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.movement?.statusAfter?.color.withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppText.labelMedium(
                widget.movement?.statusAfter?.label ?? 'Unknown',
                color: widget.movement?.statusAfter?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _toggle,
              child: const Icon(Icons.expand_less),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          widget.movement?.remarks ?? '---',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            AppText.labelSmall(
              widget.movement?.actionType?.value.toUpperCase() ?? 'Unknown',
              color: widget.movement?.actionType?.color,
              fontWeight: FontWeight.w500,
            ),
            const Spacer(),
            AppText.labelMedium(
              DateTimeHelper.dateFormatddMMYYWithTime(widget.movement?.actedAt),
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ],
    );
  }
}
