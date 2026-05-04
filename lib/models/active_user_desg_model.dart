class ActiveUserDesg {
  final int? id;
  final String? name;
  final String? designation;
  final String? section;
  final String? department;
  final String? role;
  final ActiveUserDesgRole? roleEnum;

  ActiveUserDesg({
    this.id,
    this.name,
    this.designation,
    this.section,
    this.department,
    this.role,
    this.roleEnum,
  });

  factory ActiveUserDesg.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ActiveUserDesg();
    return ActiveUserDesg(
      id: json['id'],
      name: json['name'],
      designation: json['designation'],
      section: json['section'],
      department: json['department'],
      role: json['role'],
      roleEnum: json['role'] != null
          ? ActiveUserDesgRole.fromLabel(json['role'])
          : null,
    );
  }
}

enum ActiveUserDesgRole {
  admin('admin', 1),
  deo('deo', 2),
  keeper('keeper', 3),
  cm('cm', 4),
  secretary('secretary', 5),
  pstocm('pstocm', 6);

  final String label;
  final int value;
  const ActiveUserDesgRole(this.label, this.value);

  static ActiveUserDesgRole? fromValue(int value) {
    return ActiveUserDesgRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActiveUserDesgRole.deo,
    );
  }

  static ActiveUserDesgRole? fromLabel(String label) {
    return ActiveUserDesgRole.values.firstWhere(
      (e) => e.label == label,
      orElse: () => ActiveUserDesgRole.deo,
    );
  }
}
