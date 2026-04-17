import 'dart:developer';

import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/repository/summaries/summaries_repo.dart';
import 'package:efiling_balochistan/views/screens/summaries/summaries_list_screen.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';

class SummariesState {
  final List<SummaryModel> allSummaries;
  final String searchText;
  final List<SummaryModel> filteredSummaries;
  final bool isLoading;
  final SummaryMainTab selectedMainTab;
  final SummarySubTab selectedSubTab;

  SummariesState({
    required this.allSummaries,
    this.searchText = '',
    List<SummaryModel>? filteredSummaries,
    this.selectedMainTab = SummaryMainTab.actionRequired,
    this.selectedSubTab = SummarySubTab.inbox,
    this.isLoading = false,
  }) : filteredSummaries = filteredSummaries ?? allSummaries;

  SummariesState copyWith({
    List<SummaryModel>? allSummaries,
    String? searchText,
    List<SummaryModel>? filteredSummaries,
    SummaryMainTab? selectedMainTab,
    SummarySubTab? selectedSubTab,
    bool? isLoading,
  }) {
    return SummariesState(
      allSummaries: allSummaries ?? this.allSummaries,
      searchText: searchText ?? this.searchText,
      filteredSummaries: filteredSummaries ?? this.filteredSummaries,
      selectedMainTab: selectedMainTab ?? this.selectedMainTab,
      selectedSubTab: selectedSubTab ?? this.selectedSubTab,
      isLoading: isLoading ?? this.isLoading,
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
}
