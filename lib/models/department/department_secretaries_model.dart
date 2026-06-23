class DepartmentSecretariesModel {
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

  DepartmentSecretariesModel({
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

  DepartmentSecretariesModel copyWith({
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
    return DepartmentSecretariesModel(
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
      DepartmentSecretariesSchema.id: id,
      DepartmentSecretariesSchema.userDesgId: userDesgId,
      DepartmentSecretariesSchema.userId: userId,
      DepartmentSecretariesSchema.designationId: designationId,
      DepartmentSecretariesSchema.sectionId: sectionId,
      DepartmentSecretariesSchema.name: name,
      DepartmentSecretariesSchema.designation: designation,
      DepartmentSecretariesSchema.section: section,
      DepartmentSecretariesSchema.role: role,
      DepartmentSecretariesSchema.roleId: roleId,
    };
  }

  factory DepartmentSecretariesModel.fromJson(Map<String, dynamic> map) {
    return DepartmentSecretariesModel(
      id: map[DepartmentSecretariesSchema.id]?.toInt(),
      userDesgId: map[DepartmentSecretariesSchema.userDesgId]?.toInt(),
      userId: map[DepartmentSecretariesSchema.userId]?.toInt(),
      designationId: map[DepartmentSecretariesSchema.designationId]?.toInt(),
      sectionId: map[DepartmentSecretariesSchema.sectionId]?.toInt(),
      name: map[DepartmentSecretariesSchema.name],
      designation: map[DepartmentSecretariesSchema.designation],
      section: map[DepartmentSecretariesSchema.section],
      role: map[DepartmentSecretariesSchema.role],
      roleId: map[DepartmentSecretariesSchema.roleId]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DepartmentSecretariesModel &&
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
  int get hashCode =>
      id.hashCode ^
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

class DepartmentSecretariesSchema {
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
