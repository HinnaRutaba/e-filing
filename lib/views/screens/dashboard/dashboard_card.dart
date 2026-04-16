part of 'dashboard_screen.dart';

class DashboardCard extends StatelessWidget {
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool loading;
  final bool showSmallCard;
  final IconData icon;
  const DashboardCard({
    super.key,
    required this.cardColor,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
    required this.icon,
    this.loading = false,
    this.showSmallCard = true,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildCard(),
          Positioned(
          top: showSmallCard ? -8 : 6,
          right: showSmallCard
              ? value == null
                    ? -8
                    : 12
              : 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child:
                InkWell(
                      onTap: onTap,
                      child: Container(
                        padding: showSmallCard
                            ? const EdgeInsets.all(4)
                            : const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: cardColor.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                            BoxShadow(
                              color: iconColor.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: showSmallCard
                            ? const Icon(Icons.chevron_right, size: 20)
                            : AppText.titleSmall(
                                "Open",
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondaryDark,
                                fontSize: 10,
                              ),
                      ),
                    )
                    .animate(
                     // onPlay: (c) => c.repeat()
                    )
                    .shimmer(
                      duration: 1600.ms,
                      delay: 1200.ms,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.35),
            offset: const Offset(-4, 4),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
              cardColor.withValues(alpha: 0.2),
              //cardColor.withValues(alpha: 0.4),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.8),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            cardColor.withValues(alpha: 0.6),
                            cardColor.withValues(alpha: 0.2),
                            Colors.white10,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 30,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: showSmallCard ? cardSmall() : cardBody(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget cardBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyLarge(
                title,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
              loading && (value == null || value!.isEmpty || value == '0')
                  ? const Row(
                      children: [
                        SpinKitThreeBounce(color: AppColors.accent, size: 16),
                      ],
                    )
                  : AppText.headlineMedium(
                      value ?? '',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget cardSmall() {
    return Padding(
      padding: value == null
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          if (value != null)
            AppText.headlineMedium(
              value!,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
            ),
        ],
      ),
    );
  }
}
