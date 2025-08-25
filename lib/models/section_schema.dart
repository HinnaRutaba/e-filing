// ================= SCHEMA =================
class SectionSchema {
  static const String id = "id";
  static const String title = "title";
}

// ================= MODEL =================
class SectionModel {
  final int? id;
  final String? title;

  SectionModel({
    this.id,
    this.title,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json[SectionSchema.id] as int?,
      title: json[SectionSchema.title] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SectionSchema.id: id,
      SectionSchema.title: title,
    };
  }

  SectionModel copyWith({
    int? id,
    String? title,
  }) {
    return SectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}
