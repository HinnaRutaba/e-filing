import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/department/department_secretaries_model.dart';
import 'package:efiling_balochistan/models/summaries/create_summary_model.dart';
import 'package:efiling_balochistan/models/summaries/draft_remarks_model.dart';
import 'package:efiling_balochistan/models/summaries/summaries_meta_model.dart';
import 'package:efiling_balochistan/models/summaries/sign_forward_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_daak_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_file_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_voice_note_model.dart';
import 'package:efiling_balochistan/models/summaries/voice_note_upload_model.dart';
import 'package:efiling_balochistan/repository/summaries/summaries_repo.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

enum SummaryMainTab {
  actionRequired('Action Required', Icons.notifications_none_rounded),
  sentTracked('Sent & Tracked', Icons.check_circle_outline_rounded),
  archive('Archive', Icons.archive_outlined, apiValue: 'disposed');

  final String label;
  final IconData icon;
  final String? apiValue;
  const SummaryMainTab(this.label, this.icon, {this.apiValue});
}

enum SummarySubTab {
  inbox,
  sharedToMe,
  drafts,
  disposal,
  sentOut,
  sharedInternally,
}

class SummaryTabConfig {
  final String label;
  final SummaryMainTab parent;
  final String filterName;
  const SummaryTabConfig({
    required this.label,
    required this.parent,
    required this.filterName,
  });
}

extension SummarySubTabX on SummarySubTab {
  SummaryTabConfig configFor(ActiveUserDesgRole? role) {
    switch (this) {
      case SummarySubTab.inbox:
        return const SummaryTabConfig(
          label: 'Inbox',
          parent: SummaryMainTab.actionRequired,
          filterName: 'inbox',
        );
      case SummarySubTab.sharedToMe:
        return const SummaryTabConfig(
          label: 'Shared to me',
          parent: SummaryMainTab.actionRequired,
          filterName: 'internal',
        );
      case SummarySubTab.drafts:
        return SummaryTabConfig(
          label: 'Drafts',
          parent: SummaryMainTab.actionRequired,
          filterName: role == ActiveUserDesgRole.deo ? 'my_drafts' : 'draft',
        );
      case SummarySubTab.disposal:
        return const SummaryTabConfig(
          label: 'Disposal',
          parent: SummaryMainTab.actionRequired,
          filterName: 'pending_disposal',
        );
      case SummarySubTab.sentOut:
        return const SummaryTabConfig(
          label: 'Sent Out',
          parent: SummaryMainTab.sentTracked,
          filterName: 'sent',
        );
      case SummarySubTab.sharedInternally:
        return const SummaryTabConfig(
          label: 'Shared Internally',
          parent: SummaryMainTab.sentTracked,
          filterName: 'internal_forwarded',
        );
    }
  }
}

List<SummarySubTab> subTabsForRole(ActiveUserDesgRole? role) {
  return SummarySubTab.values;
}

class SummariesState {
  final List<SummaryModel> allSummaries;
  final String searchText;
  final List<SummaryModel> filteredSummaries;
  final bool isLoading;
  final SummaryMainTab selectedMainTab;
  final SummarySubTab selectedSubTab;
  final SummariesMetaModel? meta;
  final SummaryDetailsModel? details;
  final bool isLoadingDetails;

  SummariesState({
    required this.allSummaries,
    this.searchText = '',
    List<SummaryModel>? filteredSummaries,
    this.selectedMainTab = SummaryMainTab.actionRequired,
    this.selectedSubTab = SummarySubTab.inbox,
    this.isLoading = false,
    this.meta,
    this.details,
    this.isLoadingDetails = false,
  }) : filteredSummaries = filteredSummaries ?? allSummaries;

  static const _unset = Object();

