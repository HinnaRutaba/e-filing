class SummaryActionsModel {
  final bool? canForwardExternal;
  final bool? canShareInternally;
  final bool? canReturnToSection;
  final bool? canUpdateDraftContent;
  final bool? canEditDraft;
  final bool? canForwardToCm;
  final bool? canCmSignAndReturn;
  final bool? canForwardPsToSec;
  final bool? canDispose;
  final bool? canSendForDisposal;
  final bool? canSubmitRemarks;
  final bool? isDraftReturned;
  final bool? isPostCmForward;
  final bool? isPsHolder;
  final bool? isCmHolder;
  final bool? isPstocmHolder;
  final bool? isDisposed;
  final int? myInternalForwardId;
  final String? returnRemarks;

  SummaryActionsModel({
    this.canForwardExternal,
    this.canShareInternally,
    this.canReturnToSection,
    this.canUpdateDraftContent,
    this.canEditDraft,
    this.canForwardToCm,
    this.canCmSignAndReturn,
    this.canForwardPsToSec,
    this.canDispose,
    this.canSendForDisposal,
    this.canSubmitRemarks,
    this.isDraftReturned,
    this.isPostCmForward,
    this.isPsHolder,
    this.isCmHolder,
    this.isPstocmHolder,
    this.isDisposed,
    this.myInternalForwardId,
    this.returnRemarks,
  });

  SummaryActionsModel copyWith({
    bool? canForwardExternal,
    bool? canShareInternally,
    bool? canReturnToSection,
    bool? canUpdateDraftContent,
    bool? canEditDraft,
    bool? canForwardToCm,
    bool? canCmSignAndReturn,
    bool? canForwardPsToSec,
    bool? canDispose,
    bool? canSendForDisposal,
    bool? canSubmitRemarks,
    bool? isDraftReturned,
    bool? isPostCmForward,
    bool? isPsHolder,
    bool? isCmHolder,
    bool? isPstocmHolder,
    bool? isDisposed,
    int? myInternalForwardId,
    String? returnRemarks,
  }) {
    return SummaryActionsModel(
      canForwardExternal: canForwardExternal ?? this.canForwardExternal,
      canShareInternally: canShareInternally ?? this.canShareInternally,
      canReturnToSection: canReturnToSection ?? this.canReturnToSection,
      canUpdateDraftContent:
          canUpdateDraftContent ?? this.canUpdateDraftContent,
      canEditDraft: canEditDraft ?? this.canEditDraft,
      canForwardToCm: canForwardToCm ?? this.canForwardToCm,
      canCmSignAndReturn: canCmSignAndReturn ?? this.canCmSignAndReturn,
      canForwardPsToSec: canForwardPsToSec ?? this.canForwardPsToSec,
      canDispose: canDispose ?? this.canDispose,
      canSendForDisposal: canSendForDisposal ?? this.canSendForDisposal,
      canSubmitRemarks: canSubmitRemarks ?? this.canSubmitRemarks,
      isDraftReturned: isDraftReturned ?? this.isDraftReturned,
      isPostCmForward: isPostCmForward ?? this.isPostCmForward,
      isPsHolder: isPsHolder ?? this.isPsHolder,
      isCmHolder: isCmHolder ?? this.isCmHolder,
      isPstocmHolder: isPstocmHolder ?? this.isPstocmHolder,
      isDisposed: isDisposed ?? this.isDisposed,
      myInternalForwardId: myInternalForwardId ?? this.myInternalForwardId,
      returnRemarks: returnRemarks ?? this.returnRemarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryActionsSchema.canForwardExternal: canForwardExternal,
      SummaryActionsSchema.canShareInternally: canShareInternally,
      SummaryActionsSchema.canReturnToSection: canReturnToSection,
      SummaryActionsSchema.canUpdateDraftContent: canUpdateDraftContent,
      SummaryActionsSchema.canEditDraft: canEditDraft,
      SummaryActionsSchema.canForwardToCm: canForwardToCm,
      SummaryActionsSchema.canCmSignAndReturn: canCmSignAndReturn,
      SummaryActionsSchema.canForwardPsToSec: canForwardPsToSec,
      SummaryActionsSchema.canDispose: canDispose,
      SummaryActionsSchema.canSendForDisposal: canSendForDisposal,
      SummaryActionsSchema.canSubmitRemarks: canSubmitRemarks,
      SummaryActionsSchema.isDraftReturned: isDraftReturned,
      SummaryActionsSchema.isPostCmForward: isPostCmForward,
      SummaryActionsSchema.isPsHolder: isPsHolder,
      SummaryActionsSchema.isCmHolder: isCmHolder,
      SummaryActionsSchema.isPstocmHolder: isPstocmHolder,
      SummaryActionsSchema.isDisposed: isDisposed,
      SummaryActionsSchema.myInternalForwardId: myInternalForwardId,
      SummaryActionsSchema.returnRemarks: returnRemarks,
    };
  }

  factory SummaryActionsModel.fromJson(Map<String, dynamic> map) {
    return SummaryActionsModel(
      canForwardExternal: map[SummaryActionsSchema.canForwardExternal],
      canShareInternally: map[SummaryActionsSchema.canShareInternally],
      canReturnToSection: map[SummaryActionsSchema.canReturnToSection],
      canUpdateDraftContent: map[SummaryActionsSchema.canUpdateDraftContent],
      canEditDraft: map[SummaryActionsSchema.canEditDraft],
      canForwardToCm: map[SummaryActionsSchema.canForwardToCm],
      canCmSignAndReturn: map[SummaryActionsSchema.canCmSignAndReturn],
      canForwardPsToSec: map[SummaryActionsSchema.canForwardPsToSec],
      canDispose: map[SummaryActionsSchema.canDispose],
      canSendForDisposal: map[SummaryActionsSchema.canSendForDisposal],
      canSubmitRemarks: map[SummaryActionsSchema.canSubmitRemarks],
      isDraftReturned: map[SummaryActionsSchema.isDraftReturned],
      isPostCmForward: map[SummaryActionsSchema.isPostCmForward],
      isPsHolder: map[SummaryActionsSchema.isPsHolder],
      isCmHolder: map[SummaryActionsSchema.isCmHolder],
      isPstocmHolder: map[SummaryActionsSchema.isPstocmHolder],
      isDisposed: map[SummaryActionsSchema.isDisposed],
      myInternalForwardId:
          map[SummaryActionsSchema.myInternalForwardId]?.toInt(),
      returnRemarks: map[SummaryActionsSchema.returnRemarks],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryActionsModel &&
        other.canForwardExternal == canForwardExternal &&
        other.canShareInternally == canShareInternally &&
        other.canReturnToSection == canReturnToSection &&
        other.canUpdateDraftContent == canUpdateDraftContent &&
        other.canEditDraft == canEditDraft &&
        other.canForwardToCm == canForwardToCm &&
        other.canCmSignAndReturn == canCmSignAndReturn &&
        other.canForwardPsToSec == canForwardPsToSec &&
        other.canDispose == canDispose &&
        other.canSendForDisposal == canSendForDisposal &&
        other.canSubmitRemarks == canSubmitRemarks &&
        other.isDraftReturned == isDraftReturned &&
        other.isPostCmForward == isPostCmForward &&
        other.isPsHolder == isPsHolder &&
        other.isCmHolder == isCmHolder &&
        other.isPstocmHolder == isPstocmHolder &&
        other.isDisposed == isDisposed &&
        other.myInternalForwardId == myInternalForwardId &&
        other.returnRemarks == returnRemarks;
  }

  @override
  int get hashCode {
    return canForwardExternal.hashCode ^
        canShareInternally.hashCode ^
        canReturnToSection.hashCode ^
        canUpdateDraftContent.hashCode ^
        canEditDraft.hashCode ^
        canForwardToCm.hashCode ^
        canCmSignAndReturn.hashCode ^
        canForwardPsToSec.hashCode ^
        canDispose.hashCode ^
        canSendForDisposal.hashCode ^
        canSubmitRemarks.hashCode ^
        isDraftReturned.hashCode ^
        isPostCmForward.hashCode ^
        isPsHolder.hashCode ^
        isCmHolder.hashCode ^
        isPstocmHolder.hashCode ^
        isDisposed.hashCode ^
        myInternalForwardId.hashCode ^
        returnRemarks.hashCode;
  }
}

class SummaryActionsSchema {
  static const String canForwardExternal = 'can_forward_external';
  static const String canShareInternally = 'can_share_internally';
  static const String canReturnToSection = 'can_return_to_section';
  static const String canUpdateDraftContent = 'can_update_draft_content';
  static const String canEditDraft = 'can_edit_draft';
  static const String canForwardToCm = 'can_forward_to_cm';
  static const String canCmSignAndReturn = 'can_cm_sign_and_return';
  static const String canForwardPsToSec = 'can_forward_ps_to_sec';
  static const String canDispose = 'can_dispose';
  static const String canSendForDisposal = 'can_send_for_disposal';
  static const String canSubmitRemarks = 'can_submit_remarks';
  static const String isDraftReturned = 'is_draft_returned';
  static const String isPostCmForward = 'is_post_cm_forward';
  static const String isPsHolder = 'is_ps_holder';
  static const String isCmHolder = 'is_cm_holder';
  static const String isPstocmHolder = 'is_pstocm_holder';
  static const String isDisposed = 'is_disposed';
  static const String myInternalForwardId = 'my_internal_forward_id';
  static const String returnRemarks = 'return_remarks';
}
