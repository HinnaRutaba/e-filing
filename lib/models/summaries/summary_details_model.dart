import 'package:efiling_balochistan/models/attachment_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_actions_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_brief_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_internal_forward_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_local_link_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_movement_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_remark_track_model.dart';

class SummaryDetailsModel {
  final SummaryModel? summary;
  final List<SummaryMovementModel> movements;
  final List<AttachmentModel> attachments;
  final List<SummaryInternalForwardModel> internalForwards;
  final List<SummaryLocalLinkModel> localLinks;
  final List<SummaryBriefModel> briefs;
  final List<dynamic> voiceNotes;
  final List<SummaryRemarkTrackModel> remarkTrack;
  final SummaryActionsModel? actions;

  SummaryDetailsModel({
    this.summary,
    this.movements = const [],
    this.attachments = const [],
    this.internalForwards = const [],
    this.localLinks = const [],
    this.briefs = const [],
    this.voiceNotes = const [],
    this.remarkTrack = const [],
    this.actions,
  });

  SummaryDetailsModel copyWith({
    SummaryModel? summary,
    List<SummaryMovementModel>? movements,
    List<AttachmentModel>? attachments,
    List<SummaryInternalForwardModel>? internalForwards,
    List<SummaryLocalLinkModel>? localLinks,
    List<SummaryBriefModel>? briefs,
    List<dynamic>? voiceNotes,
    List<SummaryRemarkTrackModel>? remarkTrack,
    SummaryActionsModel? actions,
  }) {
    return SummaryDetailsModel(
      summary: summary ?? this.summary,
      movements: movements ?? this.movements,
      attachments: attachments ?? this.attachments,
      internalForwards: internalForwards ?? this.internalForwards,
      localLinks: localLinks ?? this.localLinks,
      briefs: briefs ?? this.briefs,
      voiceNotes: voiceNotes ?? this.voiceNotes,
      remarkTrack: remarkTrack ?? this.remarkTrack,
      actions: actions ?? this.actions,
    );
  }

  SummaryMovementModel? get latestMovement =>
      movements.isNotEmpty ? movements.last : null;

  bool get hasForwardedBefore =>
      movements.any((m) => m.actionType == 'signed_and_forwarded') == true;

  bool get isLatestMovementSignedAndForwarded =>
      movements.isNotEmpty &&
      movements.last.actionType == 'signed_and_forwarded';

  bool get isLatestRemarksAdded =>
      movements.isNotEmpty && movements.last.actionType == 'remarks_added';

  List<String> get supportingFlagNames => attachments
      .where((a) => a.isSupporting)
      .map((a) => a.flagName)
      .whereType<String>()
      .toList();

  Map<String, dynamic> toJson() {
    return {
      SummaryDetailsSchema.summary: summary?.toJson(),
      SummaryDetailsSchema.movements: movements.map((e) => e.toJson()).toList(),
      SummaryDetailsSchema.attachments: attachments
          .map((e) => e.toJson())
          .toList(),
      SummaryDetailsSchema.internalForwards: internalForwards
          .map((e) => e.toJson())
          .toList(),
      SummaryDetailsSchema.localLinks: localLinks
          .map((e) => e.toJson())
          .toList(),
      SummaryDetailsSchema.briefs: briefs.map((e) => e.toJson()).toList(),
      SummaryDetailsSchema.voiceNotes: voiceNotes,
      SummaryDetailsSchema.remarkTrack: remarkTrack
          .map((e) => e.toJson())
          .toList(),
      SummaryDetailsSchema.actions: actions?.toJson(),
    };
  }

  factory SummaryDetailsModel.fromJson(Map<String, dynamic> map) {
    return SummaryDetailsModel(
      summary: map[SummaryDetailsSchema.summary] != null
          ? SummaryModel.fromJson(
              Map<String, dynamic>.from(map[SummaryDetailsSchema.summary]),
            )
          : null,
      movements: map[SummaryDetailsSchema.movements] != null
          ? (map[SummaryDetailsSchema.movements] as List)
                .map(
                  (e) => SummaryMovementModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      attachments: map[SummaryDetailsSchema.attachments] != null
          ? (map[SummaryDetailsSchema.attachments] as List)
                .map(
                  (e) => AttachmentModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      internalForwards: map[SummaryDetailsSchema.internalForwards] != null
          ? (map[SummaryDetailsSchema.internalForwards] as List)
                .map(
                  (e) => SummaryInternalForwardModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      localLinks: map[SummaryDetailsSchema.localLinks] != null
          ? (map[SummaryDetailsSchema.localLinks] as List)
                .map(
                  (e) => SummaryLocalLinkModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      briefs: map[SummaryDetailsSchema.briefs] != null
          ? (map[SummaryDetailsSchema.briefs] as List)
                .map(
                  (e) =>
                      SummaryBriefModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      voiceNotes: map[SummaryDetailsSchema.voiceNotes] != null
          ? List<dynamic>.from(map[SummaryDetailsSchema.voiceNotes] as List)
          : const [],
      remarkTrack: map[SummaryDetailsSchema.remarkTrack] != null
          ? (map[SummaryDetailsSchema.remarkTrack] as List)
                .map(
                  (e) => SummaryRemarkTrackModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      actions: map[SummaryDetailsSchema.actions] != null
          ? SummaryActionsModel.fromJson(
              Map<String, dynamic>.from(map[SummaryDetailsSchema.actions]),
            )
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryDetailsModel &&
        other.summary == summary &&
        other.actions == actions;
  }

  @override
  int get hashCode => summary.hashCode ^ actions.hashCode;
}

class SummaryDetailsSchema {
  static const String summary = 'summary';
  static const String movements = 'movements';
  static const String attachments = 'attachments';
  static const String internalForwards = 'internal_forwards';
  static const String localLinks = 'local_links';
  static const String briefs = 'briefs';
  static const String voiceNotes = 'voice_notes';
  static const String remarkTrack = 'remarks_track';
  static const String actions = 'actions';
}
