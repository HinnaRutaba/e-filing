class DepartmentModel {
  final int? id;
  final String? title;

  DepartmentModel({
    this.id,
    this.title,
  });

  DepartmentModel copyWith({
    int? id,
    String? title,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DepartmentSchema.id: id,
      DepartmentSchema.title: title,
    };
  }

  factory DepartmentModel.fromJson(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map[DepartmentSchema.id]?.toInt(),
      title: map[DepartmentSchema.title],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DepartmentModel && other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}

class DepartmentSchema {
  static const String id = 'id';
  static const String title = 'title';
}
