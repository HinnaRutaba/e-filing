import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/models/summaries/cm_dashboard_model.dart';
import 'package:efiling_balochistan/repository/dashboard/dashboard_interface.dart';

class DashboardRepo extends DashboardInterface {
  @override
  Future<CMDashboardModel> getCmDashboard({required int? userDesgId}) async {
    if (userDesgId == null) {
      throw Exception('Designation ID is required to fetch CM dashboard');
    }
    final Map<String, dynamic> data = await dioClient.get(
      url: cmDashboardUrl(userDesgId),
      options: await options(authRequired: true),
    );
    return CMDashboardModel.fromJson(Map<String, dynamic>.from(data['data']));
  }

  @override
  Future<DashboardStatsModel> getDashboardStats({
    required int? userDesgId,
  }) async {
    if (userDesgId == null) {
      throw Exception('Designation ID is required to fetch dashboard stats');
    }
    final Map<String, dynamic> data = await dioClient.get(
      url: dashboardStatsUrl(userDesgId),
      options: await options(authRequired: true),
    );
    return DashboardStatsModel.fromJson(
      Map<String, dynamic>.from(data['data']),
    );
  }
}
