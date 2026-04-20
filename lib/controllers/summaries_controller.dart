import 'dart:developer';

import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/summaries/summaries_meta_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/repository/summaries/summaries_repo.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';

enum SummaryMainTab {
  actionRequired('Action Required', Icons.notifications_none_rounded),
  sentTracked('Sent & Tracked', Icons.check_circle_outline_rounded),
  archive('Archive', Icons.archive_outlined);

  final String label;
  final IconData icon;
  const SummaryMainTab(this.label, this.icon);
}

enum SummarySubTab {
  // Action Required
  inbox('Inbox', SummaryMainTab.actionRequired, 'inbox'),
  sharedToMe('Shared to me', SummaryMainTab.actionRequired, 'internal'),
  drafts(
    'Drafts',
    SummaryMainTab.actionRequired,
    'draft',
    //'my_drafts',
  ),
  disposal('Disposal', SummaryMainTab.actionRequired, 'pending_disposal'),

  // Sent & Tracked
  sentOut('Sent Out', SummaryMainTab.sentTracked, 'sent'),
  sharedInternally(
    'Shared Internally',
    SummaryMainTab.sentTracked,
    'internal_forwarded',
  );

  final String label;
  final SummaryMainTab parent;
  final String filterName;
  const SummarySubTab(this.label, this.parent, this.filterName);
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
    final firstSub = SummarySubTab.values.firstWhere(
      (s) => s.parent == mainTab,
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
      List<SummaryModel> list = await repo.fetchSummariesList(
        desId: desId,
        subTab: state.selectedSubTab,
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
  }) async {
    try {
      state = state.copyWith(isLoadingDetails: true, details: null);
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
}
