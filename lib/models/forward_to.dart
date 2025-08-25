// ================= SCHEMA =================
class ForwardToSchema {
  static const String userDesgId = "user_desg_id";
  static const String userId = "user_id";
  static const String userTitle = "user_title";
  static const String designationId = "designation_id";
  static const String designationTitle = "designation_title";
}

// ================= MODEL =================
class ForwardToModel {
  final int? userDesgId;
  final int? userId;
  final String? userTitle;
  final int? designationId;
  final String? designationTitle;

  ForwardToModel({
    this.userDesgId,
    this.userId,
    this.userTitle,
    this.designationId,
    this.designationTitle,
  });

  factory ForwardToModel.fromJson(Map<String, dynamic> json) {
    return ForwardToModel(
      userDesgId: json[ForwardToSchema.userDesgId] as int?,
      userId: json[ForwardToSchema.userId] as int?,
      userTitle: json[ForwardToSchema.userTitle] as String?,
      designationId: json[ForwardToSchema.designationId] as int?,
      designationTitle: json[ForwardToSchema.designationTitle] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ForwardToSchema.userDesgId: userDesgId,
      ForwardToSchema.userId: userId,
      ForwardToSchema.userTitle: userTitle,
      ForwardToSchema.designationId: designationId,
      ForwardToSchema.designationTitle: designationTitle,
    };
  }

  ForwardToModel copyWith({
    int? userDesgId,
    int? userId,
    String? userTitle,
    int? designationId,
    String? designationTitle,
  }) {
    return ForwardToModel(
      userDesgId: userDesgId ?? this.userDesgId,
      userId: userId ?? this.userId,
      userTitle: userTitle ?? this.userTitle,
      designationId: designationId ?? this.designationId,
      designationTitle: designationTitle ?? this.designationTitle,
    );
  }
}
