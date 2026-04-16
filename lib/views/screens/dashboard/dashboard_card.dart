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
    return GradientBlurCard();
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
                      cardColor.withOpacity(0.9),
                      cardColor.withOpacity(0.6),
                      cardColor.withOpacity(0.8),
                      cardColor.withOpacity(0.9),
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
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            AppText.headlineMedium(
                              value,
                              fontSize: 16,
                              //fontWeight: FontWeight.w500,
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_outlined,
                              color: iconColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class GradientBlurCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 300,
          height: 400,
          child: Stack(
            children: [
              // 1. The Variable Blur Layer
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      // The blur will be 100% at 'stops: 0.0' and 0% at 'stops: 0.5'
                      colors: [Colors.black, Colors.transparent],
                      stops: [0.0, 0.5],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),

              // 2. The Visual Gradient Surface (Color/Border)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
