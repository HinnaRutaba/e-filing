import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/daak/daak_meta_model.dart';
import 'package:efiling_balochistan/models/department/department_model.dart';

class DaakDepartmentsModel {
  final int? otherDepartmentId;
  final List<DepartmentModel>? departments;
  final List<DepartmentUser>? departmentUsers;
  final ActiveUserDesg? activeUserDesg;

  DaakDepartmentsModel({
    this.otherDepartmentId,
    this.departments,
    this.departmentUsers,
    this.activeUserDesg,
  });

  factory DaakDepartmentsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DaakDepartmentsModel();
    return DaakDepartmentsModel(
      otherDepartmentId:
          json[DaakDepartmentsSchema.otherDepartmentId]?.toInt(),
      departments: json[DaakDepartmentsSchema.departments] != null
          ? (json[DaakDepartmentsSchema.departments] as List)
                .map((i) => DepartmentModel.fromJson(i))
                .toList()
          : null,
      departmentUsers: json[DaakDepartmentsSchema.departmentUsers] != null
          ? (json[DaakDepartmentsSchema.departmentUsers] as List)
                .map((i) => DepartmentUser.fromJson(i))
                .toList()
          : null,
      activeUserDesg: json[DaakDepartmentsSchema.activeUserDesg] != null
          ? ActiveUserDesg.fromJson(json[DaakDepartmentsSchema.activeUserDesg])
          : null,
    );
  }
}

class DaakDepartmentsSchema {
  static const String otherDepartmentId = 'other_department_id';
  static const String departments = 'departments';
  static const String departmentUsers = 'department_users';
  static const String activeUserDesg = 'active_user_desg';
}
