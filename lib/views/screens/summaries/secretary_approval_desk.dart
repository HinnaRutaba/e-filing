import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/summaries/approval_dek.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SecretaryApprovalDesk extends StatelessWidget {
  const SecretaryApprovalDesk({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 34,
          backgroundColor: Colors.transparent,
          title: AppText.headlineSmall("Approval Desk"),
        ),
        body: const ApprovalDesk(role: ActiveUserDesgRole.secretary),
      ),
    );
  }
}
