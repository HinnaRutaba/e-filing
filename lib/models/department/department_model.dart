class DepartmentModel {
  final int? id;
  final String? title;
  final bool? isOther;

  DepartmentModel({
    this.id,
    this.title,
    this.isOther,
  });

  DepartmentModel copyWith({
    int? id,
    String? title,
    bool? isOther,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isOther: isOther ?? this.isOther,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DepartmentSchema.id: id,
      DepartmentSchema.title: title,
      DepartmentSchema.isOther: isOther,
    };
  }

  factory DepartmentModel.fromJson(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map[DepartmentSchema.id]?.toInt(),
      title: map[DepartmentSchema.title],
      isOther: map[DepartmentSchema.isOther],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DepartmentModel &&
        other.id == id &&
        other.title == title &&
        other.isOther == isOther;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ isOther.hashCode;
}

class DepartmentSchema {
  static const String id = 'id';
  static const String title = 'title';
  static const String isOther = 'is_other';
}
