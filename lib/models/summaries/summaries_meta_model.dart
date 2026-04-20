import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/department/department_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/models/internal_user_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_permissions_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_role_flags_model.dart';

class SummariesMetaModel {
  final ActiveUserDesg? activeUserDesg;
  final SummaryPermissionsModel? permissions;
  final SummaryRoleFlagsModel? roleFlags;
  final List<InternalUserModel> internalUsers;
  final List<DepartmentModel> departments;
  final List<FlagModel> flags;

  SummariesMetaModel({
    this.activeUserDesg,
    this.permissions,
    this.roleFlags,
    this.internalUsers = const [],
    this.departments = const [],
    this.flags = const [],
  });

  factory SummariesMetaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SummariesMetaModel();
    return SummariesMetaModel(
      permissions: json['permissions'] != null
          ? SummaryPermissionsModel.fromJson(json['permissions'])
          : null,
      roleFlags: json['role_flags'] != null
          ? SummaryRoleFlagsModel.fromJson(json['role_flags'])
          : null,
      internalUsers: json['internal_users'] != null
          ? (json['internal_users'] as List)
                .map((i) => InternalUserModel.fromJson(i))
                .toList()
          : [],
      departments: json['departments'] != null
          ? (json['departments'] as List)
                .map((i) => DepartmentModel.fromJson(i))
                .toList()
          : [],
      activeUserDesg: json['active_user_desg'] != null
          ? ActiveUserDesg.fromJson(json['active_user_desg'])
          : null,
      flags: json['flags'] != null
          ? (json['flags'] as List).map((i) => FlagModel.fromJson(i)).toList()
          : [],
    );
  }
}
