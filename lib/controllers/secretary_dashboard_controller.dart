import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/secretary_dashboard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecretaryDashboardState {
  final SecretaryDashboardModel? data;
  final bool loading;
  final String? error;

  /// Text typed in the search bar, as entered.
  final String query;

  const SecretaryDashboardState({
    this.data,
    this.loading = false,
    this.error,
    this.query = '',
  });

  SecretaryDashboardState copyWith({
    SecretaryDashboardModel? data,
    bool? loading,
    String? error,
    String? query,
  }) {
    return SecretaryDashboardState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      query: query ?? this.query,
    );
  }

  /// [data] narrowed to [query]; null when there is nothing to filter by.
  SecretarySearchFilter? get filter {
    final data = this.data;
    return data == null ? null : SecretarySearchFilter.from(data, query);
  }
}

class SecretaryDashboardController
    extends BaseControllerState<SecretaryDashboardState> {
  SecretaryDashboardController(super.state, super.ref);

  void setQuery(String value) => state = state.copyWith(query: value);

  void clearQuery() => state = state.copyWith(query: '');

  Future<void> initData() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final userDesgId = ref
          .read(authController)
          .currentDesignation
          ?.userDesgId;
      final result = await ref
          .read(dashboardRepo)
          .getSecretaryDashboard(userDesgId: userDesgId);
      state = state.copyWith(data: result, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: handleException(e));
    }
  }
}

final secretaryDashboardController =
    StateNotifierProvider<
      SecretaryDashboardController,
      SecretaryDashboardState
    >(
      (ref) =>
          SecretaryDashboardController(const SecretaryDashboardState(), ref),
    );

/// The dashboard's user and section data narrowed to a search query.
///
/// A user matches on name, designation or section; a section matches on its
/// own name or because a matching user belongs to it. Searching the
/// department's own name matches everything, so [from] returns null (no
/// filter) in that case and for an empty query.
class SecretarySearchFilter {
  const SecretarySearchFilter({
    required this.topFilePutup,
    required this.topPending,
    required this.topForwarded,
    required this.sections,
    required this.userCount,
  });

  final List<SecretaryTopUserModel> topFilePutup;
  final List<SecretaryTopUserModel> topPending;
  final List<SecretaryTopUserModel> topForwarded;
  final List<SecretarySectionStatModel> sections;

  /// Distinct matching users across the three top lists.
  final int userCount;

  static SecretarySearchFilter? from(
    SecretaryDashboardModel data,
    String query,
  ) {
    query = query.trim().toLowerCase();
    if (query.isEmpty) return null;

    final department = data.context?.department?.title?.toLowerCase();
    if (department != null && department.contains(query)) return null;

    bool has(String? text) => text?.toLowerCase().contains(query) ?? false;

    List<SecretaryTopUserModel> users(List<SecretaryTopUserModel>? all) =>
        (all ?? const <SecretaryTopUserModel>[])
            .where(
              (u) => has(u.userTitle) || has(u.designation) || has(u.section),
            )
            .toList();

    final putup = users(data.charts?.topFilePutup);
    final pending = users(data.charts?.topPending);
    final forwarded = users(data.charts?.topForwarded);

    final matchedUsers = [...putup, ...pending, ...forwarded];
    final userSections = {
      for (final u in matchedUsers)
        if (u.section != null) u.section!.toLowerCase(),
    };
    final userIds = {for (final u in matchedUsers) u.userDesgId ?? u.userTitle};

    return SecretarySearchFilter(
      topFilePutup: putup,
      topPending: pending,
      topForwarded: forwarded,
      sections: data.sectionStats
          .where(
            (s) =>
                has(s.section) ||
                userSections.contains(s.section?.toLowerCase()),
          )
          .toList(),
      userCount: userIds.length,
    );
  }
}
