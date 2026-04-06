import 'dart:developer';

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/repository/daak/daak_repo.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

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

  static const _unset = Object();

  DaakState copyWith({
    List<DaakModel>? allDaak,
    String? searchText,
    List<DaakModel>? filteredDaak,
    DaakMeta? daakMeta,
    Object? selectedStatus = _unset,
    DaakViewFilter? selectedFilter,
    bool? isLoading,
  }) {
    return DaakState(
      allDaak: allDaak ?? this.allDaak,
      searchText: searchText ?? this.searchText,
      filteredDaak: filteredDaak ?? this.filteredDaak,
      daakMeta: daakMeta ?? this.daakMeta,
      selectedStatus: selectedStatus == _unset
          ? this.selectedStatus
          : selectedStatus as DaakStatus?,
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

  Future<void> setViewFilter(DaakViewFilter filter) async {
    state = state.copyWith(selectedFilter: filter);
    await loadData(isInitailLoad: true);
  }

  Future<void> applyStatusFilter(DaakStatus? status) async {
    state = state.copyWith(selectedStatus: status);
    await loadData(isInitailLoad: true);
  }

  List<DaakModel> get allDaak => state.allDaak;

  String get searchText => state.searchText;
  Future<void> setSearchText(String value) async {
    state = state.copyWith(searchText: value, isLoading: true);
    await loadData();
    state = state.copyWith(isLoading: false);
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

  Future<DaakModel?> fetchDaakDetails(
      {required int? daakId, required DaakStatus status}) async {
    try {
      int? desId = ref.read(authController).currentDesignation?.userDesgId;
      DaakModel? daak;
      if (status == DaakStatus.inProgress1 ||
          status == DaakStatus.inProgress2 ||
          status == DaakStatus.inProgress3) {
        daak = await repo.fetchDaakInboxShow(daakId: daakId, desId: desId);
      } else if (status == DaakStatus.forwarded) {
        daak = await repo.fetchDaakFwdShow(daakId: daakId, desId: desId);
      }
      return daak;
    } catch (e) {
      Toast.error(message: handleException(e));
      return null;
    }
  }

  Future<DaakModel?> fetchDaakInboxShow(
      {required int daakId, required int desId}) async {
    try {
      DaakModel? daak =
          await repo.fetchDaakInboxShow(daakId: daakId, desId: desId);
      return daak;
    } catch (e) {
      Toast.error(message: handleException(e));
      return null;
    }
  }

  Future<DaakModel?> fetchDaakFwdShow(
      {required int daakId, required int desId}) async {
    try {
      DaakModel? daak =
          await repo.fetchDaakFwdShow(daakId: daakId, desId: desId);
      return daak;
    } catch (e) {
      Toast.error(message: handleException(e));
      return null;
    }
  }

  Future<void> forwardDaak({
    required int? daakId,
    required int? fwdToDesId,
    String? remarks,
    XFile? supportingAttachment,
  }) async {
    try {
      EasyLoading.show();
      int? desId = ref.read(authController).currentDesignation?.userDesgId;
      await repo.forwardDaakSecretary(
        daakId: daakId,
        returnToDesId: fwdToDesId,
        desId: desId,
        remarks: remarks,
        supportingAttachment: supportingAttachment,
      );
      Toast.success(message: "Daak forwarded successfully");
      EasyLoading.dismiss();
      RouteHelper.pop(DaakViewFilter.inbox);
    } catch (e, s) {
      log("ERRR_____${e}______$s");
      EasyLoading.dismiss();
      Toast.error(message: handleException(e));
    }
  }
}
