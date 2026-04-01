import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/repository/daak/daak_repo.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';

enum DaakViewFilter { inbox, nfa, forwarded }

class DaakState {
  final List<DaakModel> allDaak;
  final String searchText;
  final List<DaakModel> filteredDaak;
  final bool isLoading;
  final DaakMeta? daakMeta;
  final DaakStatus? selectedStatus;
  final DaakViewFilter selectedFilter;

  DaakState({
    required this.allDaak,
    this.searchText = '',
    List<DaakModel>? filteredDaak,
    this.daakMeta,
    this.selectedStatus,
    this.selectedFilter = DaakViewFilter.inbox,
    this.isLoading = false,
  }) : filteredDaak = filteredDaak ?? allDaak;

  DaakState copyWith({
    List<DaakModel>? allDaak,
    String? searchText,
    List<DaakModel>? filteredDaak,
    DaakMeta? daakMeta,
    DaakStatus? selectedStatus,
    DaakViewFilter? selectedFilter,
    bool? isLoading,
  }) {
    return DaakState(
      allDaak: allDaak ?? this.allDaak,
      searchText: searchText ?? this.searchText,
      filteredDaak: filteredDaak ?? this.filteredDaak,
      daakMeta: daakMeta ?? this.daakMeta,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DaakController extends BaseControllerState<DaakState> {
  DaakController(super.state, super.ref);

  DaakRepo get repo => ref.read(daakRepo);

  Future<void> loadData({bool isInitailLoad = false}) async {
    if (isInitailLoad) state = state.copyWith(isLoading: true);
    int? desId = ref.read(authController).currentDesignation?.userDesgId;
    fetchDaakMeta(desId);
    if (state.selectedFilter == DaakViewFilter.inbox) {
      await fetchDaakInbox(desId: desId);
    } else if (state.selectedFilter == DaakViewFilter.nfa) {
      await fetchDaakMyNfa(desId: desId);
    } else if (state.selectedFilter == DaakViewFilter.forwarded) {
      await fetchDaakForwardedHistory(desId: desId);
    }
    if (isInitailLoad) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> applyStatusFilter(DaakStatus? status) async {
    state = state.copyWith(selectedStatus: status);
    await loadData();
  }

  List<DaakModel> get allDaak => state.allDaak;

  String get searchText => state.searchText;
  set searchText(String value) {
    state = state.copyWith(
      searchText: value,
      filteredDaak: state.allDaak.where((daak) {
        final query = value.toLowerCase();
        return daak.subject?.toLowerCase().contains(query) == true ||
            daak.sourceDepartment?.toLowerCase().contains(query) == true ||
            daak.letterNo?.toLowerCase().contains(query) == true ||
            daak.diaryNo?.toLowerCase().contains(query) == true ||
            daak.receivedBy?.toLowerCase().contains(query) == true;
      }).toList(),
    );
  }

  List<DaakModel> get filteredDaak => state.filteredDaak;

  Future<DaakMeta?> fetchDaakMeta(int? desId) async {
    try {
      DaakMeta meta = await repo.fetchDaakMeta(desId);
      state = state.copyWith(daakMeta: meta);
      return meta;
    } catch (e) {
      Toast.error(message: handleException(e));
      return null;
    }
  }

  Future<List<DaakModel>?> fetchDaakInbox({required int? desId}) async {
    try {
      List<DaakModel> daakList = await repo.fetchDaakInbox(
          desId: desId, status: state.selectedStatus, query: state.searchText);
      state = state.copyWith(allDaak: daakList, filteredDaak: daakList);
      return daakList;
    } catch (e) {
      Toast.error(message: handleException(e));
      return [];
    }
  }

  Future<List<DaakModel>?> fetchDaakMyNfa({required int? desId}) async {
    try {
      List<DaakModel> daakList = await repo.fetchDaakMyNfa(
          desId: desId, status: state.selectedStatus, query: state.searchText);
      state = state.copyWith(allDaak: daakList, filteredDaak: daakList);
      return daakList;
    } catch (e) {
      Toast.error(message: handleException(e));
      return [];
    }
  }

  Future<List<DaakModel>?> fetchDaakForwardedHistory(
      {required int? desId}) async {
    try {
      List<DaakModel> daakList = await repo.fetchDaakForwardedHistory(
          desId: desId, status: state.selectedStatus, query: state.searchText);
      state = state.copyWith(allDaak: daakList, filteredDaak: daakList);
      return daakList;
    } catch (e) {
      Toast.error(message: handleException(e));
      return [];
    }
  }
}
