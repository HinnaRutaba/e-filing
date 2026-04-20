class SummaryPermissionsModel {
  final bool? canCreate;
  final bool? canSecretaryInbox;
  final bool? canInternalView;
  final bool? canInternalRemarks;

  SummaryPermissionsModel({
    this.canCreate,
    this.canSecretaryInbox,
    this.canInternalView,
    this.canInternalRemarks,
  });

  SummaryPermissionsModel copyWith({
    bool? canCreate,
    bool? canSecretaryInbox,
    bool? canInternalView,
    bool? canInternalRemarks,
  }) {
    return SummaryPermissionsModel(
      canCreate: canCreate ?? this.canCreate,
      canSecretaryInbox: canSecretaryInbox ?? this.canSecretaryInbox,
      canInternalView: canInternalView ?? this.canInternalView,
      canInternalRemarks: canInternalRemarks ?? this.canInternalRemarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryPermissionsSchema.canCreate: canCreate,
      SummaryPermissionsSchema.canSecretaryInbox: canSecretaryInbox,
      SummaryPermissionsSchema.canInternalView: canInternalView,
      SummaryPermissionsSchema.canInternalRemarks: canInternalRemarks,
    };
  }

  factory SummaryPermissionsModel.fromJson(Map<String, dynamic> map) {
    return SummaryPermissionsModel(
      canCreate: map[SummaryPermissionsSchema.canCreate],
      canSecretaryInbox: map[SummaryPermissionsSchema.canSecretaryInbox],
      canInternalView: map[SummaryPermissionsSchema.canInternalView],
      canInternalRemarks: map[SummaryPermissionsSchema.canInternalRemarks],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryPermissionsModel &&
        other.canCreate == canCreate &&
        other.canSecretaryInbox == canSecretaryInbox &&
        other.canInternalView == canInternalView &&
        other.canInternalRemarks == canInternalRemarks;
  }

  @override
  int get hashCode {
    return canCreate.hashCode ^
        canSecretaryInbox.hashCode ^
        canInternalView.hashCode ^
        canInternalRemarks.hashCode;
  }
}

class SummaryPermissionsSchema {
  static const String canCreate = 'can_create';
  static const String canSecretaryInbox = 'can_secretary_inbox';
  static const String canInternalView = 'can_internal_view';
  static const String canInternalRemarks = 'can_internal_remarks';
}
