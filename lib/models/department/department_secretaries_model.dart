class DepartmentSecretariesModel {
  final int? id;
  final String? name;
  final String? designation;

  DepartmentSecretariesModel({
    this.id,
    this.name,
    this.designation,
  });

  DepartmentSecretariesModel copyWith({
    int? id,
    String? name,
    String? designation,
  }) {
    return DepartmentSecretariesModel(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DepartmentSecretariesSchema.id: id,
      DepartmentSecretariesSchema.name: name,
      DepartmentSecretariesSchema.designation: designation,
    };
  }

  factory DepartmentSecretariesModel.fromJson(Map<String, dynamic> map) {
    return DepartmentSecretariesModel(
      id: map[DepartmentSecretariesSchema.id]?.toInt(),
      name: map[DepartmentSecretariesSchema.name],
      designation: map[DepartmentSecretariesSchema.designation],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DepartmentSecretariesModel &&
        other.id == id &&
        other.name == name &&
        other.designation == designation;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ designation.hashCode;
}

class DepartmentSecretariesSchema {
  static const String id = 'id';
  static const String name = 'name';
  static const String designation = 'designation';
}
