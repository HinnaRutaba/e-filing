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
  });

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeTextColor;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
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
              body,
            ],
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