  SummariesState copyWith({
    List<SummaryModel>? allSummaries,
    String? searchText,
    List<SummaryModel>? filteredSummaries,
    SummaryMainTab? selectedMainTab,
    SummarySubTab? selectedSubTab,
    bool? isLoading,
    SummariesMetaModel? meta,
    Object? details = _unset,
    bool? isLoadingDetails,
  }) {
    return SummariesState(
      allSummaries: allSummaries ?? this.allSummaries,
      searchText: searchText ?? this.searchText,
      filteredSummaries: filteredSummaries ?? this.filteredSummaries,
      selectedMainTab: selectedMainTab ?? this.selectedMainTab,
      selectedSubTab: selectedSubTab ?? this.selectedSubTab,
      isLoading: isLoading ?? this.isLoading,
      meta: meta ?? this.meta,
      details: details == _unset
          ? this.details
          : details as SummaryDetailsModel?,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
    );
  }

  SummariesState resetData() {
    return copyWith(
      allSummaries: [],
      searchText: '',
      filteredSummaries: [],
      selectedMainTab: SummaryMainTab.actionRequired,
      selectedSubTab: SummarySubTab.inbox,
      isLoading: false,
      details: null,
      isLoadingDetails: false,
    );
  }
}

class SummariesController extends BaseControllerState<SummariesState> {
  SummariesController(super.state, super.ref);

  SummariesRepo get repo => ref.read(summariesRepo);

  Future<void> loadData({bool isInitialLoad = false}) async {
    if (isInitialLoad) state = state.copyWith(isLoading: true);
    int? desId = ref.read(authController).currentDesignation?.userDesgId;
    await fetchSummariesList(desId: desId);
    if (isInitialLoad) state = state.copyWith(isLoading: false);
  }

  SummariesMetaModel? get meta => state.meta;

  Future<SummariesMetaModel?> fetchSummariesMeta() async {
    try {
      int? desId = ref.read(authController).currentDesignation?.userDesgId;
      final meta = await repo.fetchSummariesMeta(desId: desId);
      state = state.copyWith(meta: meta);
      return meta;
    } catch (e, s) {
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return null;
    }
  }

  void resetData() {
    state = state.resetData();
  }

  Future<void> setMainTab(SummaryMainTab mainTab) async {
    final role = state.meta?.activeUserDesg?.roleEnum;
    final firstSub = subTabsForRole(role).firstWhere(
      (s) => s.configFor(role).parent == mainTab,
      orElse: () => SummarySubTab.inbox,
    );
    state = state.copyWith(selectedMainTab: mainTab, selectedSubTab: firstSub);
    await loadData(isInitialLoad: true);
  }

  Future<void> setSubTab(SummarySubTab subTab) async {
    state = state.copyWith(selectedSubTab: subTab);
    await loadData(isInitialLoad: true);
  }

  String get searchText => state.searchText;

  Future<void> setSearchText(String value) async {
    state = state.copyWith(searchText: value, isLoading: true);
    await loadData();
    state = state.copyWith(isLoading: false);
  }

  List<SummaryModel> get allSummaries => state.allSummaries;
  List<SummaryModel> get filteredSummaries => state.filteredSummaries;

  Future<List<SummaryModel>?> fetchSummariesList({required int? desId}) async {
    try {
      final role = state.meta?.activeUserDesg?.roleEnum;
      final filterName =
          state.selectedMainTab.apiValue ??
          state.selectedSubTab.configFor(role).filterName;
      List<SummaryModel> list = await repo.fetchSummariesList(
        desId: desId,
        filterName: filterName,
        query: state.searchText,
      );
      state = state.copyWith(allSummaries: list, filteredSummaries: list);
      return list;
    } catch (e, s) {
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return [];
    }
  }

  SummaryDetailsModel? get details => state.details;

  void clearDetails() {
    state = state.copyWith(details: null, isLoadingDetails: false);
  }

