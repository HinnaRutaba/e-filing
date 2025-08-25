import 'package:efiling_balochistan/config/network/network_base.dart';

class UserSchema {
  static const String id = 'id';
  static const String userTitle = 'user_title';
  static const String username = 'username';
  static const String password = 'password';
  static const String email = 'email';
  static const String emailVerifiedAt = 'email_verified_at';
  static const String sign = 'sign';
  static const String status = 'status';
  static const String roleId = 'role_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class UserModel {
  int? id;
  String? userTitle;
  String? username;
  String? email;
  String? emailVerifiedAt;
  String? sign;
  int? status;
  int? roleId;
  DateTime? createdAt;
  DateTime? updatedAt;

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
  });

  String get signature {
    return "${NetworkBase.base}/$sign";
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[UserSchema.id] as int?,
      userTitle: json[UserSchema.userTitle] as String?,
      username: json[UserSchema.username] as String?,
      email: json[UserSchema.email] as String?,
      emailVerifiedAt: json[UserSchema.emailVerifiedAt] as String?,
      sign: json[UserSchema.sign] as String?,
      status: json[UserSchema.status] as int?,
      roleId: json[UserSchema.roleId] as int?,
      createdAt: json[UserSchema.createdAt] != null
          ? DateTime.tryParse(json[UserSchema.createdAt] as String)
          : null,
      updatedAt: json[UserSchema.updatedAt] != null
          ? DateTime.tryParse(json[UserSchema.updatedAt] as String)
          : null,
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
}
