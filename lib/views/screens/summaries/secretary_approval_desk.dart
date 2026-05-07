import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/views/screens/summaries/approval_dek.dart';
import 'package:flutter/material.dart';

class SecretaryApprovalDesk extends StatelessWidget {
  const SecretaryApprovalDesk({super.key});

  @override
  Widget build(BuildContext context) {
    return const ApprovalDesk(role: ActiveUserDesgRole.secretary);
  }
}
