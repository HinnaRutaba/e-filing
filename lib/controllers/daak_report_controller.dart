import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/daak/daak_report_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DaakReportState {
  final DaakReportModel? data;
  final bool loading;
  final String? error;
  final DaakReportPeriod period;

  /// Only used (and only sent to the API) when [period] is
  /// [DaakReportPeriod.custom].
  final DateTime? from;
  final DateTime? to;

  const DaakReportState({
    this.data,
    this.loading = false,
    this.error,
    this.period = DaakReportPeriod.all,
    this.from,
    this.to,
  });

  static const _unset = Object();

  DaakReportState copyWith({
    Object? data = _unset,
    bool? loading,
    Object? error = _unset,
    DaakReportPeriod? period,
    Object? from = _unset,
    Object? to = _unset,
  }) {
    return DaakReportState(
      data: data == _unset ? this.data : data as DaakReportModel?,
      loading: loading ?? this.loading,
      error: error == _unset ? this.error : error as String?,
      period: period ?? this.period,
      from: from == _unset ? this.from : from as DateTime?,
      to: to == _unset ? this.to : to as DateTime?,
    );
  }
}

class DaakReportController extends BaseControllerState<DaakReportState> {
  DaakReportController(super.state, super.ref);

  /// Picks a preset [period] and reloads. Choosing [DaakReportPeriod.custom]
  /// here does nothing until a range is set with [setCustomRange].
  Future<void> setPeriod(DaakReportPeriod period) async {
    if (period == DaakReportPeriod.custom &&
        (state.from == null || state.to == null)) {
      return;
    }
    state = state.copyWith(period: period);
    await load();
  }

  /// [to] must not be before [from].
  Future<void> setCustomRange(DateTime from, DateTime to) async {
    if (to.isBefore(from)) return;
    state = state.copyWith(period: DaakReportPeriod.custom, from: from, to: to);
    await load();
  }

  /// Drops the custom range and goes back to the default period.
  Future<void> clearCustomRange() async {
    state = state.copyWith(
      period: const DaakReportState().period,
      from: null,
      to: null,
    );
    await load();
  }

  Future<void> load() async {
    // Keep the previous data on screen while reloading so the page doesn't
    // flash empty; it is replaced when the new response arrives.
    state = state.copyWith(loading: true, error: null);
    try {
      final userDesgId = ref
          .read(authController)
          .currentDesignation
          ?.userDesgId;
      final result = await ref
          .read(daakRepo)
          .fetchDaakReport(
            desId: userDesgId,
            period: state.period,
            from: state.from,
            to: state.to,
          );
      state = state.copyWith(data: result, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: handleException(e));
    }
  }
}

final daakReportController =
    StateNotifierProvider<DaakReportController, DaakReportState>(
      (ref) => DaakReportController(const DaakReportState(), ref),
    );
