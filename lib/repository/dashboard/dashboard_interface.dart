import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/models/secretary_department_users_model.dart';
import 'package:efiling_balochistan/models/secretary_dashboard_model.dart';
import 'package:efiling_balochistan/models/summaries/cm_dashboard_model.dart';

abstract class DashboardInterface extends NetworkBase {
  String cmDashboardUrl(int desgId) =>
      '${baseUrl}dashboard/cm?userDesgID=$desgId';

  String dashboardStatsUrl(int desgId) =>
      '${baseUrl}dashboard?userDesgID=$desgId';

  String secretaryDashboardUrl(int desgId) =>
      '${baseUrl}secretary/dashboard?userDesgID=$desgId';

  String get secretaryDepartmentUsersUrl =>
      '${baseUrl}secretary/dashboard/users';

  Future<CMDashboardModel> getCmDashboard({required int? userDesgId});

  Future<DashboardStatsModel> getDashboardStats({required int? userDesgId});

  Future<SecretaryDashboardModel> getSecretaryDashboard({
    required int? userDesgId,
  });

  Future<SecretaryDepartmentUsersModel> getSecretaryDepartmentUsers({
    required int? userDesgId,
    String query = '',
    int? sectionId,
    String sort = 'pending',
    String direction = 'desc',
    int perPage = 20,
    int page = 1,
  });
}
