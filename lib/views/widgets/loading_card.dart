import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';

class LoadingCard extends StatelessWidget {
  final int cardCount;
  const LoadingCard({super.key, this.cardCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cardCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (ctx, i) {
        return const CardLoading(
          height: 50,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          margin: EdgeInsets.only(bottom: 10),
        );
      },
    );
  }
}
