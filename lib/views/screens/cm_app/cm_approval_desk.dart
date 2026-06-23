import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/views/screens/summaries/approval_desk.dart';
import 'package:flutter/material.dart';

class CMApprovalDesk extends StatelessWidget {
  const CMApprovalDesk({super.key});

  @override
  Widget build(BuildContext context) {
    return const ApprovalDesk(role: ActiveUserDesgRole.cm, skipInitialLoad: true);
  }
}

