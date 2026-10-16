import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.body,
    this.fill = false,
  });

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeTextColor;
  final Widget body;

  /// Stretch to the height it is given, with [body] taking the space left
  /// under the header (for cards sitting beside a taller one).
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: context.appColors.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.appColors.secondaryLight.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // Only stretch when the height is bounded; while a parent is still
          // measuring (unbounded height) the card just wraps its content.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stretch = fill && constraints.hasBoundedHeight;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (stretch) Expanded(child: body) else body,
                ],
              );
            },
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
