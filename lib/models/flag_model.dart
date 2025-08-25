class FlagSchema {
  static const String id = "id";
  static const String title = "title";
}

class FlagModel {
  final int? id;
  final String? title;

  FlagModel({
    this.id,
    this.title,
  });

  factory FlagModel.fromJson(Map<String, dynamic> json) {
    return FlagModel(
      id: json[FlagSchema.id] as int?,
      title: json[FlagSchema.title] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FlagSchema.id: id,
      FlagSchema.title: title,
    };
  }

  FlagModel copyWith({
    int? id,
    String? title,
  }) {
    return FlagModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}
