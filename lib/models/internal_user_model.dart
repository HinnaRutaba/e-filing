class InternalUserModel {
  final int? id;
  final int? userDesgId;
  final int? userId;
  final int? designationId;
  final int? sectionId;
  final String? name;
  final String? designation;
  final String? section;
  final String? role;
  final int? roleId;

  InternalUserModel({
    this.id,
    this.userDesgId,
    this.userId,
    this.designationId,
    this.sectionId,
    this.name,
    this.designation,
    this.section,
    this.role,
    this.roleId,
  });

  InternalUserModel copyWith({
    int? id,
    int? userDesgId,
    int? userId,
    int? designationId,
    int? sectionId,
    String? name,
    String? designation,
    String? section,
    String? role,
    int? roleId,
  }) {
    return InternalUserModel(
      id: id ?? this.id,
      userDesgId: userDesgId ?? this.userDesgId,
      userId: userId ?? this.userId,
      designationId: designationId ?? this.designationId,
      sectionId: sectionId ?? this.sectionId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      section: section ?? this.section,
      role: role ?? this.role,
      roleId: roleId ?? this.roleId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      InternalUserSchema.id: id,
      InternalUserSchema.userDesgId: userDesgId,
      InternalUserSchema.userId: userId,
      InternalUserSchema.designationId: designationId,
      InternalUserSchema.sectionId: sectionId,
      InternalUserSchema.name: name,
      InternalUserSchema.designation: designation,
      InternalUserSchema.section: section,
      InternalUserSchema.role: role,
      InternalUserSchema.roleId: roleId,
    };
  }

  factory InternalUserModel.fromJson(Map<String, dynamic> map) {
    return InternalUserModel(
      id: map[InternalUserSchema.id]?.toInt(),
      userDesgId: map[InternalUserSchema.userDesgId]?.toInt(),
      userId: map[InternalUserSchema.userId]?.toInt(),
      designationId: map[InternalUserSchema.designationId]?.toInt(),
      sectionId: map[InternalUserSchema.sectionId]?.toInt(),
      name: map[InternalUserSchema.name],
      designation: map[InternalUserSchema.designation],
      section: map[InternalUserSchema.section],
      role: map[InternalUserSchema.role],
      roleId: map[InternalUserSchema.roleId]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InternalUserModel &&
        other.id == id &&
        other.userDesgId == userDesgId &&
        other.userId == userId &&
        other.designationId == designationId &&
        other.sectionId == sectionId &&
        other.name == name &&
        other.designation == designation &&
        other.section == section &&
        other.role == role &&
        other.roleId == roleId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userDesgId.hashCode ^
        userId.hashCode ^
        designationId.hashCode ^
        sectionId.hashCode ^
        name.hashCode ^
        designation.hashCode ^
        section.hashCode ^
        role.hashCode ^
        roleId.hashCode;
  }
}

class InternalUserSchema {
  static const String id = 'id';
  static const String userDesgId = 'user_desg_id';
  static const String userId = 'user_id';
  static const String designationId = 'designation_id';
  static const String sectionId = 'section_id';
  static const String name = 'name';
  static const String designation = 'designation';
  static const String section = 'section';
  static const String role = 'role';
  static const String roleId = 'role_id';
}
