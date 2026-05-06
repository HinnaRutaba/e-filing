import 'package:efiling_balochistan/views/screens/summaries/summaries_list_screen.dart';
import 'package:flutter/material.dart';

class CMSummariesListScreen extends StatelessWidget {
  const CMSummariesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 24.0),
      child: SummariesListScreen(),
    );
  }
}