  Future<SummaryDetailsModel?> fetchSummaryDetails({
    required int? summaryId,
    bool showLoading = true,
  }) async {
    try {
      state = state.copyWith(isLoadingDetails: showLoading, details: null);
      int? desId = ref.read(authController).currentDesignation?.userDesgId;
      SummaryDetailsModel details = await repo.fetchSummaryDetails(
        summaryId: summaryId,
        desId: desId,
      );
      state = state.copyWith(details: details, isLoadingDetails: false);
      return details;
    } catch (e, s) {
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      state = state.copyWith(isLoadingDetails: false);
      return null;
    }
  }

  Future<List<DepartmentSecretariesModel>> fetchDepartmentSecretaries({
    required int? deptId,
  }) async {
    try {
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      return await repo.fetchDepartmentSecretaries(
        deptId: deptId,
        desId: desId,
      );
    } catch (e, s) {
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return [];
    }
  }

  Future<bool> deoStoreDraftSummary({
    required CreateSummaryModel createSummaryModel,
  }) async {
    try {
      EasyLoading.show();
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.deoStoreDraftSummary(
        createSummaryModel: createSummaryModel,
        desId: desId,
      );
      Toast.success(message: "Draft summary created successfully");
      await setSubTab(SummarySubTab.drafts);
      RouteHelper.pop();
      EasyLoading.dismiss();

      return true;
    } catch (e, s) {
      EasyLoading.dismiss();
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> deoUpdateDraftSummary({
    required int? summaryId,
    required CreateSummaryModel createSummaryModel,
  }) async {
    try {
      EasyLoading.show();
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.deoUpdateDraftSummary(
        summaryId: summaryId,
        createSummaryModel: createSummaryModel,
        desId: desId,
      );
      Toast.success(message: "Draft summary updated successfully");
      await loadData(isInitialLoad: false);
      RouteHelper.pop();
      EasyLoading.dismiss();
      return true;
    } catch (e, s) {
      EasyLoading.dismiss();
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> secretaryStoreSummary({
    required CreateSummaryModel createSummaryModel,
    required bool isDraft,
  }) async {
    try {
      EasyLoading.show();
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.secretaryStoreSummary(
        createSummaryModel: createSummaryModel,
        desId: desId,
        isDraft: isDraft,
      );
      Toast.success(
        message: isDraft
            ? "Draft summary updated successfully"
            : "Summary created successfully",
      );
      await loadData(isInitialLoad: false);
      EasyLoading.dismiss();
      RouteHelper.pop();
      return true;
    } catch (e, s) {
      EasyLoading.dismiss();
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> submitDraftRemarks({required DraftRemarksModel model}) async {
    try {
      EasyLoading.show();
      await repo.submitDraftRemarks(model: model);
      Toast.success(message: "Remarks submitted successfully");
      await loadData(isInitialLoad: false);
      EasyLoading.dismiss();
      RouteHelper.pop();
      return true;
    } catch (e, s) {
      EasyLoading.dismiss();
      log('submitDraftRemarks error: $e\n$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> returnToSection({
    required int? summaryId,
    required String? remark,
  }) async {
    try {
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.returnToSection(
        summaryId: summaryId,
        remark: remark,
        desId: desId,
      );
      Toast.success(message: "Summary returned to section");
      await loadData(isInitialLoad: false);
      RouteHelper.pop();

      return true;
    } catch (e, s) {
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> shareInternally({
    required int? summaryId,
    required String instruction,
    required List<int>? recipientDesIds,
  }) async {
    try {
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.shareInternally(
        summaryId: summaryId,
        instruction: instruction,
        desId: desId,
        recipientDesIds: recipientDesIds,
      );
      Toast.success(message: "Summary shared internally");
      await loadData(isInitialLoad: false);
      RouteHelper.pop();
      return true;
    } catch (e, s) {
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> updateDraftContent({
    required int? summaryId,
    required String? body,
  }) async {
    try {
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.updateDraftContent(
        summaryId: summaryId,
        body: body,
        desId: desId,
      );
      Toast.success(message: "Draft content updated");
      await fetchSummaryDetails(summaryId: summaryId, showLoading: false);

      return true;
    } catch (e, s) {
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> deleteAttachment(int? attachmentId) async {
    final previousDetails = state.details;
    if (previousDetails != null) {
      state = state.copyWith(
        details: previousDetails.copyWith(
          attachments: previousDetails.attachments
              .where((a) => a.id != attachmentId)
              .toList(),
        ),
      );
    }

    try {
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.deleteAttachment(attachmentId: attachmentId, desId: desId);
      return true;
    } catch (e, s) {
      if (previousDetails != null) {
        state = state.copyWith(details: previousDetails);
      }
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<List<SummaryDaakModel>> searchDaaks({String? query}) async {
    try {
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      return await repo.searchDaaks(desId: desId, query: query);
    } catch (e, s) {
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return [];
    }
  }

  Future<List<SummaryFileModel>> searchFiles({String? query}) async {
    try {
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      return await repo.searchFiles(desId: desId, query: query);
    } catch (e, s) {
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return [];
    }
  }

  Future<bool> signAndForward({
    required int? summaryId,
    required Uint8List signatureBytes,
    required int targetDepartmentId,
    int? targetUserDesgId,
    // Typed remarks (provide when handwritten params are absent)
    String? remarks,
    // Handwritten params (mutually exclusive with remarks)
    String? handwrittenStrokesJson,
    String? handwrittenPngBase64,
    int? handwrittenWidth,
    int? handwrittenHeight,
    String? handwrittenPenColor,
  }) async {
    try {
      EasyLoading.show();
      final desId = ref.read(authController).currentDesignation?.userDesgId;

      // Step 1 – upload signature, get back server path
      final signatureBase64 =
          'data:image/png;base64,${base64Encode(signatureBytes)}';
      final signaturePath = await repo.saveSignForFwd(
        summaryId: summaryId,
        desId: desId,
        signatureBase64: signatureBase64,
      );
      if (signaturePath == null) {
        return false;
      }

      // Step 2 – build payload and forward
      final SignForwardModel payload;
      if (handwrittenStrokesJson != null) {
        payload = HandwrittenSignForwardModel(
          targetDepartmentId: targetDepartmentId,
          targetUserDesgId: targetUserDesgId,
          secretarySignaturePath: signaturePath,
          handwrittenStrokesJson: handwrittenStrokesJson,
          handwrittenPngBase64: handwrittenPngBase64 ?? '',
          handwrittenWidth: handwrittenWidth ?? 0,
          handwrittenHeight: handwrittenHeight ?? 0,
          handwrittenPenColor: handwrittenPenColor ?? '#0D2C6B',
        );
      } else {
        payload = TypedSignForwardModel(
          targetDepartmentId: targetDepartmentId,
          targetUserDesgId: targetUserDesgId,
          secretarySignaturePath: signaturePath,
          remarks: remarks ?? '',
        );
      }
      await repo.signAndForward(
        summaryId: summaryId,
        desId: desId,
        payload: payload,
      );

      Toast.success(message: 'Summary signed and forwarded successfully');
      await loadData(isInitialLoad: false);
      EasyLoading.dismiss();
      RouteHelper.pop();
      return true;
    } catch (e, s) {
      EasyLoading.dismiss();
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> forwardToCM({required int? summaryId}) async {
    try {
      EasyLoading.show();
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.forwardToCM(summaryId: summaryId, desgId: desId);
      Toast.success(message: 'Summary forwarded to CM');
      await loadData(isInitialLoad: false);
      EasyLoading.dismiss();
      RouteHelper.pop();
      return true;
    } catch (e, s) {
      EasyLoading.dismiss();
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> psToSectForward({required int? summaryId}) async {
    try {
      EasyLoading.show();
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.psToSectForward(summaryId: summaryId!, desgId: desId!);
      Toast.success(message: 'Summary forwarded to section');
      await loadData(isInitialLoad: false);
      EasyLoading.dismiss();
      RouteHelper.pop();
      return true;
    } catch (e, s) {
      EasyLoading.dismiss();
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> signAndReturnCM({
    required int? summaryId,
    required Uint8List signatureBytes,
    // Typed remarks
    String? body,
    // Handwritten params
    String? handwrittenStrokesJson,
    String? handwrittenPngBase64,
    int? handwrittenWidth,
    int? handwrittenHeight,
    String? handwrittenPenColor,
  }) async {
    try {
      EasyLoading.show();
      final desId = ref.read(authController).currentDesignation?.userDesgId;

      // Step 1 – upload signature, get back server path
      final signatureBase64 =
          'data:image/png;base64,${base64Encode(signatureBytes)}';
      final signaturePath = await repo.saveSignForFwd(
        summaryId: summaryId,
        desId: desId,
        signatureBase64: signatureBase64,
      );
      if (signaturePath == null) {
        EasyLoading.dismiss();
        return false;
      }

      // Step 2 – build payload and return to CM
      final SignForwardModel payload;
      if (handwrittenStrokesJson != null) {
        payload = HandwrittenSignForwardModel(
          targetDepartmentId: 0,
          secretarySignaturePath: signaturePath,
          handwrittenStrokesJson: handwrittenStrokesJson,
          handwrittenPngBase64: handwrittenPngBase64 ?? '',
          handwrittenWidth: handwrittenWidth ?? 0,
          handwrittenHeight: handwrittenHeight ?? 0,
          handwrittenPenColor: handwrittenPenColor ?? '#0D2C6B',
        );
      } else {
        payload = TypedSignForwardModel(
          targetDepartmentId: 0,
          secretarySignaturePath: signaturePath,
          remarks: body ?? '',
        );
      }

      await repo.signAndReturnCM(
        summaryId: summaryId!,
        desgId: desId!,
        payload: payload,
      );

      Toast.success(message: 'Summary signed and returned to CM');
      await loadData(isInitialLoad: false);
      EasyLoading.dismiss();
      RouteHelper.pop();
      return true;
    } catch (e, s) {
      EasyLoading.dismiss();
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> disposeOffSummary({
    required int? summaryId,
    required String remarks,
  }) async {
    try {
      EasyLoading.show();
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.disposeOffSummary(
        summaryId: summaryId,
        instruction: remarks,
        desId: desId,
      );
      Toast.success(message: 'Summary disposed off');
      await loadData(isInitialLoad: false);
      EasyLoading.dismiss();
      RouteHelper.pop();
      return true;
    } catch (e, s) {
      EasyLoading.dismiss();
      log('ERRR________${e}______$s');
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<bool> uploadVoiceNote({
    required int? summaryId,
    required String filePath,
    required int durationSec,
    required VoiceNoteVisibility visibility,
    VoiceNoteContext? context,
  }) async {
    try {
      if (summaryId == null) return false;
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      if (desId == null) return false;
      final bytes = await File(filePath).readAsBytes();
      final filename = filePath.split('/').last;
      await repo.uploadVoiceNote(
        summaryId: summaryId,
        desgId: desId,
        model: VoiceNoteUploadModel(
          audioBytes: bytes,
          audioFilename: filename,
          visibility: visibility,
          durationSec: durationSec,
          context: context,
        ),
      );
      return true;
    } catch (e, s) {
      log('uploadVoiceNote error: $e\n$s');
      return false;
    }
  }

  Future<List<SummaryVoiceNoteModel>> listVoiceNotes({
    required int? summaryId,
    required VoiceNoteVisibility visibility,
  }) async {
    try {
      List<SummaryVoiceNoteModel> voiceNotes = [];
      if (summaryId == null) return [];
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      if (desId == null) return [];
      voiceNotes = await repo.listVoiceNotes(
        summaryId: summaryId,
        desgId: desId,
      );
      return voiceNotes.where((note) => note.visibility == visibility).toList();
    } catch (e, s) {
      log('listVoiceNotes error: $e\n$s');
      return [];
    }
  }
}
