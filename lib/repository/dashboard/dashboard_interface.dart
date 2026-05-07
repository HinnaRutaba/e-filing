import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/summaries/cm_dashboard_model.dart';

abstract class DashboardInterface extends NetworkBase {
  String cmDashboardUrl(int desgId) =>
      '${baseUrl}dashboard/cm?userDesgID=$desgId';

  Future<CMDashboardModel> getCmDashboard({required int? userDesgId});
}
