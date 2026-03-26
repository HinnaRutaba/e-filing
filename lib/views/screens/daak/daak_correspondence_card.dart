import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class DaakCorrespondenceCard extends StatefulWidget {
  final String status; // "Forwarded" or "Received"
  final Color statusColor;
  final String dateTime;
  final String sender;
  final String department;
  final String message;
  final bool isBold;

  const DaakCorrespondenceCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.dateTime,
    required this.sender,
    required this.department,
    required this.message,
    this.isBold = false,
  });
  @override
  State<DaakCorrespondenceCard> createState() => _DaakCorrespondenceCardState();
}

class _DaakCorrespondenceCardState extends State<DaakCorrespondenceCard> {
  bool _isExpanded = false;

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: widget.statusColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
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
                widget.sender,
                fontWeight: FontWeight.w600,
              ),
              Text(
                widget.message,
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
        Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.black54,
        ),
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
                    widget.sender,
                    fontWeight: FontWeight.w600,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.apartment,
                          size: 16, color: Colors.black45),
                      const SizedBox(width: 4),
                      AppText.labelLarge(
                        "${widget.department} Department",
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppText.labelMedium(
                widget.status,
                color: widget.statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _toggle,
              child: Icon(Icons.expand_less, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.message,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              widget.dateTime,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}
