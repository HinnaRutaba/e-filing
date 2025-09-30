import 'package:efiling_balochistan/config/network/network_base.dart';

class UserSchema {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String userTitle = 'user_title';
  static const String username = 'username';
  static const String password = 'password';
  static const String email = 'email';
  static const String emailVerifiedAt = 'email_verified_at';
  static const String sign = 'sign';
  static const String signature = 'signature';
  static const String status = 'status';
  static const String roleId = 'role_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String designation = 'designation';
  static const String designations = 'designations';
  static const String allDesignations = 'all_designations';
  static const String section = 'section';
}

class UserModel {
  int? id;
  String? userTitle;
  String? username;
  String? email;
  String? emailVerifiedAt;
  String? designation;
  String? section;
  String? sign;
  int? status;
  int? roleId;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<DesignationModel> designations;
  DesignationModel? currentDesignation;

  UserModel({
    this.id,
    this.userTitle,
    this.username,
    this.email,
    this.emailVerifiedAt,
    this.sign,
    this.status,
    this.roleId,
    this.createdAt,
    this.updatedAt,
    this.designation,
    this.section,
    this.designations = const [],
    this.currentDesignation,
  });

  String get signature {
    return "${NetworkBase.base}/$sign";
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json[UserSchema.id] ?? json[UserSchema.userId]) as int?,
      userTitle: json[UserSchema.userTitle] as String?,
      username: json[UserSchema.username] as String?,
      email: json[UserSchema.email] as String?,
      emailVerifiedAt: json[UserSchema.emailVerifiedAt] as String?,
      sign: (json[UserSchema.sign] ?? json[UserSchema.signature]) as String?,
      status: json[UserSchema.status] as int?,
      roleId: json[UserSchema.roleId] as int?,
      createdAt: json[UserSchema.createdAt] != null
          ? DateTime.tryParse(json[UserSchema.createdAt] as String)
          : null,
      updatedAt: json[UserSchema.updatedAt] != null
          ? DateTime.tryParse(json[UserSchema.updatedAt] as String)
          : null,
      designation: json[UserSchema.designation] as String?,
      section: json[UserSchema.section] as String?,
      designations: ((json[UserSchema.designations] ??
                  json[UserSchema.allDesignations]) as List<dynamic>?)
              ?.map((e) => DesignationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      UserSchema.id: id,
      UserSchema.userTitle: userTitle,
      UserSchema.username: username,
      UserSchema.email: email,
      UserSchema.emailVerifiedAt: emailVerifiedAt,
      UserSchema.sign: sign,
      UserSchema.status: status,
      UserSchema.roleId: roleId,
      UserSchema.createdAt: createdAt.toString(),
      UserSchema.updatedAt: updatedAt.toString(),
    };
  }

  UserModel copyWith({
    int? id,
    String? userTitle,
    String? username,
    String? email,
    String? emailVerifiedAt,
    String? sign,
    int? status,
    int? roleId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? designation,
    String? section,
    List<DesignationModel>? designations,
    DesignationModel? currentDesignation,
  }) {
    return UserModel(
      id: id ?? this.id,
      userTitle: userTitle ?? this.userTitle,
      username: username ?? this.username,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      sign: sign ?? this.sign,
      status: status ?? this.status,
      roleId: roleId ?? this.roleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      designation: designation ?? this.designation,
      section: section ?? this.section,
      designations: designations ?? this.designations,
      currentDesignation: currentDesignation ?? this.currentDesignation,
    );
  }

  UserModel copyWhole(UserModel? user) {
    return UserModel(
      id: user?.id ?? id,
      userTitle: user?.userTitle ?? userTitle,
      username: (user ?? this).username,
      email: (user ?? this).email,
      emailVerifiedAt: (user ?? this).emailVerifiedAt,
      sign: (user ?? this).sign,
      status: (user ?? this).status,
      roleId: (user ?? this).roleId,
      createdAt: (user ?? this).createdAt,
      updatedAt: (user ?? this).updatedAt,
      designation: (user ?? this).designation,
      section: (user ?? this).section,
      designations: (user ?? this).designations,
      currentDesignation: (user ?? this).currentDesignation,
    );
  }
}

class DesignationSchema {
  static const String userDesgId = "user_desg_id";
  static const String designation = "designation";
  static const String section = "section";
  static const String department = "department";
  static const String prefix = "prefix";
}

class DesignationModel {
  final int? userDesgId;
  final String? designation;
  final String? section;
  final String? department;
  final String? prefix;

  DesignationModel({
    this.userDesgId,
    this.designation,
    this.section,
    this.department,
    this.prefix,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      userDesgId: json[DesignationSchema.userDesgId] as int?,
      designation: json[DesignationSchema.designation] as String?,
      section: json[DesignationSchema.section] as String?,
      department: json[DesignationSchema.department] as String?,
      prefix: json[DesignationSchema.prefix] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DesignationSchema.userDesgId: userDesgId,
      DesignationSchema.designation: designation,
      DesignationSchema.section: section,
      DesignationSchema.department: department,
      DesignationSchema.prefix: prefix,
    };
  }

  DesignationModel copyWith({
    int? userDesgId,
    String? designation,
    String? section,
    String? department,
    String? prefix,
  }) {
    return DesignationModel(
      userDesgId: userDesgId ?? this.userDesgId,
      designation: designation ?? this.designation,
      section: section ?? this.section,
      department: department ?? this.department,
      prefix: prefix ?? this.prefix,
    );
  }
}
