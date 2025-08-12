part of 'dashboard_screen.dart';

class DashboardCard extends StatelessWidget {
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;
  const DashboardCard(
      {super.key,
      required this.cardColor,
      required this.iconColor,
      required this.title,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 6,
      shadowColor: cardColor.withOpacity(0.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                cardColor,
                cardColor.withOpacity(0.5),
                cardColor.withOpacity(0.2),
                cardColor.withOpacity(0.4),
                cardColor.withOpacity(0.6),
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dashboard_rounded,
                    color: iconColor,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_right_outlined,
                    color: iconColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppText.bodyLarge(
                title,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[900],
              ),
              AppText.headlineMedium(value)
            ],
          ),
        ),
      ),
    );
  }
}
