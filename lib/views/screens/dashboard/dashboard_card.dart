part of 'dashboard_screen.dart';

class DashboardCard extends StatelessWidget {
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool loading;
  const DashboardCard({
    super.key,
    required this.cardColor,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LoadingCard(cardCount: 1)
        : Card(
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
                        AppText.bodyLarge(
                          title,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[900],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            AppText.headlineMedium(
                              value,
                              fontSize: 16,
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_outlined,
                              color: iconColor,
                              size: 16,
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
