import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/models/secretary_department_users_model.dart';
import 'package:efiling_balochistan/models/secretary_dashboard_model.dart';
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

  @override
  Future<SecretaryDashboardModel> getSecretaryDashboard({
    required int? userDesgId,
  }) async {
    if (userDesgId == null) {
      throw Exception(
        'Designation ID is required to fetch secretary dashboard',
      );
    }
    final Map<String, dynamic> data = await dioClient.get(
      url: secretaryDashboardUrl(userDesgId),
      options: await options(authRequired: true),
    );
    return SecretaryDashboardModel.fromJson(
      Map<String, dynamic>.from(data['data']),
    );
  }

  @override
  Future<SecretaryDepartmentUsersModel> getSecretaryDepartmentUsers({
    required int? userDesgId,
    String query = '',
    int? sectionId,
    String sort = 'pending',
    String direction = 'desc',
    int perPage = 20,
    int page = 1,
  }) async {
    if (userDesgId == null) {
      throw Exception('Designation ID is required to fetch department users');
    }
    final Map<String, dynamic> data = await dioClient.get(
      url: secretaryDepartmentUsersUrl,
      queryParameters: {
        'userDesgID': userDesgId,
        'q': query,
        'section_id': sectionId ?? '',
        'sort': sort,
        'direction': direction,
        'per_page': perPage,
        'page': page,
      },
      options: await options(authRequired: true),
    );
    return SecretaryDepartmentUsersModel.fromJson(
      Map<String, dynamic>.from(data['data']),
    );
  }
}
